// 공개 C API만으로 돌리는 케이스. 프레임·서버가 보는 것과 같은 메시지를 검사한다.
#include <algorithm>
#include <cstring>
#include <string>
#include <vector>

#include "field_model.h"
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

TEST_CASE("api: 덱에서 정한 판본은 아는 뷰에만 MOVE·조회로 간다", "결정 2026-11-23: 대전 화면에도 판본") {
  Game g(3);
  std::vector<uint32_t> main;
  std::vector<uint16_t> prints;
  for (int i = 0; i < 40; ++i) {
    main.push_back(100 + i % 10);
    prints.push_back(static_cast<uint16_t>(1 + i % 3));
  }
  const uint32_t lrig[] = {1};
  const uint16_t lrig_print[] = {7};
  CHECK(wx_add_deck_prints(g.duel, 0, main.data(), prints.data(), main.size(), lrig, lrig_print, 1) == WX_OK);
  CHECK(wx_add_deck_prints(g.duel, 1, main.data(), nullptr, main.size(), lrig, nullptr, 1) == WX_OK);  // 없으면 1
  wx_start(g.duel);
  CHECK(g.until_main());
  // MOVE: ... u32 host @24, u8 face @28, u16 print @29
  const uint16_t p0_hand = 3;
  int mine = 0, hidden = 0, lrig7 = 0, other_lrig1 = 0;
  for (const Msg& m : split(g.log[WX_VIEW_P1]))
    if (m.type == WX_MSG_MOVE && m.u16(20) == p0_hand) mine += m.u16(29) >= 1 && m.u16(29) <= 3;
  for (const Msg& m : split(g.log[WX_VIEW_P2]))
    if (m.type == WX_MSG_MOVE && m.u16(20) == p0_hand) hidden += m.u16(29) == 0;
  for (const Msg& m : split(g.log[WX_VIEW_SPECTATOR]))
    if (m.type == WX_MSG_MOVE && m.u32(14) == 1) (m.u16(29) == 7 ? lrig7 : other_lrig1) += 1;
  CHECK(mine >= 5);
  CHECK(hidden >= 5);
  CHECK(lrig7 == 1 && other_lrig1 == 1);  // 오픈한 루리그: P1은 판본 7, P2는 기본 1
  // 조회: 그 뷰가 아는 카드만 판본이 있다
  uint32_t hand[16];
  const size_t n = wx_query_zone(g.duel, WX_VIEW_P1, p0_hand, hand, 16);
  CHECK(n >= 5);
  wx_card_info own{}, opp{};
  CHECK(wx_query_card(g.duel, WX_VIEW_P1, hand[0], &own) == WX_OK && own.print >= 1 && own.print <= 3);
  CHECK(wx_query_card(g.duel, WX_VIEW_P2, hand[0], &opp) == WX_OK && opp.print == 0);
}

namespace {
// c102: 내 다른 시그니에 【ランサー】(설명 번호 102×32+16)를 부여한다
const char* grant_script(void*, const char* name, size_t* len) {
  static const std::string src =
      "local s,id=GetID()\n"
      "function s.initial_effect(c)\n"
      "  local g=Effect.CreateEffect(c)\n"
      "  g:SetType(EFFECT_TYPE_SINGLE)\n"
      "  g:SetCode(EFFECT_LANCER)\n"
      "  g:SetDescription(id*32+16)\n"
      "  local e1=Effect.CreateEffect(c)\n"
      "  e1:SetType(EFFECT_TYPE_FIELD)\n"
      "  e1:SetCode(EFFECT_GRANT)\n"
      "  e1:SetRange(LOCATION_SZONE)\n"
      "  e1:SetTargetRange(LOCATION_SIGNI,0)\n"
      "  e1:SetTarget(function(e,x) return x~=e:GetHandler() end)\n"
      "  e1:SetLabelObject(g)\n"
      "  c:RegisterEffect(e1)\n"
      "end\n";
  if (std::strcmp(name, "c102.lua") != 0) return nullptr;
  *len = src.size();
  return src.c_str();
}
}  // namespace

TEST_CASE("api: 부여된 능력은 wx_query_granted로(설명 번호·키워드·부여한 카드), 인쇄 능력은 없다", "결정 2026-11-23: 정보 패널에 부여된 능력") {
  wx_duel_options o{};
  o.schema_version = WX_SCHEMA_VERSION;
  o.seed = 1;
  o.flags = WX_FLAG_TEST_MODE | WX_FLAG_ALWAYS_ASK;
  o.first_player = 0;
  o.card_reader = read_card;
  o.script_reader = grant_script;
  wx_duel* duel = nullptr;
  CHECK(wx_create_duel(&o, &duel) == WX_OK);
  uint16_t zl = 0xFFFF, zc = 0xFFFF;
  char name[64];
  uint8_t owner = 0;
  for (uint16_t z = 0; z < wx_zone_count(duel); ++z) {
    wx_query_zone_info(duel, z, name, sizeof name, &owner, nullptr);
    if (owner == 0 && std::strcmp(name, "signi_left") == 0) zl = z;
    if (owner == 0 && std::strcmp(name, "signi_center") == 0) zc = z;
  }
  uint32_t target = 0, giver = 0;
  CHECK(wx_test_add_card(duel, 101, 0, zl, &target) == WX_OK);
  CHECK(wx_test_add_card(duel, 102, 0, zc, &giver) == WX_OK);
  CHECK(wx_test_begin(duel, 0, WX_PHASE_MAIN, 0) == WX_OK);
  for (int i = 0; i < 20 && wx_process(duel) == WX_CONTINUE; ++i) {
  }
  wx_granted_info g[4]{};
  CHECK(wx_query_granted(duel, WX_VIEW_SPECTATOR, target, g, 4) == 1);
  CHECK(g[0].desc == 102 * 32 + 16 && g[0].keyword == WX_KW_LANCER && g[0].source_cid == 102);
  CHECK(wx_query_granted(duel, WX_VIEW_SPECTATOR, giver, g, 4) == 0);  // 인쇄 능력은 들어 있지 않다
  wx_card_info info{};
  CHECK(wx_query_card(duel, WX_VIEW_SPECTATOR, target, &info) == WX_OK && (info.keywords & WX_KW_LANCER));
  // 게스트·관전자: 메시지 + UPDATE로 같은 목록을 받는다
  wxframe::FieldModel m;
  std::vector<uint8_t> buf(wx_get_messages(duel, WX_VIEW_SPECTATOR, nullptr, 0));
  wx_get_messages(duel, WX_VIEW_SPECTATOR, buf.data(), buf.size());
  for (const Msg& msg : split(buf)) m.apply(msg.bytes.data(), msg.bytes.size());
  const std::vector<uint8_t> upd = m.make_update(duel, WX_VIEW_SPECTATOR);
  m.apply(upd.data(), upd.size());
  CHECK(m.granted(target).size() == 1 && m.granted(target)[0].desc == 102 * 32 + 16 && m.granted(giver).empty());
  CHECK(m.make_update(duel, WX_VIEW_SPECTATOR).empty());
  wx_destroy_duel(duel);
}

TEST_CASE("api: 선공을 정하면 바로 START(引き直し 요청보다 먼저)", "용어집: じゃんけんに勝ったプレイヤーは先攻, 결정 2026-11-23: 코인토스") {
  Game t(5);
  t.decks();
  CHECK(wx_start(t.duel) == WX_OK);
  bool start_seen = false, mulligan_after = false;
  for (int i = 0; i < 20 && !mulligan_after; ++i) {
    const int r = wx_process(t.duel);
    t.pull();
    for (const Msg& m : split(t.log[WX_VIEW_ALL])) {
      if (m.type == WX_MSG_START) start_seen = true;
      if (m.type == WX_MSG_REQUEST && m.u32(8) == WX_HINT_MULLIGAN) {
        mulligan_after = start_seen;
        break;
      }
    }
    if (r == WX_END) break;
    const Msg* req = t.last_request();
    if (!req) continue;
    if (req->u32(8) == WX_HINT_MULLIGAN) break;
    std::vector<uint32_t> picks;
    for (uint32_t k = 0; k < req->u32(12); ++k) picks.push_back(req->u32(22 + 4 * k));
    wx_set_response(t.duel, picks.data(), picks.size());
  }
  CHECK(mulligan_after);
  int starts = 0;
  for (const Msg& m : split(t.log[WX_VIEW_P1])) starts += m.type == WX_MSG_START;
  CHECK(starts == 1);
}
