#include "card_db.h"
#include "json.h"

#include <sqlite3.h>

#include <algorithm>
#include <cctype>
#include <filesystem>
#include <fstream>

#ifdef _WIN32
#define WIN32_LEAN_AND_MEAN
#define NOMINMAX
#include <windows.h>
#endif
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

// [1, 2, …] → ID 목록
std::vector<uint32_t> json_ids(const char* text) {
  std::vector<uint32_t> out;
  if (!text) return out;
  Json j;
  if (!parse_json(text, j) || !j.arr()) return out;
  for (const Json& x : *j.arr())
    if (auto* n = x.num()) out.push_back(static_cast<uint32_t>(*n));
  return out;
}

// [[系統, 種族], …] → 클래스 코드 목록
std::vector<uint32_t> json_classes(const char* text) {
  std::vector<uint32_t> out;
  if (!text) return out;
  Json j;
  if (!parse_json(text, j) || !j.arr()) return out;
  for (const Json& x : *j.arr()) {
    const JsonArr* pair = x.arr();
    if (pair && pair->size() == 2 && (*pair)[0].num() && (*pair)[1].num())
      out.push_back(wx::class_code(static_cast<uint32_t>(*(*pair)[0].num()), static_cast<uint32_t>(*(*pair)[1].num())));
  }
  return out;
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
  load_classes(db, path);
  // 나중에 연 DB가 앞선 것을 덮으므로 읽어 둔 것을 비운다
  cache_.clear();
  text_cache_.clear();
  desc_cache_.clear();
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
  desc_cache_.clear();
  all_.clear();
  all_index_.clear();
  name_formats_.clear();
  class_names_.clear();
  class_ids_.clear();
  class_consts_.clear();
  warnings_.clear();
}

void CardDb::load_classes(sqlite3* db, const std::string& path) {
  sqlite3_stmt* st = nullptr;
  if (sqlite3_prepare_v2(db, "SELECT kind, id, const, ja, ko FROM classes", -1, &st, nullptr) != SQLITE_OK) return;
  static const char* kPrefix[] = {"SYS_", "RACE_", "LRIG_"};
  while (sqlite3_step(st) == SQLITE_ROW) {
    const int kind = sqlite3_column_int(st, 0);
    const auto id = static_cast<uint32_t>(sqlite3_column_int64(st, 1));
    ClassName n;
    if (auto* t = text_col(st, 2)) n.konst = t;
    if (auto* t = text_col(st, 3)) n.ja = t;
    if (auto* t = text_col(st, 4)) n.ko = t;
    if (kind < 0 || kind > 2 || !id || id > 32767 || n.konst.empty() || n.ja.empty()) continue;
    const std::string label = path + ": " + kPrefix[kind] + n.konst + "(" + std::to_string(id) + ")";
    if (auto it = class_names_.find({kind, id}); it != class_names_.end()) {
      if (it->second.ja != n.ja || it->second.konst != n.konst)
        warnings_.push_back(label + " 이 ID는 이미 " + it->second.ja + "(" + it->second.konst + ")");
      continue;
    }
    if (auto it = class_consts_.find({kind, n.konst}); it != class_consts_.end()) {
      warnings_.push_back(label + " 같은 상수가 이미 ID " + std::to_string(it->second));
      continue;
    }
    class_ids_.emplace(std::make_pair(kind, n.ja), id);
    class_consts_[{kind, n.konst}] = id;
    class_names_[{kind, id}] = std::move(n);
  }
  sqlite3_finalize(st);
}

uint32_t CardDb::class_id(int kind, const std::string& ja) const {
  auto it = class_ids_.find({kind, ja});
  return it == class_ids_.end() ? 0 : it->second;
}

bool CardDb::parse_class(const std::string& name, uint32_t& code) const {
  static const std::string kSep = "\xEF\xBC\x9A";  // 「：」(U+FF1A)
  const auto pos = name.find(kSep);
  const uint32_t sys = class_id(kClassSys, name.substr(0, pos));
  const uint32_t race = pos == std::string::npos ? 0 : class_id(kClassRace, name.substr(pos + kSep.size()));
  if (!sys || (pos != std::string::npos && !race)) return false;
  code = wx::class_code(sys, race);
  return true;
}

std::string CardDb::class_name(uint32_t code) const {
  auto name = [&](int kind, uint32_t id) {
    auto it = class_names_.find({kind, id});
    if (it == class_names_.end()) return "?" + std::to_string(id);
    return it->second.ko.empty() ? it->second.ja : it->second.ko;
  };
  std::string s = name(kClassSys, wx::class_sys(code));
  if (wx::class_race(code)) s += "\xEF\xBC\x9A" + name(kClassRace, wx::class_race(code));
  return s;
}

std::string CardDb::lrig_type_name(uint32_t id) const {
  auto it = class_names_.find({kClassLrig, id});
  if (it == class_names_.end()) return "?" + std::to_string(id);
  return it->second.ko.empty() ? it->second.ja : it->second.ko;
}

std::string CardDb::classes_lua() const {
  static const char* kPrefix[] = {"SYS_", "RACE_", "LRIG_"};
  std::string s = "-- 카드 DB의 classes 표로 만든 상수(CardDb::classes_lua)\n";
  for (const auto& [key, n] : class_names_)
    s += std::string(kPrefix[key.first]) + n.konst + "=" + std::to_string(key.second) + "  -- " + n.ja + "\n";
  return s;
}

bool CardDb::read_script(const std::string& name, std::string& code) const {
  if (name == "classes.lua") {
    code = classes_lua();
    return true;
  }
  return read_script_file(name, code);
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
  if (!n && error_.empty()) error_ = "카드 DB(*.db)가 최상단·repositories/·expansions/ 어디에도 없음";
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
                     "SELECT type, class, color, level, lim, power, cost_ena, limit_cond, guard, "
                     "life_burst, timing, alias, team, coin, cost_other, lrig_type, limit_cost FROM cards WHERE cid=?",
                     -1, &st, nullptr);
  sqlite3_bind_int64(st, 1, cid);
  if (sqlite3_step(st) == SQLITE_ROW) {
    found = true;
    wx::CardData d;
    d.cid = cid;
    d.type = static_cast<uint32_t>(sqlite3_column_int64(st, 0));
    d.classes = json_classes(text_col(st, 1));
    d.lrig_types = json_ids(text_col(st, 15));
    d.limit_cost = sqlite3_column_int(st, 16);
    d.color = static_cast<uint8_t>(sqlite3_column_int(st, 2));
    d.level = sqlite3_column_int(st, 3);
    d.limit = sqlite3_column_int(st, 4);
    const int power = sqlite3_column_int(st, 5);
    d.power = power < 0 ? wx::kPowerInfinity : power;
    if (auto* s = text_col(st, 6)) d.cost_ena = s;
    d.limit_cond = json_ids(text_col(st, 7));
    d.guard = sqlite3_column_int(st, 8) != 0;
    d.life_burst = sqlite3_column_int(st, 9) != 0;
    d.timing = static_cast<uint32_t>(sqlite3_column_int(st, 10));
    d.alias = static_cast<wx::Cid>(sqlite3_column_int64(st, 11));
    d.teams = json_strings(text_col(st, 12));
    d.coin = sqlite3_column_int(st, 13);
    if (const char* other = text_col(st, 14)) {  // {"coin": 1}
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

// 이름은 texts, 본문·LB는 strings의 능력 줄·라이프 버스트를 이어 붙인다(종류마다 한국어 줄이 있으면 한국어)
CardDb::Text CardDb::text_of(wx::Cid cid) {
  if (auto it = text_cache_.find(cid); it != text_cache_.end()) return it->second;
  Text t;
  for (auto db = dbs_.rbegin(); db != dbs_.rend(); ++db) {
    sqlite3_stmt* st = nullptr;
    sqlite3_prepare_v2(*db,
                       "SELECT name FROM texts WHERE cid=? ORDER BY CASE lang WHEN 'ko' THEN 0 ELSE 1 END LIMIT 1",
                       -1, &st, nullptr);
    sqlite3_bind_int64(st, 1, cid);
    const bool found = sqlite3_step(st) == SQLITE_ROW;
    if (found)
      if (auto* s = text_col(st, 0)) t.name = s;
    sqlite3_finalize(st);
    if (!found) continue;
    std::string lines[3][2];  // [kind 0 능력 줄 / 2 라이프 버스트][ko, ja]
    sqlite3_prepare_v2(*db, "SELECT kind, lang, text FROM strings WHERE cid=? AND kind IN (0, 2) ORDER BY kind, idx", -1,
                       &st, nullptr);
    sqlite3_bind_int64(st, 1, cid);
    while (sqlite3_step(st) == SQLITE_ROW) {
      const int kind = sqlite3_column_int(st, 0);
      const char* lang = text_col(st, 1);
      std::string& dst = lines[kind][lang && std::string(lang) == "ko" ? 0 : 1];
      if (auto* s = text_col(st, 2)) dst += (dst.empty() ? "" : "\n") + std::string(s);
    }
    sqlite3_finalize(st);
    t.ability = lines[0][0].empty() ? lines[0][1] : lines[0][0];
    t.life_burst = lines[2][0].empty() ? lines[2][1] : lines[2][0];
    break;
  }
  text_cache_[cid] = t;
  return t;
}

std::string CardDb::desc_text(uint32_t desc) {
  if (!desc) return {};
  if (auto it = desc_cache_.find(desc); it != desc_cache_.end()) return it->second;
  // slot 0~15 = str, 16~30 = 능력 줄 0~14, 31 = 라이프 버스트
  const wx::Cid cid = desc / 32;
  const uint32_t slot = desc % 32;
  const int kind = slot < 16 ? 1 : slot < 31 ? 0 : 2;
  const int idx = slot < 16 ? static_cast<int>(slot) : slot < 31 ? static_cast<int>(slot - 16) : 0;
  std::string out;
  bool found = false;
  for (auto db = dbs_.rbegin(); db != dbs_.rend() && !found; ++db) {
    sqlite3_stmt* st = nullptr;
    // strings 표가 없는 옛 DB는 건너뛴다
    if (sqlite3_prepare_v2(*db,
                           "SELECT text FROM strings WHERE cid=? AND kind=? AND idx=? "
                           "ORDER BY CASE lang WHEN 'ko' THEN 0 ELSE 1 END LIMIT 1",
                           -1, &st, nullptr) != SQLITE_OK) {
      sqlite3_finalize(st);
      continue;
    }
    sqlite3_bind_int64(st, 1, cid);
    sqlite3_bind_int(st, 2, kind);
    sqlite3_bind_int(st, 3, idx);
    if (sqlite3_step(st) == SQLITE_ROW) {
      found = true;
      if (auto* s = text_col(st, 0)) out = s;
    }
    sqlite3_finalize(st);
  }
  desc_cache_[desc] = out;
  return out;
}

bool CardDb::fill(wx::Cid cid, wx_card_data* out) {
  wx::CardData d;
  if (!read(cid, d)) return false;
  auto join = [](const std::vector<std::string>& v) {
    std::string s;
    for (const auto& x : v) s += x + "\n";
    return s;
  };
  fill_ids_[0] = d.classes;
  fill_ids_[1] = d.lrig_types;
  fill_ids_[2] = d.limit_cond;
  fill_buf_[2] = join(d.teams);
  static thread_local std::string cost;
  cost = d.cost_ena;
  out->cid = cid;
  out->alias = d.alias;
  out->type = d.type;
  out->color = d.color;
  out->level = d.level;
  out->limit = d.limit;
  out->limit_cost = d.limit_cost;
  out->power = d.power;
  out->classes = fill_ids_[0].data();
  out->n_classes = fill_ids_[0].size();
  out->lrig_types = fill_ids_[1].data();
  out->n_lrig_types = fill_ids_[1].size();
  out->limit_cond = fill_ids_[2].data();
  out->n_limit_cond = fill_ids_[2].size();
  out->teams = fill_buf_[2].c_str();
  out->cost_ena = cost.c_str();
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
      "SELECT c.cid, c.type, c.class, c.color, c.level, c.lim, c.power, c.life_burst, c.alias, c.formats, "
      "  tj.name, tj.reading, tk.name, "
      "  (SELECT group_concat(s.text, char(10)) FROM strings s WHERE s.cid=c.cid AND s.kind IN (0, 2)), "
      "  c.lrig_type "
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
    e.type = static_cast<uint32_t>(sqlite3_column_int64(st, 1));
    if (e.type & (wx::TYPE_TOKEN | wx::TYPE_COIN | wx::TYPE_CRAFT)) continue;  // 덱에 넣지 않는다
    e.cid = static_cast<wx::Cid>(sqlite3_column_int64(st, 0));
    // 표시·검색용 이름: 시그니 클래스, 루리그 타입
    for (uint32_t code : json_classes(text_col(st, 2))) e.classes.push_back(class_name(code));
    e.lrig_types = json_ids(text_col(st, 14));
    for (uint32_t t : e.lrig_types) e.classes.push_back(lrig_type_name(t));
    e.color = static_cast<uint8_t>(sqlite3_column_int(st, 3));
    e.level = sqlite3_column_int(st, 4);
    e.limit = sqlite3_column_int(st, 5);
    const int power = sqlite3_column_int(st, 6);
    e.power = power < 0 ? wx::kPowerInfinity : power;
    e.life_burst = sqlite3_column_int(st, 7) != 0;
    e.alias = static_cast<wx::Cid>(sqlite3_column_int64(st, 8));
    e.formats = static_cast<uint32_t>(sqlite3_column_int(st, 9));
    e.name_ja = col(10);
    e.name = col(12).empty() ? e.name_ja : col(12);
    // 이름·읽기·클래스·텍스트(능력 줄·LB, 일본어·한국어)
    std::string search = e.name + "\n" + e.name_ja + "\n" + col(11) + "\n";
    for (const auto& c : e.classes) search += c + "\n";
    search += col(13);
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
    name_formats_[all_[i].name_key()] |= all_[i].formats;
  }
  return all_;
}

const CardEntry* CardDb::entry(wx::Cid cid) {
  all_cards();
  auto it = all_index_.find(cid);
  return it == all_index_.end() ? nullptr : &all_[it->second];
}

int CardDb::print_count(wx::Cid cid) {
  for (auto db = dbs_.rbegin(); db != dbs_.rend(); ++db) {  // 그 카드를 가진 가장 나중 DB
    sqlite3_stmt* st = nullptr;
    sqlite3_prepare_v2(*db, "SELECT COUNT(*) FROM prints WHERE cid=?", -1, &st, nullptr);
    sqlite3_bind_int64(st, 1, cid);
    const int n = sqlite3_step(st) == SQLITE_ROW ? sqlite3_column_int(st, 0) : 0;
    sqlite3_finalize(st);
    if (n) return n;
  }
  return 0;
}

bool CardDb::name_has_format(wx::Cid name_key, uint32_t bits) {
  all_cards();
  auto it = name_formats_.find(name_key);
  return it != name_formats_.end() && (it->second & bits);
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
  auto cid = [&](const Json& x) -> wx::Cid {
    const wx::Cid c = x.num() ? static_cast<wx::Cid>(*x.num()) : 0;
    if ((!c || !db.entry(c)) && error.empty()) error = path + ": 모르는 카드 cid " + std::to_string(c);
    return c;
  };
  if (auto* s = j.get("name"); s && s->str()) out.name = *s->str();
  if (auto* s = j.get("format"); s && s->str()) out.format = *s->str();
  // [[cid, 장수, idx], ...]. idx(판본)는 생략하면 1. 카드 번호로 된 옛 형식({"WD01-001": 1})은 읽지 않는다
  auto counts = [&](const char* key, std::vector<wx::Cid>& dst, std::vector<int>& idx) {
    const Json* o = j.get(key);
    if (o && o->obj()) {
      if (error.empty()) error = path + ": 옛 덱 형식(카드 번호)이다. 새 버전에서 덱을 다시 만들어야 한다";
      return;
    }
    if (!o || !o->arr()) return;
    for (const Json& e : *o->arr()) {
      const JsonArr* a = e.arr();
      if (!a || a->size() < 2 || !(*a)[1].num()) {
        if (error.empty()) error = path + ": " + key + " 항목은 [cid, 장수, idx]";
        continue;
      }
      const wx::Cid c = cid((*a)[0]);
      // 남이 보낸 덱일 수 있다: 말이 안 되는 장수는 받지 않는다
      const long long n = *(*a)[1].num();
      if (n < 0 || n > 99 || dst.size() > 200) {
        if (error.empty()) error = path + ": " + key + "의 장수가 잘못됨";
        return;
      }
      const int print = a->size() >= 3 && (*a)[2].num() && *(*a)[2].num() > 1 ? static_cast<int>(*(*a)[2].num()) : 1;
      for (long long k = 0; k < n; ++k) {
        dst.push_back(c);
        idx.push_back(print);
      }
    }
  };
  counts("lrig", out.lrig, out.lrig_idx);
  counts("main", out.main, out.main_idx);
  if (const Json* s = j.get("start_lrig")) {
    if (auto* c = s->get("center"); c && c->num()) out.start_center = cid(*c);
    if (auto* a = s->get("assist"); a && a->arr())
      for (const Json& x : *a->arr())
        if (out.start_assists.size() < 10) out.start_assists.push_back(cid(x));
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

bool save_deck(const std::string& path, const DeckFile& deck, std::string& error) {
  // [[cid, 장수, idx], ...] — (cid, 판본)마다 한 줄, 처음 나온 순서대로. idx 1은 생략
  auto counts = [&](bool lrig_deck) {
    const auto& cards = lrig_deck ? deck.lrig : deck.main;
    struct Row {
      wx::Cid cid;
      int idx, n;
    };
    std::vector<Row> list;
    for (size_t i = 0; i < cards.size(); ++i) {
      const int idx = deck.print_of(lrig_deck, i);
      auto it = std::find_if(list.begin(), list.end(), [&](const Row& x) { return x.cid == cards[i] && x.idx == idx; });
      if (it == list.end()) list.push_back({cards[i], idx, 1});
      else ++it->n;
    }
    std::string s = "[";
    for (size_t i = 0; i < list.size(); ++i) {
      s += std::string(i ? ", " : "") + "[" + std::to_string(list[i].cid) + ", " + std::to_string(list[i].n);
      if (list[i].idx > 1) s += ", " + std::to_string(list[i].idx);
      s += "]";
    }
    return s + "]";
  };
  std::string text = "{\n";
  text += "  \"name\": " + json_quote(deck.name) + ",\n";
  text += "  \"format\": " + json_quote(deck.format) + ",\n";
  text += "  \"lrig\": " + counts(true) + ",\n";
  text += "  \"main\": " + counts(false) + ",\n";
  text += "  \"start_lrig\": {\"center\": " + std::to_string(deck.start_center) + ", \"assist\": [";
  for (size_t i = 0; i < deck.start_assists.size(); ++i)
    text += (i ? ", " : "") + std::to_string(deck.start_assists[i]);
  text += "]}\n}\n";
  std::ofstream f(path, std::ios::binary);
  if (!f) {
    error = path + ": 쓸 수 없음";
    return false;
  }
  f << text;
  return static_cast<bool>(f);
}

wx::Cid card_no_cid(const std::string& card_no) {
  static const std::map<std::string, wx::Cid> table = [] {
    std::map<std::string, wx::Cid> m;
    std::string text;
    Json j;
    if (read_deck_text(data_dir() + "/tools/card_nos.json", text) && parse_json(text, j) && j.obj())
      for (const auto& [no, v] : *j.obj())
        if (const JsonArr* a = v.arr(); a && !a->empty() && (*a)[0].num()) m[no] = static_cast<wx::Cid>(*(*a)[0].num());
    return m;
  }();
  auto it = table.find(card_no);
  return it == table.end() ? 0 : it->second;
}

std::string data_dir() {
  // 배포판: exe 옆에 config/가 있으면 그 폴더. 개발: 빌드할 때의 소스 폴더
  static const std::string dir = [] {
    std::error_code ec;
#ifdef _WIN32
    wchar_t buf[MAX_PATH];
    GetModuleFileNameW(nullptr, buf, MAX_PATH);
    const std::filesystem::path exe = std::filesystem::path(buf).parent_path();
#else
    const std::filesystem::path exe = std::filesystem::read_symlink("/proc/self/exe", ec).parent_path();
#endif
    if (std::filesystem::is_directory(exe / "config", ec)) return exe.string();
    return std::string(WX_DATA_DIR);
  }();
  return dir;
}

std::vector<std::string> data_dirs() {
  // YGOPro처럼 최상단(cards.cdb 자리)과 expansions/ 바로 밑. 저장소는 repositories/<이름>/
  std::vector<std::string> out{data_dir()};
  std::vector<std::string> repos;
  std::error_code ec;
  for (const auto& e : std::filesystem::directory_iterator(data_dir() + "/repositories", ec))
    if (e.is_directory()) repos.push_back(e.path().string());
  std::sort(repos.begin(), repos.end());
  out.insert(out.end(), repos.begin(), repos.end());
  out.push_back(data_dir() + "/expansions");
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
