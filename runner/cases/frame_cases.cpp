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
    }
    if (!g.ended())
      std::printf("    seed %llu: steps %d, request %s hint %u\n", static_cast<unsigned long long>(seed), steps,
                  g.request() ? "있음" : "없음", g.request() ? g.request()->hint : 0);
    CHECK(g.ended());
    CHECK(!g.log(0).empty() && !g.log(1).empty());
    bool core_error = false;
    for (const auto& line : g.log(WX_VIEW_ALL)) core_error |= line.rfind("[코어]", 0) == 0;
    CHECK(!core_error);
  }
}
