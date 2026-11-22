// 프레임의 대전 래퍼(frame/game.cpp)를 화면 없이 돌린다. 요청 해석·응답·로그가 끝까지 가는지
#include <cstdio>
#include <random>

#include "game.h"
#include "test.h"

TEST_CASE("frame: 래퍼로 D01 대 WDK09를 끝까지(요청 해석·응답·되돌리기)", "CLAUDE.md: 작업 순서 4") {
  wxtest::CardDb db;
  CHECK(db.open(wxtest::data_dir() + "/expansions/official/wixoss.db"));
  wxtest::DeckFile d[2];
  std::string err;
  CHECK(wxtest::load_deck(wxtest::data_dir() + "/decks/WXDi-D01_ancient_surprise.json", db, d[0], err));
  CHECK(wxtest::load_deck(wxtest::data_dir() + "/decks/WDK09_blue_umr.json", db, d[1], err));
  for (uint64_t seed = 1; seed <= 5; ++seed) {
    wxframe::Game g(db);
    CHECK(g.start(d[0], d[1], seed, true, err));
    bool model_ok = true;
    std::mt19937_64 rng(seed);
    int steps = 0, undos = 0;
    while (!g.ended() && g.request() && steps++ < 5000) {
      const auto& r = *g.request();
      if (steps % 97 == 0 && g.undo()) {
        ++undos;
        continue;
      }
      // 무작위로 고르고, 검증에서 거부되면(에나 지불 등) 다시. 확정 전이면 가끔 취소
      const wxframe::Request copy = r;
      bool done = false;
      for (int attempt = 0; attempt < 300 && !done; ++attempt) {
        std::vector<uint32_t> picks;
        if (copy.type == WX_REQ_YES_NO) {
          picks = {static_cast<uint32_t>(rng() % 2)};
        } else {
          std::vector<uint32_t> vals;
          for (const auto& o : copy.options) vals.push_back(o.value);
          std::shuffle(vals.begin(), vals.end(), rng);
          const uint32_t hi = std::min<uint32_t>(copy.max, static_cast<uint32_t>(vals.size()));
          const uint32_t lo = std::min(copy.min, hi);
          vals.resize(lo + static_cast<uint32_t>(rng() % (hi - lo + 1)));
          picks = vals;
        }
        done = g.respond(picks);
      }
      if (!done && !(copy.cancelable && g.cancel())) break;
      // 장 모델: UPDATE까지 반영하면 코어 조회와 같다(다시 비교하면 고칠 게 없다)
      for (int v = 0; v < 3; ++v) model_ok &= g.model(v).make_update(g.duel(), static_cast<uint8_t>(v)).empty();
    }
    if (!g.ended())
      std::printf("    seed %llu: steps %d, request %s hint %u\n", static_cast<unsigned long long>(seed), steps,
                  g.request() ? "있음" : "없음", g.request() ? g.request()->hint : 0);
    CHECK(g.ended());
    CHECK(model_ok);
    // 메시지만으로 재구성한 존이 틀리는 건 순서가 메시지에 없는 덱뿐이어야 한다(「덱 위치는 메시지에 싣지 않는다」 결정)
    for (const auto& [zone, n] : g.zone_fixes()) {
      if (zone != "main_deck") std::printf("    seed %llu: 존 %s를 UPDATE로 %d번 고침\n", static_cast<unsigned long long>(seed), zone.c_str(), n);
      CHECK(zone == "main_deck");
    }
    CHECK(!g.log(0).empty() && !g.log(1).empty());
    bool core_error = false;
    for (const auto& line : g.log(WX_VIEW_ALL)) core_error |= line.kind == wxframe::LogLine::Error;
    CHECK(!core_error);
    // 읽는 로그: 내 드로는 카드 이름이 있고, 상대 드로는 모르는 채로 찍힌다(덱 아래에 공개해 둔 카드를 뽑으면 이름이 보일 수 있다).
    // 모르는 카드가 이어지는 일(라이프 클로스 7장 등)은 ×N으로 묶인다
    for (int v = 0; v < 2; ++v) {
      bool my_draw_named = false, opp_draw_hidden = false, grouped = false;
      for (const auto& l : g.log(v)) {
        grouped |= l.count > 1;
        if (l.text != "드로") continue;
        if (l.who == v) my_draw_named |= l.cid != 0;
        else opp_draw_hidden |= l.cid == 0;
      }
      CHECK(my_draw_named);
      CHECK(opp_draw_hidden);
      CHECK(grouped);
    }
  }
}
