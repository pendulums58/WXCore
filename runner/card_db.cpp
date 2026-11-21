#include "card_db.h"

#include <sqlite3.h>

#include <cctype>
#include <fstream>
#include <sstream>
#include <variant>

namespace wxtest {

namespace {

// ── 작은 JSON 파서(덱 파일·DB의 JSON 칸용). 문자열·정수·배열·객체만 ──

struct Json;
using JsonObj = std::vector<std::pair<std::string, Json>>;  // 파일 순서 유지
using JsonArr = std::vector<Json>;
struct Json {
  std::variant<std::nullptr_t, long long, std::string, JsonArr, JsonObj> v;
  const JsonObj* obj() const { return std::get_if<JsonObj>(&v); }
  const JsonArr* arr() const { return std::get_if<JsonArr>(&v); }
  const std::string* str() const { return std::get_if<std::string>(&v); }
  const long long* num() const { return std::get_if<long long>(&v); }
  const Json* get(const std::string& k) const {
    if (auto* o = obj())
      for (auto& [key, val] : *o)
        if (key == k) return &val;
    return nullptr;
  }
};

struct Parser {
  const std::string& s;
  size_t i = 0;
  bool ok = true;

  void ws() {
    while (i < s.size() && std::isspace(static_cast<unsigned char>(s[i]))) ++i;
  }
  bool eat(char c) {
    ws();
    if (i < s.size() && s[i] == c) {
      ++i;
      return true;
    }
    return false;
  }
  std::string string() {
    std::string out;
    if (!eat('"')) {
      ok = false;
      return out;
    }
    while (i < s.size() && s[i] != '"') {
      if (s[i] == '\\' && i + 1 < s.size()) {
        const char e = s[++i];
        if (e == 'n') out += '\n';
        else if (e == 'u') {  // BMP만
          const unsigned cp = static_cast<unsigned>(std::stoul(s.substr(i + 1, 4), nullptr, 16));
          i += 4;
          if (cp < 0x80) out += static_cast<char>(cp);
          else if (cp < 0x800) {
            out += static_cast<char>(0xC0 | (cp >> 6));
            out += static_cast<char>(0x80 | (cp & 0x3F));
          } else {
            out += static_cast<char>(0xE0 | (cp >> 12));
            out += static_cast<char>(0x80 | ((cp >> 6) & 0x3F));
            out += static_cast<char>(0x80 | (cp & 0x3F));
          }
        } else out += e;
        ++i;
      } else {
        out += s[i++];
      }
    }
    ++i;
    return out;
  }
  Json value() {
    ws();
    if (i >= s.size()) {
      ok = false;
      return {};
    }
    const char c = s[i];
    if (c == '"') return {string()};
    if (c == '{') {
      ++i;
      JsonObj o;
      if (eat('}')) return {o};
      do {
        std::string k = string();
        if (!eat(':')) ok = false;
        o.emplace_back(std::move(k), value());
      } while (ok && eat(','));
      if (!eat('}')) ok = false;
      return {o};
    }
    if (c == '[') {
      ++i;
      JsonArr a;
      if (eat(']')) return {a};
      do a.push_back(value());
      while (ok && eat(','));
      if (!eat(']')) ok = false;
      return {a};
    }
    if (c == '-' || std::isdigit(static_cast<unsigned char>(c))) {
      size_t n = 0;
      const long long v = std::stoll(s.substr(i), &n);
      i += n;
      return {v};
    }
    if (s.compare(i, 4, "null") == 0) {
      i += 4;
      return {};
    }
    ok = false;
    return {};
  }
};

bool parse_json(const std::string& text, Json& out) {
  Parser p{text};
  out = p.value();
  return p.ok;
}

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
  if (db_) sqlite3_close(db_);
}

bool CardDb::open(const std::string& path) {
  if (sqlite3_open_v2(path.c_str(), &db_, SQLITE_OPEN_READONLY, nullptr) != SQLITE_OK) {
    error_ = path + ": " + (db_ ? sqlite3_errmsg(db_) : "열 수 없음");
    if (db_) sqlite3_close(db_);
    db_ = nullptr;
    return false;
  }
  return true;
}

bool CardDb::read(wx::Cid cid, wx::CardData& out) {
  if (auto it = cache_.find(cid); it != cache_.end()) {
    out = it->second;
    return true;
  }
  if (!db_) return false;
  sqlite3_stmt* st = nullptr;
  sqlite3_prepare_v2(db_,
                     "SELECT kind, class, color, level, lim, power, cost_ena, grow_ena, limit_cond, guard, "
                     "life_burst, timing, alias, team, coin, cost_other FROM cards WHERE cid=?",
                     -1, &st, nullptr);
  sqlite3_bind_int64(st, 1, cid);
  bool found = false;
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
  return found;
}

wx::Cid CardDb::cid_of(const std::string& card_no) {
  if (!db_) return 0;
  sqlite3_stmt* st = nullptr;
  sqlite3_prepare_v2(db_, "SELECT cid FROM prints WHERE card_no=? LIMIT 1", -1, &st, nullptr);
  sqlite3_bind_text(st, 1, card_no.c_str(), -1, SQLITE_TRANSIENT);
  wx::Cid cid = 0;
  if (sqlite3_step(st) == SQLITE_ROW) cid = static_cast<wx::Cid>(sqlite3_column_int64(st, 0));
  sqlite3_finalize(st);
  return cid;
}

std::string CardDb::name_of(wx::Cid cid) {
  if (!db_) return {};
  sqlite3_stmt* st = nullptr;
  sqlite3_prepare_v2(db_, "SELECT name FROM texts WHERE cid=? AND lang='ja'", -1, &st, nullptr);
  sqlite3_bind_int64(st, 1, cid);
  std::string name;
  if (sqlite3_step(st) == SQLITE_ROW)
    if (auto* s = text_col(st, 0)) name = s;
  sqlite3_finalize(st);
  return name;
}

bool load_deck(const std::string& path, CardDb& db, DeckFile& out, std::string& error) {
  std::ifstream f(path, std::ios::binary);
  if (!f) {
    error = path + ": 열 수 없음";
    return false;
  }
  std::stringstream ss;
  ss << f.rdbuf();
  Json j;
  if (!parse_json(ss.str(), j) || !j.obj()) {
    error = path + ": JSON 형식 오류";
    return false;
  }
  auto cid = [&](const std::string& no) {
    const wx::Cid c = db.cid_of(no);
    if (!c && error.empty()) error = path + ": 모르는 카드 번호 " + no;
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

std::string data_dir() { return WX_DATA_DIR; }

bool read_script_file(const std::string& name, std::string& code) {
  std::ifstream f(data_dir() + "/expansions/official/script/" + name, std::ios::binary);
  if (!f) return false;
  std::stringstream ss;
  ss << f.rdbuf();
  code = ss.str();
  return true;
}

}  // namespace wxtest
