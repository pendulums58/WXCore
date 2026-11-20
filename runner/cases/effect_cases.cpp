#include <lua.h>

#include "fixture.h"
#include "test.h"

using namespace wx;
using wxtest::Fixture;

namespace {

// WXDi-P16-008 《扉の俯瞰者　タウィル＝トレ》 흉내: 【常】あなたの白のシグニのパワーを＋1000する。
const char* kTawil = R"(
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】: 나중에 나온 시그니도 받는다
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_LRIG)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,c) return c:IsColor(COLOR_WHITE) end)
  e1:SetValue(1000)
  c:RegisterEffect(e1)
end
)";

// 【常】このシグニのパワーは＋N000 (N = 레벨)
const char* kSelfBuff = R"(
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 자기 자신
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetValue(function(e,c) return c:GetLevel()*1000 end)
  c:RegisterEffect(e1)
end
)";

}  // namespace

TEST_CASE("power: ＋/－ 수정은 합산", "설계: 레이어 5") {
  Fixture f;
  f.signi(100, 5000);
  Duel& d = f.start();
  CardIdx c = f.put(100, 0, "signi_left");
  f.single(c, EFFECT_UPDATE_POWER, 3000, 0);
  f.single(c, EFFECT_UPDATE_POWER, -1000, 1);
  CHECK(d.power_of(c) == 7000);
}

TEST_CASE("power: 설정을 먼저, 증감을 나중에", "WXK10-054 FAQ 2") {
  Fixture f;
  f.signi(100, 5000);
  Duel& d = f.start();
  CardIdx c = f.put(100, 1, "signi_left");
  f.single(c, EFFECT_UPDATE_POWER, 3000, 1);
  CHECK(d.power_of(c) == 8000);
  f.single(c, EFFECT_SET_POWER, 0, 0);  // 「基本パワーを０にする」가 나중에 와도
  CHECK(d.power_of(c) == 3000);
}

TEST_CASE("power: 보이는 값은 0 밑으로 안 가고 계산은 음수까지", "WXEX2-52 FAQ 3, WX21-067 FAQ 3") {
  Fixture f;
  f.signi(100, 1000);
  Duel& d = f.start();
  CardIdx c = f.put(100, 1, "signi_left");
  f.single(c, EFFECT_UPDATE_POWER, -5000, 0);
  CHECK(d.power_of(c) == 0);
  CHECK(d.power_raw(c) == -4000);
  f.single(c, EFFECT_UPDATE_POWER, 5000, 0);
  CHECK(d.power_of(c) == 1000);
}

TEST_CASE("target: [まで] 고정 대상은 나중에 나온 시그니에 안 걸린다", "rule_240419: WDK04-007") {
  Fixture f;
  f.signi(100, 15000);
  Duel& d = f.start();
  CardIdx a = f.put(100, 1, "signi_left");
  f.single(a, EFFECT_UPDATE_POWER, -12000, 0);  // 그때 있던 시그니만
  CardIdx b = f.put(100, 1, "signi_center");
  CHECK(d.power_of(a) == 3000);
  CHECK(d.power_of(b) == 15000);
}

TEST_CASE("target: [の間] 【常】은 나중에 나온 시그니에도 걸린다", "rule_240419: WXDi-P16-008") {
  Fixture f;
  f.lrig(10);
  f.script(10, kTawil);
  f.signi(100, 5000, COLOR_WHITE);
  f.signi(101, 5000, COLOR_RED);
  Duel& d = f.start();
  f.put(10, 0, "lrig_center");
  CardIdx w = f.put(100, 0, "signi_left");
  CardIdx r = f.put(101, 0, "signi_center");
  CardIdx opp = f.put(100, 1, "signi_left");
  CHECK(d.power_of(w) == 6000);
  CHECK(d.power_of(r) == 5000);
  CHECK(d.power_of(opp) == 5000);
  CHECK(f.logs.empty());
}

TEST_CASE("target: [の間] 「このターン」 동적 효과도 나중 시그니에 걸린다", "rule_240419: WDK06-R06") {
  Fixture f;
  f.signi(100, 5000);
  Duel& d = f.start();
  f.field(EFFECT_UPDATE_POWER, 2000, 0, LOCATION_SZONE, 0, RESET_PHASE | PHASE_END);
  CardIdx later = f.put(100, 0, "signi_right");
  CHECK(d.power_of(later) == 7000);
}

TEST_CASE("reset: 장을 떠나면 생성 효과가 끊긴다", "용어집: 領域") {
  Fixture f;
  f.signi(100, 5000);
  Duel& d = f.start();
  CardIdx c = f.put(100, 0, "signi_left");
  f.single(c, EFFECT_UPDATE_POWER, 3000, 0);
  d.state.move(c, f.zone(0, "hand"));
  d.state.move(c, f.zone(0, "signi_left"));
  CHECK(d.power_of(c) == 5000);
}

TEST_CASE("reset: 장 안 이동은 효과를 유지한다", "WXK07-037 FAQ 1") {
  Fixture f;
  f.signi(100, 5000);
  Duel& d = f.start();
  CardIdx c = f.put(100, 0, "signi_center");
  f.single(c, EFFECT_UPDATE_POWER, 3000, 0, RESET_PHASE | PHASE_END);
  d.state.move(c, f.zone(0, "signi_left"));
  CHECK(d.power_of(c) == 8000);
}

TEST_CASE("reset: 「ターン終了時まで」는 엔드 페이즈에 끝난다", "설계: 엔드 페이즈 3") {
  Fixture f;
  f.signi(100, 5000);
  Duel& d = f.start();
  CardIdx c = f.put(100, 0, "signi_left");
  f.single(c, EFFECT_UPDATE_POWER, 3000, 0, RESET_PHASE | PHASE_END);
  f.single(c, EFFECT_UPDATE_POWER, 1000, 0);
  d.reset_phase(PHASE_MAIN);
  CHECK(d.power_of(c) == 9000);
  d.reset_phase(PHASE_END);
  CHECK(d.power_of(c) == 6000);
}

TEST_CASE("script: 【常】 값 함수가 현재 레벨을 읽는다", "설계: Lua 스크립트") {
  Fixture f;
  f.signi(102, 5000, COLOR_WHITE, 3);
  f.script(102, kSelfBuff);
  Duel& d = f.start();
  CardIdx c = f.put(102, 0, "signi_left");
  CHECK(d.power_of(c) == 8000);
  f.single(c, EFFECT_UPDATE_LEVEL, 1, 0);
  CHECK(d.power_of(c) == 9000);
  // 패에서는 범위 밖
  CardIdx h = f.put(102, 0, "hand");
  CHECK(d.power_of(h) == 5000);
  CHECK(f.logs.empty());
}

TEST_CASE("ability: 상실은 그 시점 능력만, 나중에 얻은 능력은 남는다", "SPK01-13 FAQ 5") {
  Fixture f;
  f.signi(102, 5000, COLOR_WHITE, 2);
  f.script(102, kSelfBuff);
  Duel& d = f.start();
  CardIdx c = f.put(102, 1, "signi_left");
  f.grant(c, EFFECT_UPDATE_POWER, 1000, 1);  // 먼저 얻은 능력
  CHECK(d.power_of(c) == 8000);
  f.single(c, EFFECT_LOSE_ABILITY, 0, 0);
  CHECK(d.power_of(c) == 5000);
  f.grant(c, EFFECT_UPDATE_POWER, 500, 1);  // 나중에 얻은 능력
  CHECK(d.power_of(c) == 5500);
}

TEST_CASE("ability: 동적 상실은 나중에 나온 시그니도 잃게 한다", "SP38-006 FAQ 6") {
  Fixture f;
  f.signi(102, 5000, COLOR_WHITE, 2);
  f.script(102, kSelfBuff);
  Duel& d = f.start();
  f.field(EFFECT_LOSE_ABILITY, 0, 0, 0, LOCATION_SZONE, RESET_PHASE | PHASE_END);
  CardIdx c = f.put(102, 1, "signi_left");
  CHECK(d.power_of(c) == 5000);
  d.reset_phase(PHASE_END);
  CHECK(d.power_of(c) == 7000);
}

TEST_CASE("innocence: 쓴 시점의 상대 효과는 何もしない", "WXK02-001 FAQ 16") {
  Fixture f;
  f.signi(100, 10000);
  Duel& d = f.start();
  CardIdx c = f.put(100, 0, "signi_left");
  f.single(c, EFFECT_UPDATE_POWER, -8000, 1);  // 상대 효과
  f.single(c, EFFECT_UPDATE_POWER, 2000, 0);   // 내 효과
  CHECK(d.power_of(c) == 4000);
  d.suppress_opponent_effects(0, RESET_PHASE | PHASE_END);
  CHECK(d.power_of(c) == 12000);
  // 이노센스 뒤에 쓴 상대 효과는 영향 없음
  f.single(c, EFFECT_UPDATE_POWER, -1000, 1);
  CHECK(d.power_of(c) == 11000);
  d.reset_phase(PHASE_END);
  CHECK(d.power_of(c) == 3000);
}

TEST_CASE("innocence: 공개 영역의 【常】만, 나중에 온 카드는 영향 없음", "WXK02-001 FAQ 25·26") {
  Fixture f;
  f.lrig(10);
  f.script(10, kTawil);
  f.signi(100, 5000, COLOR_WHITE);
  Duel& d = f.start();
  CardIdx tawil = f.put(10, 1, "lrig_center");
  CardIdx c = f.put(100, 1, "signi_left");
  CHECK(d.power_of(c) == 6000);
  d.suppress_opponent_effects(0, RESET_PHASE | PHASE_END);
  CHECK(d.power_of(c) == 5000);
  // 새 객체가 되면(장을 떠났다 돌아옴) 영향을 받지 않는다
  d.state.move(tawil, f.zone(1, "lrig_deck"));
  d.state.move(tawil, f.zone(1, "lrig_center"));
  CHECK(d.power_of(c) == 6000);
}

TEST_CASE("innocence: 원래 파워 0 시그니는 0이 된다", "WXK02-001 FAQ 20") {
  Fixture f;
  f.signi(103, 0, COLOR_GREEN, 3);
  f.script(103, kSelfBuff);
  Duel& d = f.start();
  CardIdx c = f.put(103, 1, "signi_left");
  CHECK(d.power_of(c) == 3000);
  d.suppress_opponent_effects(0, RESET_PHASE | PHASE_END);
  CHECK(d.power_raw(c) == 0);
}

TEST_CASE("innocence: 나중 이노센스가 덮는다", "WXK02-001 FAQ 19") {
  Fixture f;
  f.signi(100, 10000);
  Duel& d = f.start();
  CardIdx mine = f.put(100, 0, "signi_left");
  CardIdx theirs = f.put(100, 1, "signi_left");
  f.single(theirs, EFFECT_UPDATE_POWER, -3000, 0);  // 내 효과
  f.single(mine, EFFECT_UPDATE_POWER, -4000, 1);    // 상대 효과
  d.suppress_opponent_effects(1, RESET_PHASE | PHASE_END);  // 상대 이노센스
  CHECK(d.power_of(theirs) == 10000);
  CHECK(d.power_of(mine) == 6000);
  d.suppress_opponent_effects(0, RESET_PHASE | PHASE_END);  // 내 이노센스
  CHECK(d.power_of(theirs) == 7000);
  CHECK(d.power_of(mine) == 10000);
}

TEST_CASE("joker: 고정 수정과 얻은 능력은 사라지고 상태는 남는다", "WX17-001 FAQ 8·9") {
  Fixture f;
  f.signi(100, 5000, COLOR_WHITE, 2);
  f.signi(102, 12000, COLOR_RED, 4);
  f.script(102, kSelfBuff);
  Duel& d = f.start();
  CardIdx c = f.put(100, 0, "signi_left");
  d.state.cards.get(c).flags |= CF_DOWN;
  f.single(c, EFFECT_UPDATE_POWER, -8000, 1);
  f.grant(c, EFFECT_UPDATE_POWER, 3000, 0);
  d.become_copy(c, 102, 0, RESET_PHASE | PHASE_END);
  CHECK(d.text_of(c) == 102);
  CHECK(d.color_of(c) == COLOR_RED);
  CHECK(d.level_of(c) == 4);
  CHECK(d.power_of(c) == 16000);  // 12000 + 복사한 【常】 4000
  CHECK(d.state.cards.get(c).flags & CF_DOWN);
  CHECK(f.logs.empty());
}

TEST_CASE("joker: 동적 효과는 복사 뒤에도 적용된다", "WX17-001 FAQ 10") {
  Fixture f;
  f.signi(100, 5000);
  f.signi(102, 12000, COLOR_RED, 4);
  f.script(102, kSelfBuff);
  Duel& d = f.start();
  CardIdx c = f.put(100, 0, "signi_left");
  f.field(EFFECT_LOSE_ABILITY, 0, 1, 0, LOCATION_SZONE);  // ルーブル처럼 상대가 건 동적 상실
  d.become_copy(c, 102, 0, RESET_PHASE | PHASE_END);
  CHECK(d.power_of(c) == 12000);
}

TEST_CASE("joker: 턴 종료 시 원래 카드로 돌아온다", "WX17-001 FAQ 12") {
  Fixture f;
  f.signi(100, 5000);
  f.signi(102, 12000, COLOR_RED, 4);
  f.script(102, kSelfBuff);
  Duel& d = f.start();
  CardIdx c = f.put(100, 0, "signi_left");
  d.become_copy(c, 102, 0, RESET_PHASE | PHASE_END);
  d.reset_phase(PHASE_END);
  CHECK(d.text_of(c) == 100);
  CHECK(d.power_of(c) == 5000);
}

TEST_CASE("innocence: 복사 효과도 何もしない가 되면 원래대로", "WXK02-001 FAQ 22") {
  Fixture f;
  f.signi(100, 5000);
  f.signi(102, 12000, COLOR_RED, 4);
  Duel& d = f.start();
  CardIdx c = f.put(100, 0, "signi_left");
  d.become_copy(c, 102, 1, RESET_PHASE | PHASE_END);  // 상대가 바꿈
  CHECK(d.text_of(c) == 102);
  d.suppress_opponent_effects(0, RESET_PHASE | PHASE_END);
  CHECK(d.text_of(c) == 100);
}

TEST_CASE("class: 「：」 좌우 완전 일치 또는 오른쪽만 질의", "용어집: クラス") {
  CHECK(class_matches("精像：悪魔", "精像：悪魔"));
  CHECK(!class_matches("精像：悪魔", "奏像：悪魔"));
  CHECK(class_matches("精像：悪魔", "悪魔"));
  CHECK(class_matches("奏像：悪魔", "悪魔"));
  CHECK(!class_matches("精像：天使", "悪魔"));
}

TEST_CASE("script: math.random은 코어 PRNG를 쓴다", "설계: 결정론") {
  auto roll = [](uint64_t seed) {
    Fixture f;
    f.signi(104, 1000);
    f.script(104, "local s,id=GetID()\nfunction s.initial_effect(c) s.rolled=math.random(1000000) end");
    Duel& d = f.start(seed);
    f.put(104, 0, "hand");
    lua_getglobal(d.lua(), "c104");
    lua_getfield(d.lua(), -1, "rolled");
    lua_Integer v = lua_tointeger(d.lua(), -1);
    lua_pop(d.lua(), 2);
    return v;
  };
  CHECK(roll(5) == roll(5));
  CHECK(roll(5) != roll(6));
}
