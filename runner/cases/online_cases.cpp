// 온라인 대전: 같은 프로세스 안에서 방장·게스트를 127.0.0.1로 잇고 무작위로 끝까지 둔다.
// 게스트는 코어 없이 메시지 + UPDATE로 장을 만들므로, 게스트 차례마다 게스트 장이 방장 코어의 게스트 뷰와 같아야 한다.
#include <algorithm>
#include <random>

#include "online.h"
#include "test.h"

namespace {

std::vector<uint32_t> random_picks(const wxframe::Request& r, std::mt19937_64& rng) {
  if (r.type == WX_REQ_YES_NO) return {static_cast<uint32_t>(rng() % 2)};
  std::vector<uint32_t> vals;
  for (const auto& o : r.options) vals.push_back(o.value);
  std::shuffle(vals.begin(), vals.end(), rng);
  const uint32_t hi = std::min<uint32_t>(r.max, static_cast<uint32_t>(vals.size()));
  const uint32_t lo = std::min(r.min, hi);
  vals.resize(lo + static_cast<uint32_t>(rng() % (hi - lo + 1)));
  return vals;
}

}  // namespace

TEST_CASE("online: 방장·게스트가 127.0.0.1로 끝까지 두고, 게스트 장은 방장 코어의 게스트 뷰와 같다", "설계: 실행 위치(온라인)") {
  wxtest::CardDb db;
  CHECK(db.open(wxtest::data_dir() + "/expansions/official/wixoss.db"));
  std::string deck_json, err;
  CHECK(wxtest::read_deck_text(wxtest::data_dir() + "/decks/WDK09_blue_umr.json", deck_json));
  wxtest::DeckFile host_deck;
  CHECK(wxtest::load_deck(wxtest::data_dir() + "/decks/WXDi-D01_ancient_surprise.json", db, host_deck, err));

  for (uint64_t seed = 1; seed <= 3; ++seed) {
    wxframe::Game hg(db), gg(db);
    wxframe::OnlineHost host(db, hg);
    wxframe::OnlineGuest guest(db, gg);
    const uint16_t port = static_cast<uint16_t>(27911 + seed);
    CHECK(host.open(port, "방장", err, true));
    CHECK(guest.connect("127.0.0.1", port, "게스트", err));
    guest.send_deck(deck_json);
    auto pump = [&] {
      host.poll();
      guest.poll();
    };
    for (int i = 0; i < 2000 && !(host.can_start() && guest.deck_checked()); ++i) pump();
    CHECK(host.has_guest() && host.guest_name() == "게스트" && guest.host_name() == "방장");
    CHECK(host.can_start() && guest.deck_problems().empty());
    CHECK(host.start(host_deck, seed, err));

    std::mt19937_64 rng(seed);
    bool same = true;
    int guest_turns = 0, idle = 0;
    for (int step = 0; step < 200000 && !hg.ended(); ++step) {
      pump();
      const auto& hr = hg.request();
      if (hr && hr->player == 0) {
        const wxframe::Request copy = *hr;
        bool done = false;
        for (int a = 0; a < 300 && !done; ++a) done = hg.respond(random_picks(copy, rng));
        if (!done && copy.cancelable) hg.cancel();
        idle = 0;
      } else if (gg.request()) {
        // 게스트 차례: 게스트 장 == 방장 코어의 게스트 뷰
        same &= gg.model(1).make_update(hg.duel(), 1).empty();
        ++guest_turns;
        gg.respond(random_picks(*gg.request(), rng));
        idle = 0;
      } else if (++idle > 5000) {
        break;  // 막혔다
      }
    }
    for (int i = 0; i < 200; ++i) pump();  // 마지막 메시지까지
    if (!hg.ended()) std::printf("    seed %llu: 끝나지 않음\n", static_cast<unsigned long long>(seed));
    CHECK(hg.ended());
    CHECK(gg.ended() && gg.winner() == hg.winner());
    CHECK(guest_turns > 0);
    CHECK(same);
    CHECK(gg.model(1).make_update(hg.duel(), 1).empty());
    host.close();
    guest.close();
  }
}
