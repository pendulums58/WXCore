// 공개 C API만으로 돌리는 케이스. 프레임·서버가 보는 것과 같은 메시지를 검사한다.
#include <algorithm>
#include <cstring>
#include <string>
#include <vector>

#include "test.h"
#include "wx_api.h"

namespace {

int read_card(void*, uint32_t cid, wx_card_data* out) {
  static const uint32_t lrig_types[] = {1};  // タマ
  if (cid == 1) {  // 레벨 0 루리그
    out->cid = 1;
    out->type = 1;  // TYPE_LRIG
    out->color = 1;
    out->lrig_types = lrig_types;
    out->n_lrig_types = 1;
    return 1;
  }
  if (cid >= 100 && cid < 110) {
    out->cid = cid;
    out->type = 2;  // TYPE_SIGNI
    out->color = 1;
    out->level = 1;
    out->power = 1000 * static_cast<int32_t>(cid - 99);
    return 1;
  }
  return 0;
}

struct Msg {
  uint16_t type;
  std::vector<uint8_t> bytes;  // size 필드부터
  uint32_t u32(size_t at) const {
    uint32_t v = 0;
    for (int i = 0; i < 4; ++i) v |= static_cast<uint32_t>(bytes[at + i]) << (8 * i);
    return v;
  }
  uint16_t u16(size_t at) const { return static_cast<uint16_t>(bytes[at] | (bytes[at + 1] << 8)); }
};

std::vector<Msg> split(const std::vector<uint8_t>& buf) {
  std::vector<Msg> out;
  size_t pos = 0;
  while (pos + 6 <= buf.size()) {
    uint32_t size = 0;
    for (int i = 0; i < 4; ++i) size |= static_cast<uint32_t>(buf[pos + i]) << (8 * i);
    Msg m;
    m.bytes.assign(buf.begin() + static_cast<std::ptrdiff_t>(pos),
                   buf.begin() + static_cast<std::ptrdiff_t>(pos + 4 + size));
    m.type = m.u16(4);
    out.push_back(std::move(m));
    pos += 4 + size;
  }
  return out;
}

struct Game {
  wx_duel* duel = nullptr;
  std::vector<uint8_t> log[4];  // 뷰별로 받은 전체 바이트

  explicit Game(uint64_t seed, uint32_t flags = WX_FLAG_ALWAYS_ASK) {
    wx_duel_options o{};
    o.schema_version = WX_SCHEMA_VERSION;
    o.seed = seed;
    o.flags = flags;
    o.first_player = 0;
    o.card_reader = read_card;
    wx_create_duel(&o, &duel);
  }
  ~Game() { wx_destroy_duel(duel); }

  void pull() {
    for (uint8_t v = 0; v < 4; ++v) {
      std::vector<uint8_t> buf(wx_get_messages(duel, v, nullptr, 0));
      if (buf.empty()) continue;
      wx_get_messages(duel, v, buf.data(), buf.size());
      log[v].insert(log[v].end(), buf.begin(), buf.end());
    }
  }

  void decks() {
    std::vector<uint32_t> main;
    for (int i = 0; i < 40; ++i) main.push_back(100 + i % 10);
    const uint32_t lrig[] = {1};
    wx_add_deck(duel, 0, main.data(), main.size(), lrig, 1);
    wx_add_deck(duel, 1, main.data(), main.size(), lrig, 1);
  }

  // 마지막 요청(전부 뷰 기준)을 찾는다
  const Msg* last_request() {
    static Msg m;
    auto msgs = split(log[WX_VIEW_ALL]);
    for (auto it = msgs.rbegin(); it != msgs.rend(); ++it)
      if (it->type == WX_MSG_REQUEST) {
        m = *it;
        return &m;
      }
    return nullptr;
  }

  // 요청이 그 힌트가 될 때까지 최소 응답으로 진행
  bool until_main() {
    for (int i = 0; i < 100; ++i) {
      const int r = wx_process(duel);
      pull();
      if (r == WX_END) return false;
      const Msg* req = last_request();
      if (!req) continue;
      const uint8_t type = req->bytes[6];
      const uint32_t mn = req->u32(12);
      if (type == WX_REQ_SELECT_ACTION) return true;
      std::vector<uint32_t> picks;
      if (type == WX_REQ_YES_NO) picks = {0};
      for (uint32_t k = 0; k < mn; ++k) picks.push_back(req->u32(22 + 4 * k));
      wx_set_response(duel, picks.data(), picks.size());
    }
    return false;
  }
};

}  // namespace

TEST_CASE("api: 스키마 버전이 다르면 생성 거부", "설계: 스키마 + 버전 협상") {
  wx_duel_options o{};
  o.schema_version = WX_SCHEMA_VERSION + 1;
  wx_duel* d = nullptr;
  CHECK(wx_create_duel(&o, &d) == WX_ERR_VERSION);
  CHECK(d == nullptr);
}

TEST_CASE("api: 테스트 모드 명령은 플래그 없이 거부", "CLAUDE.md: 코어 규칙") {
  Game g(1);
  CHECK(wx_test_add_card(g.duel, 100, 0, 0, nullptr) == WX_ERR_TEST_MODE);
  CHECK(wx_test_begin(g.duel, 0, 0x10, 0) == WX_ERR_TEST_MODE);
  Game t(1, WX_FLAG_TEST_MODE);
  uint32_t h = 0;
  CHECK(wx_test_add_card(t.duel, 100, 0, 0, &h) == WX_OK && h != 0);
}

TEST_CASE("api: 비공개 카드는 모르는 뷰에 cid 0", "설계: 메시지 가시성") {
  Game g(3);
  g.decks();
  wx_start(g.duel);
  CHECK(g.until_main());
  // 드로(덱 → 패) 이동을 뷰별로 센다. 존 번호: p0 패=3, p1 패=17+3
  auto count_hand_moves = [&](int view, uint16_t hand_zone, bool with_cid) {
    int n = 0;
    for (const Msg& m : split(g.log[view]))
      if (m.type == WX_MSG_MOVE && m.u16(20) == hand_zone && (m.u32(14) != 0) == with_cid) ++n;
    return n;
  };
  const uint16_t p0_hand = 3;
  CHECK(count_hand_moves(WX_VIEW_P1, p0_hand, true) >= 5);
  CHECK(count_hand_moves(WX_VIEW_P2, p0_hand, true) == 0);
  CHECK(count_hand_moves(WX_VIEW_P2, p0_hand, false) >= 5);
  CHECK(count_hand_moves(WX_VIEW_SPECTATOR, p0_hand, true) == 0);
  CHECK(count_hand_moves(WX_VIEW_ALL, p0_hand, true) >= 5);
  // 오픈한 루리그는 모두에게 보인다
  int lrig_seen = 0;
  for (const Msg& m : split(g.log[WX_VIEW_SPECTATOR]))
    if (m.type == WX_MSG_MOVE && m.u32(14) == 1) ++lrig_seen;
  CHECK(lrig_seen == 2);
}

TEST_CASE("api: 요청은 고르는 사람에게만, 나머지는 WAITING", "설계: 정보 공개") {
  Game g(3);
  g.decks();
  wx_start(g.duel);
  CHECK(g.until_main());
  for (const Msg& m : split(g.log[WX_VIEW_SPECTATOR])) CHECK(m.type != WX_MSG_REQUEST);
  bool waiting = false;
  for (const Msg& m : split(g.log[WX_VIEW_SPECTATOR])) waiting |= m.type == WX_MSG_WAITING;
  CHECK(waiting);
}

TEST_CASE("api: 셔플하면 덱 카드 handle이 새로 나온다", "설계: 카드 인지 기록") {
  Game g(3);
  g.decks();
  std::vector<uint32_t> before;
  g.pull();
  for (const Msg& m : split(g.log[WX_VIEW_ALL]))
    if (m.type == WX_MSG_MOVE && m.u16(20) == 0) before.push_back(m.u32(10));  // p0 덱으로 들어간 카드
  wx_start(g.duel);
  wx_process(g.duel);
  g.pull();
  bool found = false;
  for (const Msg& m : split(g.log[WX_VIEW_P2]))
    if (m.type == WX_MSG_SHUFFLE && m.u16(6) == 0) {
      found = true;
      const uint16_t n = m.u16(8);
      for (uint16_t i = 0; i < n; ++i) {
        const uint32_t h = m.u32(10 + 4 * i);
        CHECK(std::find(before.begin(), before.end(), h) == before.end());
      }
    }
  CHECK(found);
}

TEST_CASE("api: 틀린 응답은 거부하고 RETRY를 보낸다", "설계: propose → validate") {
  Game g(3);
  g.decks();
  wx_start(g.duel);
  wx_process(g.duel);
  g.pull();
  const uint32_t bogus = 0xFFFFFF;
  CHECK(wx_set_response(g.duel, &bogus, 1) == WX_ERR_INVALID);
  g.pull();
  bool retry = false;
  for (const Msg& m : split(g.log[WX_VIEW_P1])) retry |= m.type == WX_MSG_RETRY;
  CHECK(retry);
  CHECK(wx_process(g.duel) == WX_NEED_RESPONSE);  // 같은 요청을 다시 기다린다
}

TEST_CASE("api: 같은 시드·덱·응답이면 메시지 바이트가 같다", "설계: 결정론, 리플레이") {
  Game a(42), b(42);
  a.decks();
  b.decks();
  wx_start(a.duel);
  wx_start(b.duel);
  CHECK(a.until_main() && b.until_main());
  CHECK(a.log[WX_VIEW_ALL] == b.log[WX_VIEW_ALL]);
  CHECK(!a.log[WX_VIEW_ALL].empty());
}

TEST_CASE("api: 덤프는 사람이 읽는 한 줄", "설계: 메시지 디버그 덤프") {
  Game g(3);
  g.decks();
  g.pull();
  auto msgs = split(g.log[WX_VIEW_ALL]);
  CHECK(msgs.size() > 1 && msgs[0].type == WX_MSG_ZONES);
  char out[256];
  const Msg& mv = msgs[1];
  wx_dump_message(mv.bytes.data(), mv.bytes.size(), out, sizeof out);
  CHECK(std::strncmp(out, "MOVE", 4) == 0);
}

TEST_CASE("api: 되돌리면 RESET 뒤에 그 요청까지의 메시지를 똑같이 다시 보낸다", "설계: 테스트 모드, 결정론") {
  Game g(9, WX_FLAG_TEST_MODE | WX_FLAG_ALWAYS_ASK);
  g.decks();
  wx_start(g.duel);
  CHECK(wx_process(g.duel) == WX_NEED_RESPONSE);
  g.pull();
  std::vector<uint8_t> before[4];
  for (int v = 0; v < 4; ++v) before[v] = g.log[v];
  const uint32_t none = 0;
  CHECK(wx_set_response(g.duel, &none, 0) == WX_OK);
  wx_process(g.duel);
  g.pull();
  for (auto& l : g.log) l.clear();
  CHECK(wx_test_undo(g.duel) == WX_OK);
  g.pull();
  for (int v = 0; v < 4; ++v) {
    auto msgs = split(g.log[v]);
    CHECK(!msgs.empty() && msgs[0].type == WX_MSG_RESET);
    const std::vector<uint8_t> rest(g.log[v].begin() + 6, g.log[v].end());
    CHECK(rest == before[v]);
  }
  CHECK(wx_process(g.duel) == WX_NEED_RESPONSE);
}

TEST_CASE("api: 상태 조작·되돌리기는 테스트 모드에서만", "CLAUDE.md: 코어 규칙") {
  Game g(1);
  CHECK(wx_test_move_card(g.duel, 1, 0, 0, nullptr) == WX_ERR_TEST_MODE);
  CHECK(wx_test_set_power(g.duel, 1, 1000) == WX_ERR_TEST_MODE);
  CHECK(wx_test_undo(g.duel) == WX_ERR_TEST_MODE);
  Game t(1, WX_FLAG_TEST_MODE);
  uint32_t h = 0, moved = 0;
  CHECK(wx_test_add_card(t.duel, 100, 0, 0, &h) == WX_OK);
  CHECK(wx_test_set_power(t.duel, h, 1000) == WX_OK);
  CHECK(wx_test_move_card(t.duel, h, 3, 0, &moved) == WX_OK && moved != 0 && moved != h);  // 덱 → 패: 새 객체
  CHECK(wx_test_set_power(t.duel, 0xFFFFFF, 1000) == WX_ERR_ARGS);
  CHECK(wx_test_undo(t.duel) == WX_ERR_STATE);  // 응답이 없다
}


TEST_CASE("api: 카드 조회는 효과를 반영한 값, 모르는 뷰에는 cid 0", "설계: 메시지 가시성, 효과 모델") {
  Game t(1, WX_FLAG_TEST_MODE);
  uint32_t signi = 0, hidden = 0;
  wx_zone_count(t.duel);
  // 존 번호: p0 시그니 존은 이름으로 찾는다
  uint16_t z_signi = 0xFFFF, z_hand1 = 0xFFFF;
  char name[64];
  uint8_t owner = 0;
  for (uint16_t z = 0; z < wx_zone_count(t.duel); ++z) {
    wx_query_zone_info(t.duel, z, name, sizeof name, &owner, nullptr);
    if (owner == 0 && std::strcmp(name, "signi_center") == 0) z_signi = z;
    if (owner == 1 && std::strcmp(name, "hand") == 0) z_hand1 = z;
  }
  CHECK(z_signi != 0xFFFF && z_hand1 != 0xFFFF);
  CHECK(wx_test_add_card(t.duel, 101, 0, z_signi, &signi) == WX_OK);
  CHECK(wx_test_add_card(t.duel, 102, 1, z_hand1, &hidden) == WX_OK);
  CHECK(wx_test_set_power(t.duel, signi, 7777) == WX_OK);
  wx_card_info info{};
  CHECK(wx_query_card(t.duel, WX_VIEW_SPECTATOR, signi, &info) == WX_OK);
  CHECK(info.known && info.cid == 101 && info.power == 7777 && info.level == 1);
  CHECK(wx_query_card(t.duel, WX_VIEW_P1, hidden, &info) == WX_OK);
  CHECK(!info.known && info.cid == 0 && info.owner == 1);
  CHECK(wx_query_card(t.duel, WX_VIEW_P2, hidden, &info) == WX_OK);
  CHECK(info.known && info.cid == 102);
  uint32_t buf[8];
  CHECK(wx_query_zone(t.duel, WX_VIEW_P1, z_hand1, buf, 8) == 1 && buf[0] == hidden);
  wx_game_info g{};
  CHECK(wx_query_game(t.duel, &g) == WX_OK && g.winner == 0xFF && !g.ended);
}
