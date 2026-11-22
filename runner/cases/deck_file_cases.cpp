// 덱 에디터의 데이터 쪽: 카드 목록, 덱 파일 저장·다시 읽기
#include <filesystem>

#include <sqlite3.h>

#include "card_db.h"
#include "test.h"

TEST_CASE("deck file: 저장한 덱을 다시 읽으면 같은 덱(카드 번호도 그대로)", "CLAUDE.md: 덱 파일은 decks/*.json") {
  wxtest::CardDb db;
  CHECK(db.open(wxtest::data_dir() + "/wixoss.db"));
  for (const char* name : {"WXDi-D01_ancient_surprise", "WDK09_blue_umr"}) {
    wxtest::DeckFile a, b;
    std::string err;
    CHECK(wxtest::load_deck(wxtest::data_dir() + "/decks/" + name + ".json", db, a, err));
    const std::string path = (std::filesystem::temp_directory_path() / (std::string("wx_deck_") + name + ".json")).string();
    CHECK(wxtest::save_deck(path, db, a, err));
    CHECK(wxtest::load_deck(path, db, b, err));
    CHECK(a.name == b.name && a.format == b.format);
    CHECK(a.main == b.main && a.lrig == b.lrig);
    CHECK(a.start_center == b.start_center && a.start_assists == b.start_assists);
    CHECK(a.card_no == b.card_no);
    std::filesystem::remove(path);
  }
}

TEST_CASE("deck file: 카드 목록은 토큰·코인을 빼고, 포맷 아이콘·기본 번호를 단다", "용어집: デッキ, 포맷 FAQ") {
  wxtest::CardDb db;
  CHECK(db.open(wxtest::data_dir() + "/wixoss.db"));
  const auto& all = db.all_cards();
  CHECK(!all.empty());  // 전체 DB든 덱 카드만 넣은 DB(build_db.py --decks)든
  bool token = false;
  for (const auto& e : all) token |= (e.type & (wx::TYPE_TOKEN | wx::TYPE_COIN)) != 0;
  CHECK(!token);
  // WXDi-D01-001(디바 스타터)은 디바 아이콘, WDK09-005는 키 아이콘
  const wxtest::CardEntry* d01 = db.entry(db.cid_of("WXDi-D01-001"));
  const wxtest::CardEntry* k09 = db.entry(db.cid_of("WDK09-005"));
  CHECK(d01 && (d01->formats & wxtest::kFormatDiva));
  CHECK(k09 && (k09->formats & wxtest::kFormatKey));
  CHECK(d01 && !d01->card_no.empty() && !d01->name_ja.empty());
}

TEST_CASE("data: 나중에 연 DB가 같은 cid를 덮는다(expansions가 repositories보다 우선)", "결정 2026-11-22: repositories·expansions") {
  const std::string base = wxtest::data_dir() + "/wixoss.db";
  const std::string copy = (std::filesystem::temp_directory_path() / "wx_override.db").string();
  std::error_code ec;
  std::filesystem::copy_file(base, copy, std::filesystem::copy_options::overwrite_existing, ec);
  CHECK(!ec);
  wxtest::CardDb probe;
  CHECK(probe.open(base));
  const wx::Cid cid = probe.cid_of("WDK09-011");
  wx::CardData before;
  CHECK(probe.read(cid, before));
  {
    sqlite3* db = nullptr;
    CHECK(sqlite3_open(copy.c_str(), &db) == SQLITE_OK);
    const std::string sql = "UPDATE cards SET power=99999 WHERE cid=" + std::to_string(cid);
    CHECK(sqlite3_exec(db, sql.c_str(), nullptr, nullptr, nullptr) == SQLITE_OK);
    sqlite3_close(db);
  }
  {
    wxtest::CardDb db;
    CHECK(db.open(base) && db.open(copy));
    wx::CardData after;
    CHECK(db.read(cid, after) && after.power == 99999 && before.power != 99999);
    const wxtest::CardEntry* e = db.entry(cid);
    CHECK(e && e->power == 99999);
    CHECK(db.all_cards().size() == probe.all_cards().size());  // 같은 cid는 하나로
  }  // 지우기 전에 닫는다(Windows는 열린 파일을 못 지운다)
  CHECK(!wxtest::find_data_file("script", "c" + std::to_string(cid) + ".lua").empty());
  std::filesystem::remove(copy, ec);
}

TEST_CASE("data: 최상단 → repositories/*/ → expansions/ 바로 밑(YGOPro식, expansions 하위 폴더는 안 읽는다)", "결정 2026-11-22: YGOPro식 위치") {
  namespace fs = std::filesystem;
  const fs::path sub = fs::path(wxtest::data_dir()) / "expansions" / "_wx_test_sub";
  std::error_code ec;
  fs::create_directories(sub, ec);
  const auto dirs = wxtest::data_dirs();
  fs::remove(sub, ec);
  CHECK(dirs.size() >= 2);
  CHECK(dirs.front() == wxtest::data_dir());
  CHECK(dirs.back() == wxtest::data_dir() + "/expansions");
  for (size_t i = 1; i + 1 < dirs.size(); ++i)
    CHECK(fs::path(dirs[i]).parent_path().filename() == "repositories");
  // 공식 DB·스크립트는 최상단
  CHECK(fs::exists(fs::path(wxtest::data_dir()) / "wixoss.db"));
  CHECK(!wxtest::find_data_file("script", "utility.lua").empty());
}

TEST_CASE("data: 한글 폴더 안의 DB도 연다(경로는 UTF-8, utf8.manifest)", "버그: 한글 경로에서 unable to open database file") {
  namespace fs = std::filesystem;
  const fs::path dir = fs::temp_directory_path() / fs::path(u8"wx_위크로스_경로");
  std::error_code ec;
  fs::create_directories(dir, ec);
  CHECK(!ec);
  fs::copy_file(fs::path(wxtest::data_dir()) / "wixoss.db", dir / "wixoss.db", fs::copy_options::overwrite_existing, ec);
  CHECK(!ec);
  {
    wxtest::CardDb db;
    CHECK(db.open((dir / "wixoss.db").string()));  // open_all·data_dirs와 같은 변환
    CHECK(db.cid_of("WDK09-005") != 0);
  }
  fs::remove_all(dir, ec);
}
