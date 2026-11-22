// 덱 에디터의 데이터 쪽: 카드 목록, 덱 파일 저장·다시 읽기
#include <filesystem>

#include "card_db.h"
#include "test.h"

TEST_CASE("deck file: 저장한 덱을 다시 읽으면 같은 덱(카드 번호도 그대로)", "CLAUDE.md: 덱 파일은 decks/*.json") {
  wxtest::CardDb db;
  CHECK(db.open(wxtest::data_dir() + "/expansions/official/wixoss.db"));
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
  CHECK(db.open(wxtest::data_dir() + "/expansions/official/wixoss.db"));
  const auto& all = db.all_cards();
  CHECK(all.size() > 6000);
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
