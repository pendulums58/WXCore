// 뷰별 메시지의 정보 공개(점검 2026-11-24 #1)
#include <algorithm>
#include <string>
#include <vector>

#include "fixture.h"
#include "test.h"
#include "wx_api.h"

namespace {

uint32_t u32(const std::vector<uint8_t>& b, size_t at) {
  uint32_t v = 0;
  for (int i = 0; i < 4; ++i) v |= static_cast<uint32_t>(b[at + i]) << (8 * i);
  return v;
}

// 그 뷰에 쌓인 메시지 가운데 종류가 type인 것(앞 6바이트 포함)
std::vector<std::vector<uint8_t>> take(wx::Duel& d, int view, uint16_t type) {
  std::vector<std::vector<uint8_t>> out;
  const auto buf = d.take_messages(view);
  for (size_t pos = 0; pos + 6 <= buf.size();) {
    const size_t len = 4 + u32(buf, pos);
    if ((buf[pos + 4] | (buf[pos + 5] << 8)) == type)
      out.emplace_back(buf.begin() + static_cast<std::ptrdiff_t>(pos), buf.begin() + static_cast<std::ptrdiff_t>(pos + len));
    pos += len;
  }
  return out;
}

void clear(wx::Duel& d) {
  for (int v = 0; v < 4; ++v) d.take_messages(v);
}

// 패에 있을 때 자기 메인 페이즈 개시에 발동하는 카드
const char* kHandTrigger = R"(
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
  e1:SetDescription(id*32+16)
  e1:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e1:SetRange(LOCATION_HAND)
  e1:SetOperation(function(e,tp) end)
  c:RegisterEffect(e1)
end)";

void setup(wxtest::Fixture& f, const char* script) {
  f.lrig(1);
  f.signi(100, 1000);
  f.signi(300, 1000);
  f.script(300, script);
  f.start();
  f.put(1, 0, "lrig_center");
  f.put(1, 1, "lrig_center");
  f.fill(100, 0, "main_deck", 10);
  f.fill(100, 1, "main_deck", 10);
}

}  // namespace

TEST_CASE("visibility: 비공개 카드의 발동은 모르는 쪽에 설명 번호(cid)를 보내지 않고, 안 쓰면 알리지 않는다", "AGENTS.md: 코어 규칙(비공개 카드는 cid 0)") {
  for (uint32_t yes : {0u, 1u}) {
    wxtest::Fixture f;
    setup(f, kHandTrigger);
    f.put(300, 0, "hand");
    f.session->command([](wx::Duel& d) { d.test_begin(0, wx::PHASE_ATTACK); });
    CHECK(f.until(wx::HINT_USE_TRIGGER));
    clear(f.d());
    CHECK(f.answer({yes}));
    f.d().process();
    for (int v = 0; v < 4; ++v) {
      const auto m = take(f.d(), v, WX_MSG_TRIGGER);
      CHECK(m.size() == yes);
      if (m.size() != 1) continue;
      const uint32_t desc = u32(m[0], 11);  // 6 + u8 + u32
      CHECK(desc == (v == 0 || v == WX_VIEW_ALL ? 300u * 32 + 16 : 0u));
    }
  }
}

TEST_CASE("visibility: 공개한 카드는 관전자에게도 보인다", "설계: 정보 공개(관전은 공개 정보)") {
  wxtest::Fixture f;
  setup(f, "");
  const auto c = f.put(100, 0, "hand");
  clear(f.d());
  f.session->command([&](wx::Duel& d) { d.reveal({c}); });
  for (int v = 0; v < 4; ++v) {
    const auto m = take(f.d(), v, WX_MSG_REVEAL);
    CHECK(m.size() == 1 && u32(m[0], 10) == 100);
  }
}

TEST_CASE("visibility: 섞어서 덱 아래에 놓으면 옮길 때의 번호로 순서를 알 수 없다", "점검 2026-11-24 #1-2") {
  wxtest::Fixture f;
  setup(f, "");
  std::vector<wx::CardIdx> cs;
  for (int i = 0; i < 4; ++i) cs.push_back(f.put(100, 0, "main_deck"));
  std::vector<wx::ObjId> before;
  f.session->command([&](wx::Duel& d) {
    const auto deck = d.state.zones.find(0, wx::ZoneKind::MainDeck);
    for (wx::CardIdx c : cs) {
      d.state.move(c, deck, wx::Pos::Bottom);
      d.state.cards.get(c).known_by = 0b11;
      before.push_back(d.state.cards.get(c).oid);
    }
    d.state.shuffle_bottom(deck, cs.size());
  });
  for (size_t i = 0; i < cs.size(); ++i) {
    const auto& card = f.d().state.cards.get(cs[i]);
    CHECK(card.oid != before[i] && card.known_by == 0);
  }
  CHECK(f.count(0, "main_deck") == 14);
  // 위쪽 카드는 그대로
  const auto& z = f.d().state.zones.get(f.zone(0, "main_deck"));
  for (size_t i = 0; i < 4; ++i) CHECK(std::find(cs.begin(), cs.end(), z.cards[i]) != cs.end());
}
