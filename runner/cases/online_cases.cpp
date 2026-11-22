// 온라인 대전: 같은 프로세스 안에서 방장·게스트·관전자를 127.0.0.1로 잇는다.
// 게스트·관전자는 코어 없이 메시지 + UPDATE로 장을 만들므로, 그 장이 방장 코어의 해당 뷰와 같아야 한다.
#include <algorithm>
#include <functional>
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

wxtest::CardDb& db() {
  static wxtest::CardDb d;
  if (!d.is_open()) d.open(wxtest::data_dir() + "/expansions/official/wixoss.db");
  return d;
}

std::string deck_text(const char* name) {
  std::string t;
  wxtest::read_deck_text(wxtest::data_dir() + "/decks/" + name + ".json", t);
  return t;
}

// cond가 참이 될 때까지 돌린다
bool pump_until(const std::function<void()>& pump, const std::function<bool()>& cond, int limit = 3000) {
  for (int i = 0; i < limit; ++i) {
    if (cond()) return true;
    pump();
  }
  return cond();
}

}  // namespace

TEST_CASE("online: 방장·게스트가 끝까지 두고, 중간에 들어온 관전자까지 장이 방장 코어의 뷰와 같다", "설계: 실행 위치(온라인), 정보 공개") {
  std::string err;
  wxtest::DeckFile host_deck;
  CHECK(wxtest::load_deck(wxtest::data_dir() + "/decks/WXDi-D01_ancient_surprise.json", db(), host_deck, err));
  for (uint64_t seed = 1; seed <= 3; ++seed) {
    wxframe::Game hg(db()), gg(db()), sg(db());
    wxframe::OnlineHost host(db(), hg);
    wxframe::OnlineGuest guest(db(), gg), spec(db(), sg);
    const uint16_t port = static_cast<uint16_t>(27911 + seed);
    CHECK(host.open(port, "방장", "방", "", err, true, static_cast<uint16_t>(28911 + seed)));
    CHECK(guest.connect("127.0.0.1", port, "게스트", "", false, err));
    guest.send_deck(deck_text("WDK09_blue_umr"));
    auto pump = [&] {
      host.poll();
      guest.poll();
      spec.poll();
    };
    CHECK(pump_until(pump, [&] { return host.room().guest_deck_ok; }));
    CHECK(!host.can_start());  // 준비 전에는 시작할 수 없다
    guest.set_ready(true);
    CHECK(pump_until(pump, [&] { return host.can_start() && guest.ready(); }));
    CHECK(host.room().guest_name == "게스트" && guest.room().host_name == "방장");
    CHECK(host.start(host_deck, seed, err));

    std::mt19937_64 rng(seed);
    bool same = true, spec_joined = false;
    int guest_turns = 0, idle = 0, steps = 0;
    for (; steps < 200000 && !hg.ended(); ++steps) {
      pump();
      if (!spec_joined && guest_turns == 3) {  // 대전 중간에 관전자가 들어온다
        CHECK(spec.connect("127.0.0.1", port, "관전자", "", true, err));
        spec_joined = true;
      }
      const auto& hr = hg.request();
      if (hr && hr->player == 0) {
        const wxframe::Request copy = *hr;
        bool done = false;
        for (int a = 0; a < 300 && !done; ++a) done = hg.respond(random_picks(copy, rng));
        if (!done && copy.cancelable) hg.cancel();
        idle = 0;
      } else if (gg.request()) {
        same &= gg.model(1).make_update(hg.duel(), 1).empty();  // 게스트 장 == 방장 코어의 게스트 뷰
        ++guest_turns;
        gg.respond(random_picks(*gg.request(), rng));
        idle = 0;
      } else if (++idle > 5000) {
        break;
      }
    }
    pump_until(pump, [] { return false; }, 300);  // 마지막 메시지까지
    if (!hg.ended()) std::printf("    seed %llu: 끝나지 않음\n", static_cast<unsigned long long>(seed));
    CHECK(hg.ended());
    CHECK(gg.ended() && gg.winner() == hg.winner());
    CHECK(guest_turns > 3 && same);
    CHECK(gg.model(1).make_update(hg.duel(), 1).empty());
    // 관전자: 처음부터 따라잡아 공개 정보만 본다
    CHECK(spec.spectating() && sg.running() && sg.seat() == 2);
    CHECK(sg.ended() && sg.winner() == hg.winner());
    CHECK(sg.model(2).make_update(hg.duel(), 2).empty());
    CHECK(!sg.request());
    // 방으로 돌아가면 준비가 풀린다
    host.back_to_room();
    CHECK(pump_until(pump, [&] { return !gg.running() && !sg.running(); }));
    CHECK(!host.room().guest_ready && !host.can_start());
    host.close();
    guest.close();
    spec.close();
  }
}

TEST_CASE("online: 비밀번호·채팅·강퇴·관전 전환", "CyanPro 방 대기 화면") {
  std::string err;
  wxframe::Game hg(db()), g1(db()), g2(db()), g3(db());
  wxframe::OnlineHost host(db(), hg);
  wxframe::OnlineGuest a(db(), g1), b(db(), g2), c(db(), g3);
  auto pump = [&] {
    host.poll();
    a.poll();
    b.poll();
    c.poll();
  };
  CHECK(host.open(27950, "방장", "비밀방", "1234", err, true, 28950));
  CHECK(host.room().locked);
  // 비밀번호가 틀리면 들어오지 못한다
  CHECK(c.connect("127.0.0.1", 27950, "틀림", "0000", false, err));
  CHECK(pump_until(pump, [&] { return !c.connected() && !c.connecting(); }));
  CHECK(c.status.find("비밀번호") != std::string::npos);
  // 첫 사람은 대전자, 둘째는 자리가 차서 관전
  CHECK(a.connect("127.0.0.1", 27950, "에이", "1234", false, err));
  CHECK(pump_until(pump, [&] { return a.joined(); }));
  CHECK(b.connect("127.0.0.1", 27950, "비", "1234", false, err));
  CHECK(pump_until(pump, [&] { return b.joined(); }));
  CHECK(!a.spectating() && b.spectating());
  CHECK(pump_until(pump, [&] { return a.room().spectators.size() == 1; }));
  // 채팅은 모두에게
  a.chat("안녕");
  host.chat("어서 와");
  CHECK(pump_until(pump, [&] { return b.chat_log().size() == 2 && a.chat_log().size() == 2; }));
  // 방장 말은 바로, 게스트 말은 방장을 거쳐 퍼지므로 순서는 보지 않는다
  CHECK(std::any_of(b.chat_log().begin(), b.chat_log().end(), [](const auto& c) { return c.name == "에이" && c.text == "안녕"; }));
  CHECK(std::any_of(a.chat_log().begin(), a.chat_log().end(), [](const auto& c) { return c.name == "방장" && c.text == "어서 와"; }));
  CHECK(host.chat_log().size() == 2);
  // 대전자가 관전으로 가면 자리가 비고, 관전자가 대전자로 들어간다
  a.to_spectator();
  CHECK(pump_until(pump, [&] { return a.spectating() && host.room().guest_name.empty(); }));
  b.to_duelist();
  CHECK(pump_until(pump, [&] { return !b.spectating() && b.joined() && host.room().guest_name == "비"; }));
  // 강퇴
  host.kick_guest();
  CHECK(pump_until(pump, [&] { return !b.connected(); }));
  CHECK(b.status.find("내보냈다") != std::string::npos);
  CHECK(host.room().guest_name.empty());
  host.kick_spectator(0);
  CHECK(pump_until(pump, [&] { return !a.connected(); }));
  host.close();
}

TEST_CASE("online: LAN 방 찾기는 방 이름·방장·인원·잠김을 알려 준다", "CyanPro LAN 창") {
  std::string err;
  wxframe::Game hg(db());
  wxframe::OnlineHost host(db(), hg);
  CHECK(host.open(27960, "방장", "찾을 방", "pw", err, true, 28960));
  wxframe::LanFinder finder;
  CHECK(finder.search(err, 28960, {"127.0.0.1"}, true));
  CHECK(pump_until([&] { host.poll(); finder.poll(); }, [&] { return !finder.rooms().empty(); }));
  CHECK(finder.rooms().size() == 1);
  if (!finder.rooms().empty()) {
    const auto& r = finder.rooms()[0];
    CHECK(r.ip == "127.0.0.1" && r.port == 27960 && r.room_name == "찾을 방" && r.host_name == "방장");
    CHECK(r.players == 1 && r.locked && !r.in_duel);
  }
  host.close();
}
