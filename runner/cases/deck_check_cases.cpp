// 덱 검증(formats/*.lua). 근거: 용어집 メインデッキ·ルリグデッキ·デッキ·ピース, 포맷 FAQ
#include <algorithm>
#include <filesystem>

#include <sqlite3.h>

#include "deck_check.h"
#include "test.h"

namespace {

wxtest::CardDb& db() {
  static wxtest::CardDb d;
  if (!d.is_open()) d.open(wxtest::data_dir() + "/wixoss.db");
  return d;
}

wxtest::DeckFile load(const char* name) {
  wxtest::DeckFile d;
  std::string err;
  wxtest::load_deck(wxtest::data_dir() + "/decks/" + name + ".json", db(), d, err);
  return d;
}

// 문제 목록에 이 말이 든 줄이 있는가
bool has(const wxtest::DeckCheck& r, const char* text) {
  return std::any_of(r.problems.begin(), r.problems.end(), [&](const std::string& p) { return p.find(text) != std::string::npos; });
}

// wixoss.db 사본에 sql을 적용한 임시 DB. 지우기 전에 CardDb를 닫아야 한다(Windows)
std::string patched_db(const char* file, const std::string& sql) {
  const std::string path = (std::filesystem::temp_directory_path() / file).string();
  std::error_code ec;
  std::filesystem::copy_file(wxtest::data_dir() + "/wixoss.db", path, std::filesystem::copy_options::overwrite_existing, ec);
  CHECK(!ec);
  sqlite3* db = nullptr;
  CHECK(sqlite3_open(path.c_str(), &db) == SQLITE_OK);
  CHECK(sqlite3_exec(db, sql.c_str(), nullptr, nullptr, nullptr) == SQLITE_OK);
  sqlite3_close(db);
  return path;
}

// 덱에서 cid를 모두 빼고 n장 넣는다
void put(std::vector<wx::Cid>& cards, wx::Cid cid, int n) {
  std::erase(cards, cid);
  cards.insert(cards.end(), n, cid);
}

}  // namespace

TEST_CASE("deck check: 테스트 덱은 자기 포맷에서 통과", "설계: 테스트 덱, 포맷 FAQ") {
  for (const char* name : {"WXDi-D01_ancient_surprise", "WDK09_blue_umr", "WDK-F03_tama", "WD01_white_hope", "WD02_hanayo", "WD19_nanashi", "WD03_piruluk", "WD04_midoriko", "WDK08_LoV", "WDK08_yuzuki"}) {
    const auto r = wxtest::check_deck(db(), load(name));
    for (const auto& p : r.problems) std::printf("    %s: %s\n", name, p.c_str());
    if (!r.error.empty()) std::printf("    %s: %s\n", name, r.error.c_str());
    CHECK(r.ok);
  }
}

TEST_CASE("deck check: 메인 덱 40장 정확히, 같은 이름 4장까지", "용어집: メインデッキ") {
  auto d = load("WDK09_blue_umr");
  d.main.pop_back();
  CHECK(has(wxtest::check_deck(db(), d), "40장이어야"));
  d = load("WDK09_blue_umr");
  d.main[0] = d.main[39];  // 다른 카드 한 장을 마지막 카드로 바꿔 5장 이상으로
  d.main[1] = d.main[39];
  d.main[2] = d.main[39];
  CHECK(has(wxtest::check_deck(db(), d), "4장까지"));
}

TEST_CASE("deck check: 라이프 버스트 20장까지", "용어집: メインデッキ") {
  auto d = load("WDK09_blue_umr");
  // LB 카드 하나로 LB 없는 카드 자리를 채워 21장 이상으로
  wx::Cid lb = 0;
  for (wx::Cid c : d.main)
    if (const auto* e = db().entry(c); e && e->life_burst) lb = c;
  int added = 0;
  for (wx::Cid& c : d.main)
    if (const auto* e = db().entry(c); e && !e->life_burst && added < 1) {
      c = lb;
      ++added;
    }
  CHECK(has(wxtest::check_deck(db(), d), "라이프 버스트"));
}

TEST_CASE("deck check: 루리그 덱 같은 이름 불가, 10장까지", "용어집: デッキ, ルリグデッキ") {
  auto d = load("WDK09_blue_umr");
  d.lrig.push_back(d.lrig.back());
  const auto r = wxtest::check_deck(db(), d);
  CHECK(has(r, "같은 이름을 넣을 수 없다"));
  CHECK(has(r, "10장까지"));
}

TEST_CASE("deck check: 레벨 0 루리그 3장이면 피스 2장까지 더해 12장", "용어집: ルリグデッキ, ピース") {
  // D01은 레벨 0 루리그 3장 + 피스 1장으로 11장이라 통과
  auto d = load("WXDi-D01_ancient_surprise");
  CHECK(d.lrig.size() == 11);
  CHECK(wxtest::check_deck(db(), d).ok);
  // 피스가 아닌 카드(레벨 1 이상 루리그)로 11장째를 채우면 10장 제한
  auto k = load("WDK09_blue_umr");
  for (wx::Cid c : load("WXDi-D01_ancient_surprise").lrig)
    if (const auto* e = db().entry(c); e && (e->type & wx::TYPE_LRIG) && e->level > 0) {
      k.lrig.push_back(c);
      break;
    }
  CHECK(k.lrig.size() == 11);
  CHECK(has(wxtest::check_deck(db(), k), "10장까지"));
}

TEST_CASE("deck check: 시작 루리그는 레벨 0 센터, 어시스트는 0장 또는 2장", "설계: 포맷과 덱 검증") {
  auto d = load("WXDi-D01_ancient_surprise");
  d.start_assists.pop_back();
  CHECK(has(wxtest::check_deck(db(), d), "1장 또는 3장"));
  d = load("WDK09_blue_umr");
  d.start_center = 0;
  CHECK(has(wxtest::check_deck(db(), d), "시작 센터 루리그를 정해야"));
}

TEST_CASE("deck check: 키 셀렉션 카드는 디바 셀렉션에서 못 쓴다, 올스타는 된다", "포맷 FAQ") {
  auto d = load("WDK09_blue_umr");
  d.format = "diva";
  CHECK(has(wxtest::check_deck(db(), d), "디바 셀렉션에서 쓸 수 없는 카드"));
  d.format = "allstar";
  CHECK(wxtest::check_deck(db(), d).ok);
}

TEST_CASE("deck check: 같은 이름은 alias(없으면 cid)로 판정, 일본어 이름이 없는 오리카도 센다", "용어집: メインデッキ, デッキ / 지시 2026-11-23 #1") {
  const auto base = load("WDK09_blue_umr");
  const wx::Cid a = base.main[0];
  wx::Cid b = 0;
  for (wx::Cid c : base.main)
    if (c != a && db().entry(c)->name_ja != db().entry(a)->name_ja) b = c;
  CHECK(b != 0);
  const wx::Cid lrig = base.lrig.back();
  const std::string ids = std::to_string(a) + "," + std::to_string(lrig);
  // 오리카처럼 ko 텍스트만 남긴다
  const std::string orica = patched_db(
      "wx_orica.db", "INSERT OR IGNORE INTO texts(cid, lang, name) SELECT cid, 'ko', name FROM texts WHERE lang='ja' AND cid IN (" +
                         ids + "); DELETE FROM texts WHERE lang='ja' AND cid IN (" + ids + ");");
  // b는 포맷 아이콘을 지운다. alias가 있으면 a의 아이콘으로 쓸 수 있다(포맷 FAQ: 「同名のカードであれば、以前のカードも使用できます」)
  const std::string no_icon = "UPDATE cards SET formats=0 WHERE cid=" + std::to_string(b) + ";";
  const std::string plain = patched_db("wx_noicon.db", no_icon);
  const std::string aliased = patched_db("wx_alias.db", no_icon + "UPDATE cards SET alias=" + std::to_string(a) + " WHERE cid=" + std::to_string(b));
  {
    wxtest::CardDb odb;
    CHECK(odb.open(orica));
    CHECK(odb.entry(a) && odb.entry(a)->name_ja.empty());
    auto d = base;
    put(d.main, a, 4);
    CHECK(!has(wxtest::check_deck(odb, d), "4장까지"));
    put(d.main, a, 5);
    CHECK(has(wxtest::check_deck(odb, d), "4장까지"));
    d = base;
    d.lrig.push_back(lrig);
    CHECK(has(wxtest::check_deck(odb, d), "같은 이름을 넣을 수 없다"));
  }
  {
    auto d = base;
    put(d.main, a, 3);
    put(d.main, b, 2);
    CHECK(!has(wxtest::check_deck(db(), d), "4장까지"));  // alias 없으면 다른 카드
    wxtest::CardDb adb;
    CHECK(adb.open(aliased));
    CHECK(adb.entry(b)->name_key() == a);
    CHECK(has(wxtest::check_deck(adb, d), "4장까지"));
    wxtest::CardDb pdb;
    CHECK(pdb.open(plain));
    CHECK(has(wxtest::check_deck(pdb, d), "쓸 수 없는 카드"));
    CHECK(!has(wxtest::check_deck(adb, d), "쓸 수 없는 카드"));
  }
  std::error_code ec;
  std::filesystem::remove(orica, ec);
  std::filesystem::remove(aliased, ec);
  std::filesystem::remove(plain, ec);
}
