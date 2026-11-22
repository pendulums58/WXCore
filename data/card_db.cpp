#include "card_db.h"
#include "json.h"

#include <sqlite3.h>

#include <algorithm>
#include <cctype>
#include <filesystem>
#include <fstream>
#include <sstream>
#include <variant>

namespace wxtest {

namespace {


std::vector<std::string> json_strings(const char* text) {
  std::vector<std::string> out;
  if (!text) return out;
  Json j;
  if (!parse_json(text, j) || !j.arr()) return out;
  for (const Json& x : *j.arr())
    if (auto* s = x.str()) out.push_back(*s);
  return out;
}

uint32_t type_bits(const std::vector<std::string>& kinds) {
  static const std::map<std::string, uint32_t> m = {
      {"ルリグ", wx::TYPE_LRIG},        {"シグニ", wx::TYPE_SIGNI},   {"アーツ", wx::TYPE_ARTS},
      {"スペル", wx::TYPE_SPELL},       {"アシストルリグ", wx::TYPE_ASSIST_LRIG},
      {"トークン", wx::TYPE_TOKEN},     {"ピース", wx::TYPE_PIECE},   {"キー", wx::TYPE_KEY},
      {"レゾナ", wx::TYPE_RESONA},      {"クラフト", wx::TYPE_CRAFT}, {"コイン", wx::TYPE_COIN},
      {"リレー", wx::TYPE_RELAY},
  };
  uint32_t t = 0;
  for (const auto& k : kinds)
    if (auto it = m.find(k); it != m.end()) t |= it->second;
  return t;
}

uint32_t timing_bits(const std::vector<std::string>& timings) {
  uint32_t t = 0;
  for (const auto& x : timings) {
    if (x == "メインフェイズ") t |= wx::TIMING_MAIN;
    if (x == "アタックフェイズ") t |= wx::TIMING_ATTACK;
    if (x == "スペルカットイン") t |= wx::TIMING_CUTIN;
  }
  return t;
}

const char* text_col(sqlite3_stmt* st, int i) { return reinterpret_cast<const char*>(sqlite3_column_text(st, i)); }

}  // namespace

CardDb::~CardDb() {
  for (sqlite3* db : dbs_) sqlite3_close(db);
}

bool CardDb::open(const std::string& path) {
  sqlite3* db = nullptr;
  if (sqlite3_open_v2(path.c_str(), &db, SQLITE_OPEN_READONLY, nullptr) != SQLITE_OK) {
    error_ = path + ": " + (db ? sqlite3_errmsg(db) : "열 수 없음");
    if (db) sqlite3_close(db);
    return false;
  }
  dbs_.push_back(db);
  paths_.push_back(path);
  // 나중에 연 DB가 앞선 것을 덮으므로 읽어 둔 것을 비운다
  cache_.clear();
  text_cache_.clear();
  all_.clear();
  all_index_.clear();
  name_formats_.clear();
  return true;
}

void CardDb::close_all() {
  for (sqlite3* db : dbs_) sqlite3_close(db);
  dbs_.clear();
  paths_.clear();
  error_.clear();
  cache_.clear();
  text_cache_.clear();
  all_.clear();
  all_index_.clear();
  name_formats_.clear();
}

int CardDb::open_all() {
  int n = 0;
  for (const auto& dir : data_dirs()) {
    std::vector<std::string> files;
    std::error_code ec;
    for (const auto& e : std::filesystem::directory_iterator(dir, ec))
      if (e.path().extension() == ".db") files.push_back(e.path().string());
    std::sort(files.begin(), files.end());
    for (const auto& f : files) n += open(f) ? 1 : 0;
  }
  if (!n && error_.empty()) error_ = "카드 DB(*.db)가 repositories/·expansions/ 어디에도 없음";
  return n;
}

bool CardDb::read(wx::Cid cid, wx::CardData& out) {
  if (auto it = cache_.find(cid); it != cache_.end()) {
    out = it->second;
    return true;
  }
  bool found = false;
  for (auto db = dbs_.rbegin(); db != dbs_.rend() && !found; ++db) {  // 나중에 연 DB가 우선
  sqlite3_stmt* st = nullptr;
  sqlite3_prepare_v2(*db,
                     "SELECT kind, class, color, level, lim, power, cost_ena, grow_ena, limit_cond, guard, "
                     "life_burst, timing, alias, team, coin, cost_other FROM cards WHERE cid=?",
                     -1, &st, nullptr);
  sqlite3_bind_int64(st, 1, cid);
  if (sqlite3_step(st) == SQLITE_ROW) {
    found = true;
    wx::CardData d;
    d.cid = cid;
    d.type = type_bits(json_strings(text_col(st, 0)));
    d.classes = json_strings(text_col(st, 1));
    d.color = static_cast<uint8_t>(sqlite3_column_int(st, 2));
    d.level = sqlite3_column_int(st, 3);
    d.limit = sqlite3_column_int(st, 4);
    const int power = sqlite3_column_int(st, 5);
    d.power = power < 0 ? wx::kPowerInfinity : power;
    if (auto* s = text_col(st, 6)) d.cost_ena = s;
    if (auto* s = text_col(st, 7)) d.grow_ena = s;
    d.limit_cond = json_strings(text_col(st, 8));
    d.guard = sqlite3_column_int(st, 9) != 0;
    d.life_burst = sqlite3_column_int(st, 10) != 0;
    d.timing = timing_bits(json_strings(text_col(st, 11)));
    d.alias = static_cast<wx::Cid>(sqlite3_column_int64(st, 12));
    d.teams = json_strings(text_col(st, 13));
    d.coin = sqlite3_column_int(st, 14);
    if (const char* other = text_col(st, 15)) {  // {"coin": 1}
      Json j;
      if (parse_json(other, j))
        if (const Json* c = j.get("coin"); c && c->num()) d.cost_coin = static_cast<uint32_t>(*c->num());
    }
    cache_[cid] = d;
    out = d;
  }
  sqlite3_finalize(st);
  }
  return found;
}

wx::Cid CardDb::cid_of(const std::string& card_no) {
  wx::Cid cid = 0;
  for (auto db = dbs_.rbegin(); db != dbs_.rend() && !cid; ++db) {
    sqlite3_stmt* st = nullptr;
    sqlite3_prepare_v2(*db, "SELECT cid FROM prints WHERE card_no=? LIMIT 1", -1, &st, nullptr);
    sqlite3_bind_text(st, 1, card_no.c_str(), -1, SQLITE_TRANSIENT);
    if (sqlite3_step(st) == SQLITE_ROW) cid = static_cast<wx::Cid>(sqlite3_column_int64(st, 0));
    sqlite3_finalize(st);
  }
  return cid;
}

std::string CardDb::name_of(wx::Cid cid) {
  std::string name;
  for (auto db = dbs_.rbegin(); db != dbs_.rend() && name.empty(); ++db) {
    sqlite3_stmt* st = nullptr;
    sqlite3_prepare_v2(*db, "SELECT name FROM texts WHERE cid=? AND lang='ja'", -1, &st, nullptr);
    sqlite3_bind_int64(st, 1, cid);
    if (sqlite3_step(st) == SQLITE_ROW)
      if (auto* s = text_col(st, 0)) name = s;
    sqlite3_finalize(st);
  }
  return name;
}

CardDb::Text CardDb::text_of(wx::Cid cid) {
  if (auto it = text_cache_.find(cid); it != text_cache_.end()) return it->second;
  Text t;
  bool found = false;
  for (auto db = dbs_.rbegin(); db != dbs_.rend() && !found; ++db) {
    sqlite3_stmt* st = nullptr;
    sqlite3_prepare_v2(*db,
                       "SELECT name, ability, life_burst_text FROM texts WHERE cid=? "
                       "ORDER BY CASE lang WHEN 'ko' THEN 0 ELSE 1 END LIMIT 1",
                       -1, &st, nullptr);
    sqlite3_bind_int64(st, 1, cid);
    if (sqlite3_step(st) == SQLITE_ROW) {
      found = true;
      if (auto* s = text_col(st, 0)) t.name = s;
      if (auto* s = text_col(st, 1)) t.ability = s;
      if (auto* s = text_col(st, 2)) t.life_burst = s;
    }
    sqlite3_finalize(st);
  }
  text_cache_[cid] = t;
  return t;
}

bool CardDb::fill(wx::Cid cid, wx_card_data* out) {
  wx::CardData d;
  if (!read(cid, d)) return false;
  auto join = [](const std::vector<std::string>& v) {
    std::string s;
    for (const auto& x : v) s += x + "\n";
    return s;
  };
  fill_buf_[0] = join(d.classes);
  fill_buf_[1] = join(d.limit_cond);
  fill_buf_[2] = join(d.teams);
  static thread_local std::string cost, grow;
  cost = d.cost_ena;
  grow = d.grow_ena;
  out->cid = cid;
  out->alias = d.alias;
  out->type = d.type;
  out->color = d.color;
  out->level = d.level;
  out->limit = d.limit;
  out->power = d.power;
  out->classes = fill_buf_[0].c_str();
  out->limit_cond = fill_buf_[1].c_str();
  out->teams = fill_buf_[2].c_str();
  out->cost_ena = cost.c_str();
  out->grow_ena = grow.c_str();
  out->guard = d.guard;
  out->life_burst = d.life_burst;
  out->timing = d.timing;
  out->coin = d.coin;
  out->cost_coin = d.cost_coin;
  return true;
}

const std::vector<CardEntry>& CardDb::all_cards() {
  if (!all_.empty() || dbs_.empty()) return all_;
  for (sqlite3* db : dbs_) {  // 나중 DB가 같은 cid를 덮는다
  sqlite3_stmt* st = nullptr;
  sqlite3_prepare_v2(
      db,
      "SELECT c.cid, c.kind, c.class, c.color, c.level, c.lim, c.power, c.life_burst, c.alias, "
      "  (SELECT MAX(p.formats & 1) FROM prints p WHERE p.cid=c.cid) | "
      "  (SELECT MAX(p.formats & 2) FROM prints p WHERE p.cid=c.cid), "
      "  (SELECT p.card_no FROM prints p WHERE p.cid=c.cid ORDER BY p.idx LIMIT 1), "
      "  (SELECT group_concat(p.card_no, ' ') FROM prints p WHERE p.cid=c.cid), "
      "  tj.name, tj.reading, tj.ability, tj.life_burst_text, tk.name, tk.ability, tk.life_burst_text "
      "FROM cards c "
      "LEFT JOIN texts tj ON tj.cid=c.cid AND tj.lang='ja' "
      "LEFT JOIN texts tk ON tk.cid=c.cid AND tk.lang='ko' "
      "ORDER BY c.cid",
      -1, &st, nullptr);
  auto col = [&](int i) -> std::string {
    const char* t = text_col(st, i);
    return t ? t : "";
  };
  while (sqlite3_step(st) == SQLITE_ROW) {
    CardEntry e;
    e.type = type_bits(json_strings(text_col(st, 1)));
    if (e.type & (wx::TYPE_TOKEN | wx::TYPE_COIN | wx::TYPE_CRAFT)) continue;  // 덱에 넣지 않는다
    e.cid = static_cast<wx::Cid>(sqlite3_column_int64(st, 0));
    e.classes = json_strings(text_col(st, 2));
    e.color = static_cast<uint8_t>(sqlite3_column_int(st, 3));
    e.level = sqlite3_column_int(st, 4);
    e.limit = sqlite3_column_int(st, 5);
    const int power = sqlite3_column_int(st, 6);
    e.power = power < 0 ? wx::kPowerInfinity : power;
    e.life_burst = sqlite3_column_int(st, 7) != 0;
    e.alias = static_cast<wx::Cid>(sqlite3_column_int64(st, 8));
    e.formats = static_cast<uint32_t>(sqlite3_column_int(st, 9));
    e.card_no = col(10);
    e.name_ja = col(12);
    e.name = col(16).empty() ? e.name_ja : col(16);
    // 이름·읽기·카드 번호(모든 인쇄본)·클래스·텍스트(일본어·한국어)
    std::string search = e.name + "\n" + e.name_ja + "\n" + col(13) + "\n" + col(11) + "\n";
    for (const auto& c : e.classes) search += c + "\n";
    search += col(14) + "\n" + col(15) + "\n" + col(17) + "\n" + col(18);
    std::transform(search.begin(), search.end(), search.begin(),
                   [](char ch) { return static_cast<char>(std::tolower(static_cast<unsigned char>(ch))); });
    e.search = std::move(search);
    if (auto it = all_index_.find(e.cid); it != all_index_.end()) {
      all_[it->second] = std::move(e);
    } else {
      all_index_[e.cid] = all_.size();
      all_.push_back(std::move(e));
    }
  }
  sqlite3_finalize(st);
  }
  std::sort(all_.begin(), all_.end(), [](const CardEntry& a, const CardEntry& b) { return a.cid < b.cid; });
  all_index_.clear();
  name_formats_.clear();
  for (size_t i = 0; i < all_.size(); ++i) {
    all_index_[all_[i].cid] = i;
    name_formats_[all_[i].name_ja] |= all_[i].formats;
  }
  return all_;
}

const CardEntry* CardDb::entry(wx::Cid cid) {
  all_cards();
  auto it = all_index_.find(cid);
  return it == all_index_.end() ? nullptr : &all_[it->second];
}

bool CardDb::name_has_format(const std::string& name_ja, uint32_t bits) {
  all_cards();
  auto it = name_formats_.find(name_ja);
  return it != name_formats_.end() && (it->second & bits);
}

std::string CardDb::card_no_of(wx::Cid cid) {
  if (const CardEntry* e = entry(cid)) return e->card_no;
  return {};
}

bool read_deck_text(const std::string& path, std::string& text) {
  std::ifstream f(path, std::ios::binary);
  if (!f) return false;
  std::stringstream ss;
  ss << f.rdbuf();
  text = ss.str();
  return true;
}

bool load_deck(const std::string& path, CardDb& db, DeckFile& out, std::string& error) {
  std::string text;
  if (!read_deck_text(path, text)) {
    error = path + ": 열 수 없음";
    return false;
  }
  return load_deck_text(text, db, out, error, path);
}

bool load_deck_text(const std::string& text, CardDb& db, DeckFile& out, std::string& error, const std::string& path) {
  Json j;
  if (!parse_json(text, j) || !j.obj()) {
    error = path + ": JSON 형식 오류";
    return false;
  }
  auto cid = [&](const std::string& no) {
    const wx::Cid c = db.cid_of(no);
    if (!c && error.empty()) error = path + ": 모르는 카드 번호 " + no;
    if (c) out.card_no.emplace(c, no);
    return c;
  };
  if (auto* s = j.get("name"); s && s->str()) out.name = *s->str();
  if (auto* s = j.get("format"); s && s->str()) out.format = *s->str();
  auto counts = [&](const char* key, std::vector<wx::Cid>& dst) {
    const Json* o = j.get(key);
    if (!o || !o->obj()) return;
    for (auto& [no, n] : *o->obj())
      for (long long k = 0; k < (n.num() ? *n.num() : 0); ++k) dst.push_back(cid(no));
  };
  counts("lrig", out.lrig);
  counts("main", out.main);
  if (const Json* s = j.get("start_lrig")) {
    if (auto* c = s->get("center"); c && c->str()) out.start_center = cid(*c->str());
    if (auto* a = s->get("assist"); a && a->arr())
      for (const Json& x : *a->arr())
        if (x.str()) out.start_assists.push_back(cid(*x.str()));
  }
  return error.empty();
}

namespace {

std::string json_quote(const std::string& s) {
  std::string out = "\"";
  for (char c : s) {
    if (c == '"' || c == '\\') out += '\\';
    if (c == '\n') {
      out += "\\n";
      continue;
    }
    out += c;
  }
  return out + "\"";
}

}  // namespace

bool save_deck(const std::string& path, CardDb& db, const DeckFile& deck, std::string& error) {
  auto no = [&](wx::Cid c) {
    auto it = deck.card_no.find(c);
    return it != deck.card_no.end() ? it->second : db.card_no_of(c);
  };
  // {"카드 번호": 장 수} — 처음 나온 순서대로
  auto counts = [&](const std::vector<wx::Cid>& cards) {
    std::vector<std::pair<std::string, int>> list;
    for (wx::Cid c : cards) {
      const std::string n = no(c);
      if (n.empty()) {
        if (error.empty()) error = "카드 번호를 모르는 카드: cid " + std::to_string(c);
        continue;
      }
      auto it = std::find_if(list.begin(), list.end(), [&](const auto& x) { return x.first == n; });
      if (it == list.end()) list.emplace_back(n, 1);
      else ++it->second;
    }
    std::string s = "{";
    for (size_t i = 0; i < list.size(); ++i) s += (i ? "," : "") + json_quote(list[i].first) + ":" + std::to_string(list[i].second);
    return s + "}";
  };
  std::string text = "{\n";
  text += "  \"name\": " + json_quote(deck.name) + ",\n";
  text += "  \"format\": " + json_quote(deck.format) + ",\n";
  text += "  \"lrig\": " + counts(deck.lrig) + ",\n";
  text += "  \"main\": " + counts(deck.main) + ",\n";
  text += "  \"start_lrig\": {\"center\":" + (deck.start_center ? json_quote(no(deck.start_center)) : std::string("null")) +
          ",\"assist\":[";
  for (size_t i = 0; i < deck.start_assists.size(); ++i) text += (i ? "," : "") + json_quote(no(deck.start_assists[i]));
  text += "]}\n}\n";
  if (!error.empty()) return false;
  std::ofstream f(path, std::ios::binary);
  if (!f) {
    error = path + ": 쓸 수 없음";
    return false;
  }
  f << text;
  return static_cast<bool>(f);
}

std::string data_dir() { return WX_DATA_DIR; }

std::vector<std::string> data_dirs() {
  std::vector<std::string> out;
  for (const char* group : {"repositories", "expansions"}) {
    std::vector<std::string> found;
    std::error_code ec;
    for (const auto& e : std::filesystem::directory_iterator(data_dir() + "/" + group, ec))
      if (e.is_directory()) found.push_back(e.path().string());
    std::sort(found.begin(), found.end());
    out.insert(out.end(), found.begin(), found.end());
  }
  return out;
}

std::string find_data_file(const std::string& sub, const std::string& name) {
  const auto dirs = data_dirs();
  for (auto d = dirs.rbegin(); d != dirs.rend(); ++d) {  // expansions가 repositories보다 먼저
    const std::string path = *d + "/" + sub + "/" + name;
    if (std::filesystem::exists(path)) return path;
  }
  return {};
}

bool read_script_file(const std::string& name, std::string& code) {
  const std::string path = find_data_file("script", name);
  if (path.empty()) return false;
  std::ifstream f(path, std::ios::binary);
  if (!f) return false;
  std::stringstream ss;
  ss << f.rdbuf();
  code = ss.str();
  return true;
}

}  // namespace wxtest
