// 아츠·스펠·【起】 사용과 확정 전 취소
#include <lua.h>

#include "fixture.h"
#include "test.h"

using namespace wx;
using wxtest::Fixture;

namespace {

// 상대 시그니 1체를 대상으로 바니시하는 스펠
const char* kBanishSpell = R"(
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetTarget(s.tg)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingTarget(Card.IsSigni,tp,0,LOCATION_SZONE,1,nil) end
  Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
end
function s.op(e,tp)
  ORDER = (ORDER or '') .. 'S'
  local tc=Duel.GetFirstTarget()
  if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
end
)";

// 1장 뽑는 아츠
const char* kDrawArts = R"(
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e1)
end
)";

void setup(Fixture& f) {
  f.lrig(1, COLOR_WHITE, 3, 9);
  f.cards[1].classes = {"タマ"};
  f.signi(100, 5000);
  f.signi(101, 3000, COLOR_RED);
  f.cards[400] = CardData{};
  f.cards[400].type = TYPE_SPELL;
  f.cards[400].color = COLOR_WHITE;
  f.cards[400].cost_ena = "{W}";
  f.script(400, kBanishSpell);
  f.cards[401] = CardData{};
  f.cards[401].type = TYPE_ARTS;
  f.cards[401].timing = TIMING_ATTACK;
  f.script(401, kDrawArts);
}

void stock(Fixture& f) {
  f.fill(100, 0, "main_deck", 10);
  f.fill(100, 1, "main_deck", 10);
}

}  // namespace

TEST_CASE("use: 스펠은 코스트 → 대상 → 효과 → 트래시", "faq.txt 「スペルの使用手順」") {
  Fixture f;
  setup(f);
  Duel& d = f.start();
  stock(f);
  f.put(1, 0, "lrig_center");
  CardIdx spell = f.put(400, 0, "hand");
  CardIdx white = f.put(100, 0, "ena");
  CardIdx target = f.put(100, 1, "signi_left");
  d.test_begin(0, PHASE_MAIN);
  CHECK(f.until(HINT_MAIN));
  const uint32_t act = f.action(ActionKind::UseCard, spell);
  CHECK(act != 0xFFFFFFFF);
  CHECK(f.answer({act}));
  CHECK(f.until(HINT_PAY_ENA));
  CHECK(d.request()->cancelable);
  CHECK(f.answer({white}));
  CHECK(f.until(HINT_TARGET));
  CHECK(d.request()->options == std::vector<uint32_t>{target});
  CHECK(f.answer({target}));
  CHECK(f.until(HINT_MAIN));
  CHECK(d.state.cards.get(target).zone == f.zone(1, "ena"));
  CHECK(d.state.cards.get(spell).zone == f.zone(0, "trash"));
  CHECK(d.state.cards.get(white).zone == f.zone(0, "trash"));
  CHECK(f.saw(HINT_CUTIN));  // 상대에게 컷인 창이 열렸다(always_ask)
  CHECK(f.logs.empty());
}

TEST_CASE("use: 확정 전에는 취소하면 아무것도 바뀌지 않는다", "설계: 확정 전 취소(아레나식)") {
  Fixture f;
  setup(f);
  Duel& d = f.start();
  stock(f);
  f.put(1, 0, "lrig_center");
  CardIdx spell = f.put(400, 0, "hand");
  CardIdx white = f.put(100, 0, "ena");
  f.put(100, 1, "signi_left");
  d.test_begin(0, PHASE_MAIN);
  CHECK(f.until(HINT_MAIN));
  CHECK(f.answer({f.action(ActionKind::UseCard, spell)}));
  CHECK(f.until(HINT_PAY_ENA));
  CHECK(f.answer({white}));
  CHECK(f.until(HINT_TARGET));
  Response cancel;
  cancel.cancel = true;
  CHECK(d.respond(cancel));
  CHECK(f.until(HINT_MAIN));
  CHECK(d.state.cards.get(spell).zone == f.zone(0, "hand"));
  CHECK(d.state.cards.get(white).zone == f.zone(0, "ena"));
  CHECK(d.chain.empty());
  // 다시 써도 된다
  CHECK(f.action(ActionKind::UseCard, spell) != 0xFFFFFFFF);
}

TEST_CASE("use: 확정 뒤의 선택은 취소할 수 없다", "설계: 확정 전 취소") {
  Fixture f;
  setup(f);
  Duel& d = f.start();
  stock(f);
  f.fill(100, 0, "hand", 8);
  d.test_begin(0, PHASE_END);
  CHECK(f.until(HINT_DISCARD));
  CHECK(!d.request()->cancelable);
  Response cancel;
  cancel.cancel = true;
  std::string why;
  CHECK(!d.respond(cancel, &why));
}

TEST_CASE("use: 대상이 없으면 쓸 수 있는 행동에 나오지 않는다", "설계: 묻는 시점") {
  Fixture f;
  setup(f);
  Duel& d = f.start();
  stock(f);
  f.put(1, 0, "lrig_center");
  CardIdx spell = f.put(400, 0, "hand");
  f.put(100, 0, "ena");
  d.test_begin(0, PHASE_MAIN);
  CHECK(f.until(HINT_MAIN));
  CHECK(f.action(ActionKind::UseCard, spell) == 0xFFFFFFFF);
}

TEST_CASE("use: 에나 색이 안 맞으면 쓸 수 없다", "용어집: スペル, 설계: 비용 표기") {
  Fixture f;
  setup(f);
  Duel& d = f.start();
  stock(f);
  f.put(1, 0, "lrig_center");
  CardIdx spell = f.put(400, 0, "hand");
  f.put(101, 0, "ena");  // 적
  f.put(100, 1, "signi_left");
  d.test_begin(0, PHASE_MAIN);
  CHECK(f.until(HINT_MAIN));
  CHECK(f.action(ActionKind::UseCard, spell) == 0xFFFFFFFF);
}

TEST_CASE("use: 【アタックフェイズ】 아츠는 프리어택(턴)·디펜스(상대) 스텝에", "faq.txt 「アタックフェイズ」, 용어집: 使用タイミング") {
  Fixture f;
  setup(f);
  Duel& d = f.start();
  stock(f);
  CardIdx mine = f.put(401, 0, "lrig_deck");
  CardIdx theirs = f.put(401, 1, "lrig_deck");
  d.test_begin(0, PHASE_MAIN);
  CHECK(f.until(HINT_MAIN));
  CHECK(f.action(ActionKind::UseCard, mine) == 0xFFFFFFFF);  // 메인 페이즈에는 못 쓴다
  CHECK(f.answer({f.action(ActionKind::EndPhase)}));
  CHECK(f.until(HINT_PRE_ATTACK));
  CHECK(d.request()->player == 0);
  CHECK(f.answer({f.action(ActionKind::UseCard, mine)}));
  CHECK(f.until(HINT_DEFENSE));
  CHECK(d.request()->player == 1);
  CHECK(f.count(0, "hand") == 1);
  CHECK(d.state.cards.get(mine).zone == f.zone(0, "lrig_trash"));
  CHECK(f.answer({f.action(ActionKind::UseCard, theirs)}));
  CHECK(f.until(HINT_DEFENSE));  // 다 쓰고 나면 다시 묻는다(always_ask)
  CHECK(f.count(1, "hand") == 1);
}

TEST_CASE("use: 컷인은 스펠 효과보다 먼저, 대상이 떠나면 그 부분은 처리되지 않는다", "faq.txt 610·639, PR-030 FAQ 2") {
  Fixture f;
  setup(f);
  f.cards[402] = CardData{};
  f.cards[402].type = TYPE_ARTS;
  f.cards[402].timing = TIMING_CUTIN;
  f.script(402, R"(
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetOperation(function(e,tp)
    ORDER = (ORDER or '') .. 'C'
    local g=Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil)
    Duel.Banish(g:GetFirst())
  end)
  c:RegisterEffect(e1)
end
)");
  Duel& d = f.start();
  stock(f);
  f.put(1, 0, "lrig_center");
  CardIdx spell = f.put(400, 0, "hand");
  f.put(100, 0, "ena");
  CardIdx target = f.put(100, 1, "signi_left");
  CardIdx cut = f.put(402, 1, "lrig_deck");
  d.test_begin(0, PHASE_MAIN);
  CHECK(f.until(HINT_MAIN));
  CHECK(f.answer({f.action(ActionKind::UseCard, spell)}));
  CHECK(f.until(HINT_TARGET));
  CHECK(f.answer({target}));
  CHECK(f.until(HINT_CUTIN));
  CHECK(d.request()->player == 1);
  CHECK(d.state.cards.get(spell).zone == f.zone(0, "check"));  // 스펠은 체크 존에서 기다린다
  CHECK(f.answer({f.action(ActionKind::UseCard, cut)}));
  CHECK(f.until(HINT_MAIN));
  lua_getglobal(d.lua(), "ORDER");
  CHECK(std::string(lua_tostring(d.lua(), -1)) == "CS");
  lua_pop(d.lua(), 1);
  CHECK(d.state.cards.get(target).zone == f.zone(1, "ena"));
  CHECK(d.state.cards.get(cut).zone == f.zone(1, "lrig_trash"));
  CHECK(f.logs.empty());
}

TEST_CASE("use: 【起】 에나 코스트를 내고 효과를 처리한다", "용어집: 起動能力") {
  Fixture f;
  setup(f);
  f.signi(403, 5000);
  f.script(403, R"(
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetRange(LOCATION_SZONE)
  e1:SetEnaCost('{R}')
  e1:SetOperation(function(e,tp)
    local c=e:GetHandler()
    -- [まで] 턴 종료 시까지, 대상 고정
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_UPDATE_POWER)
    e2:SetValue(3000)
    e2:SetReset(RESET_PHASE+PHASE_END)
    c:RegisterEffect(e2)
  end)
  c:RegisterEffect(e1)
end
)");
  for (bool has_red : {false, true}) {
    Duel& d = f.start();
    stock(f);
    f.put(1, 0, "lrig_center");
    CardIdx s = f.put(403, 0, "signi_left");
    f.put(100, 0, "ena");
    CardIdx red = has_red ? f.put(101, 0, "ena") : kNoCard;
    d.test_begin(0, PHASE_MAIN);
    CHECK(f.until(HINT_MAIN));
    const uint32_t act = f.action(ActionKind::UseAbility, s);
    if (!has_red) {
      CHECK(act == 0xFFFFFFFF);  // 적 에나가 없다
      continue;
    }
    CHECK(act != 0xFFFFFFFF);
    CHECK(f.answer({act}));
    CHECK(f.until(HINT_PAY_ENA));
    CHECK(f.answer({red}));
    CHECK(f.until(HINT_MAIN));
    CHECK(d.power_of(s) == 8000);
  }
  CHECK(f.logs.empty());
}

TEST_CASE("use: 한정 조건이 센터 루리그와 다르면 쓸 수 없다", "용어집: ルリグタイプ") {
  Fixture f;
  setup(f);
  f.cards[404] = f.cards[401];
  f.cards[404].timing = TIMING_MAIN;
  f.cards[404].limit_cond = {"ピルルク"};
  f.script(404, kDrawArts);
  Duel& d = f.start();
  stock(f);
  f.put(1, 0, "lrig_center");
  CardIdx arts = f.put(404, 0, "lrig_deck");
  d.test_begin(0, PHASE_MAIN);
  CHECK(f.until(HINT_MAIN));
  CHECK(f.action(ActionKind::UseCard, arts) == 0xFFFFFFFF);
}
