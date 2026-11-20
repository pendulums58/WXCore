// 턴 진행·룰 처리·트리거 케이스
#include <lua.h>

#include "fixture.h"
#include "test.h"

using namespace wx;
using wxtest::Fixture;

namespace {

// 기본 장: 양쪽에 레벨 3·리미트 9 루리그
void base(Fixture& f) {
  f.lrig(1, COLOR_WHITE, 3, 9);
  f.cards[1].classes = {"タマ"};
  f.signi(100, 5000);
  f.signi(101, 3000);
}

// 양쪽 덱을 채운다. 덱이 비어 있으면 트래시에 카드가 들어가는 순간 리프레시가 일어난다
void stock(Fixture& f, int n = 10) {
  f.fill(100, 0, "main_deck", n);
  f.fill(100, 1, "main_deck", n);
}

const char* kDrawOn(const char* event) {
  static std::string s;
  s = std::string(R"(
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetCode()") + event + R"()
  e1:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e1)
end
)";
  return s.c_str();
}

}  // namespace

TEST_CASE("mode: 테스트 모드가 꺼져 있으면 test_begin 거부", "CLAUDE.md: 코어 규칙") {
  Fixture f;
  f.test_mode = false;
  Duel& d = f.start();
  CHECK(!d.test_begin(0, PHASE_MAIN));
}

TEST_CASE("start: 게임 시작 절차(5장, 引き直し, 라이프 7, 오픈)", "faq.txt 「ゲーム開始時」, 용어집: 引き直し") {
  Fixture f;
  base(f);
  f.lrig(2, COLOR_WHITE, 0, 0);
  f.cards[2].classes = {"タマ"};
  f.first = 1;
  Duel& d = f.start(7);
  std::vector<Cid> main(40, 100);
  d.set_deck(0, main, {2});
  d.set_deck(1, main, {2});
  d.start();
  CHECK(f.until(HINT_MULLIGAN));
  CHECK(d.request()->player == 1);  // 선공부터 선언
  CHECK(f.answer({d.request()->options[0], d.request()->options[1]}));
  CHECK(f.until(HINT_MULLIGAN));
  CHECK(d.request()->player == 0);
  CHECK(f.answer({}));
  CHECK(f.until(HINT_MAIN));
  CHECK(d.turn_player == 1);
  CHECK(f.count(0, "hand") == 5);
  CHECK(f.count(0, "life_cloth") == 7 && f.count(1, "life_cloth") == 7);
  CHECK(f.count(1, "hand") == 6);  // 5장 + 선공 1턴째 드로 1장
  CHECK(f.count(1, "main_deck") == 40 - 5 - 7 - 1);
  CHECK(d.state.cards.get(d.center_lrig(0)).face_up);
}

TEST_CASE("start: 같은 시드와 응답이면 같은 게임", "설계: 결정론") {
  auto play = [](uint64_t seed) {
    Fixture f;
    base(f);
    f.lrig(2, COLOR_WHITE, 0, 0);
    for (Cid c = 100; c < 110; ++c) f.signi(c, 1000);
    Duel& d = f.start(seed);
    std::vector<Cid> main;
    for (int i = 0; i < 40; ++i) main.push_back(100 + i % 10);
    d.set_deck(0, main, {2});
    d.set_deck(1, main, {2});
    d.start();
    f.until(HINT_MAIN);
    std::vector<Cid> hand;
    for (CardIdx c : d.state.zones.get(f.zone(d.turn_player, "hand")).cards) hand.push_back(d.state.cards.get(c).cid);
    return std::make_pair(d.turn_player, hand);
  };
  CHECK(play(11) == play(11));
}

TEST_CASE("draw: 선공 1턴째는 1장, 어택 페이즈 없음", "용어집: 先攻") {
  Fixture f;
  base(f);
  Duel& d = f.start();
  f.put(1, 0, "lrig_center");
  f.put(100, 0, "signi_left");
  f.fill(100, 0, "main_deck", 5);
  f.fill(100, 1, "main_deck", 5);
  d.test_begin(0, PHASE_UP, true);
  CHECK(f.until(HINT_MAIN));
  CHECK(f.count(0, "hand") == 1);
  CHECK(f.answer({f.action(ActionKind::EndPhase)}));
  CHECK(f.until(HINT_MAIN));
  CHECK(d.turn_player == 1);
  CHECK(!f.saw(HINT_ATTACK_SIGNI) && !f.saw(HINT_ATTACK_LRIG));
}

TEST_CASE("draw: 1장 뽑고 덱 0장이면 리프레시하고 엔나 페이즈로", "용어집: ドローフェイズ, リフレッシュ") {
  Fixture f;
  base(f);
  Duel& d = f.start();
  f.fill(100, 0, "main_deck", 1);
  f.fill(101, 0, "trash", 3);
  f.fill(100, 0, "life_cloth", 2);
  d.test_begin(0, PHASE_DRAW);
  CHECK(f.until(HINT_ENA_CHARGE));
  CHECK(f.count(0, "hand") == 1);
  CHECK(f.count(0, "main_deck") == 3);
  CHECK(f.count(0, "trash") == 1);  // 라이프 1장이 트래시로
  CHECK(f.count(0, "life_cloth") == 1);
  CHECK(d.players[0].refreshes_this_turn == 1);
}

TEST_CASE("refresh: 한 턴에 두 번째 리프레시면 턴이 끝난다", "용어집: リフレッシュ, ターンを終了する") {
  Fixture f;
  base(f);
  Duel& d = f.start();
  f.put(1, 0, "lrig_center");
  f.put(100, 0, "signi_left");  // 어택할 수 있는 시그니
  f.fill(100, 0, "main_deck", 1);
  f.fill(101, 0, "trash", 3);
  f.fill(100, 0, "life_cloth", 3);
  f.fill(100, 1, "main_deck", 5);
  d.test_begin(0, PHASE_DRAW);
  CHECK(f.until(HINT_MAIN));
  CHECK(d.players[0].refreshes_this_turn == 1);
  // 덱을 비우고 체크 존에 카드를 둔 채 메인을 끝낸다
  for (CardIdx c : std::vector<CardIdx>(d.state.zones.get(f.zone(0, "main_deck")).cards))
    d.state.move(c, f.zone(0, "trash"));
  CardIdx chk = f.put(101, 0, "check");
  CHECK(f.answer({f.action(ActionKind::EndPhase)}));
  CHECK(f.until(HINT_MAIN));
  CHECK(d.turn_player == 1);
  CHECK(!f.saw(HINT_ATTACK_SIGNI));  // 남은 페이즈는 건너뛴다
  CHECK(d.state.zones.get(d.state.cards.get(chk).zone).kind == ZoneKind::Trash);
}

TEST_CASE("up: 동결된 시그니는 업하지 않고, 업 페이즈 끝에 동결이 풀린다", "용어집: アップフェイズ, 凍結") {
  Fixture f;
  base(f);
  Duel& d = f.start();
  CardIdx a = f.put(100, 0, "signi_left");
  CardIdx b = f.put(100, 0, "signi_center");
  d.state.cards.get(a).flags |= CF_DOWN | CF_FROZEN;
  d.state.cards.get(b).flags |= CF_DOWN;
  d.test_begin(0, PHASE_UP);
  CHECK(f.until(HINT_ENA_CHARGE));
  CHECK(d.state.cards.get(a).flags == CF_DOWN);
  CHECK(d.state.cards.get(b).flags == 0);
}

TEST_CASE("ena: 패 또는 장의 시그니 1장, 안 해도 된다", "용어집: エナフェイズ") {
  Fixture f;
  base(f);
  Duel& d = f.start();
  CardIdx h = f.put(101, 0, "hand");
  CardIdx s = f.put(100, 0, "signi_left");
  d.test_begin(0, PHASE_ENA);
  CHECK(f.until(HINT_ENA_CHARGE));
  const Request& r = *d.request();
  CHECK(r.min == 0 && r.max == 1);
  CHECK(r.options.size() == 2);
  CHECK(f.answer({s}));
  CHECK(f.until(HINT_MAIN));
  CHECK(f.count(0, "ena") == 1);
  CHECK(d.state.cards.get(h).zone == f.zone(0, "hand"));
}

TEST_CASE("grow: 한 레벨 위, 같은 루리그 타입, 비용 색이 맞아야 한다", "용어집: グロウ, faq.txt 「グロウの手順」") {
  Fixture f;
  base(f);
  f.lrig(2, COLOR_WHITE, 0, 0);
  f.cards[2].classes = {"タマ"};
  f.lrig(3, COLOR_WHITE, 1, 3);
  f.cards[3].classes = {"タマ"};
  f.cards[3].grow_ena = "{W}";
  f.lrig(4, COLOR_WHITE, 2, 5);  // 두 단계 위
  f.cards[4].classes = {"タマ"};
  f.signi(102, 1000, COLOR_RED);
  Duel& d = f.start();
  stock(f);
  CardIdx old = f.put(2, 0, "lrig_center");
  CardIdx next = f.put(3, 0, "lrig_deck");
  f.put(4, 0, "lrig_deck");
  CardIdx white = f.put(100, 0, "ena");
  CardIdx red = f.put(102, 0, "ena");
  d.test_begin(0, PHASE_GROW);
  CHECK(f.until(HINT_GROW));
  CHECK(d.request()->options == std::vector<uint32_t>{next});
  CHECK(f.answer({next}));
  CHECK(f.until(HINT_PAY_ENA));
  std::string why;
  CHECK(!d.respond(Response{{red}}, &why));  // 색이 안 맞으면 거부하고 다시 묻는다
  CHECK(!why.empty());
  CHECK(f.answer({white}));
  CHECK(f.until(HINT_MAIN));
  CHECK(d.center_lrig(0) == next);
  CHECK(d.state.cards.get(next).under == std::vector<CardIdx>{old});
  CHECK(d.state.cards.get(white).zone == f.zone(0, "trash"));
}

TEST_CASE("main: 루리그 레벨·리미트를 넘는 시그니는 낼 수 없다", "용어집: メインフェイズ 1, リミット") {
  Fixture f;
  base(f);
  f.lrig(5, COLOR_WHITE, 2, 5);
  f.signi(110, 1000, COLOR_WHITE, 3);
  f.signi(111, 1000, COLOR_WHITE, 2);
  Duel& d = f.start();
  f.put(5, 0, "lrig_center");
  f.put(111, 0, "signi_left");
  f.put(111, 0, "signi_center");  // 레벨 합 4
  CardIdx lv3 = f.put(110, 0, "hand");
  CardIdx lv2 = f.put(111, 0, "hand");
  d.test_begin(0, PHASE_MAIN);
  CHECK(f.until(HINT_MAIN));
  CHECK(f.action(ActionKind::PlaySigni, lv3) == 0xFFFFFFFF);  // 레벨 초과
  CHECK(f.action(ActionKind::PlaySigni, lv2) == 0xFFFFFFFF);  // 합 6 > 리미트 5
}

TEST_CASE("trigger: 【出】로 1장 뽑는다", "설계: 능력 종류 대응 【出】") {
  Fixture f;
  base(f);
  f.signi(300, 1000);
  f.script(300, kDrawOn("EVENT_ON_PLAY"));
  Duel& d = f.start();
  f.put(1, 0, "lrig_center");
  f.fill(100, 0, "main_deck", 3);
  CardIdx c = f.put(300, 0, "hand");
  d.test_begin(0, PHASE_MAIN);
  CHECK(f.until(HINT_MAIN));
  CHECK(f.answer({f.action(ActionKind::PlaySigni, c, f.zone(0, "signi_left"))}));
  CHECK(f.until(HINT_MAIN));
  CHECK(f.count(0, "hand") == 1);
  CHECK(f.logs.empty());
}

TEST_CASE("trigger: 스크립트의 선택 요청은 코루틴으로 멈췄다 이어진다", "설계: 선택과 입력") {
  Fixture f;
  base(f);
  f.signi(303, 1000);
  f.script(303, R"(
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    if Duel.SelectYesNo(tp) then Duel.Draw(tp,2) end
  end)
  c:RegisterEffect(e1)
end
)");
  Duel& d = f.start();
  f.put(1, 0, "lrig_center");
  f.fill(100, 0, "main_deck", 3);
  CardIdx c = f.put(303, 0, "hand");
  d.test_begin(0, PHASE_MAIN);
  CHECK(f.until(HINT_MAIN));
  CHECK(f.answer({f.action(ActionKind::PlaySigni, c, f.zone(0, "signi_left"))}));
  CHECK(f.until(HINT_SCRIPT));
  CHECK(f.answer({1}));
  CHECK(f.until(HINT_MAIN));
  CHECK(f.count(0, "hand") == 2);
  CHECK(f.logs.empty());
}

TEST_CASE("rule1: 파워 0 이하 → 바니시, 붙은 카드는 트래시", "용어집: ルール処理 1·3, バニッシュ") {
  Fixture f;
  base(f);
  Duel& d = f.start();
  stock(f);
  f.put(1, 0, "lrig_center");
  CardIdx s = f.put(101, 0, "signi_left");
  CardIdx acce = f.put(100, 0, "trash");
  d.state.attach(acce, s);
  f.single(s, EFFECT_UPDATE_POWER, -3000, 1);
  d.test_begin(0, PHASE_END);
  CHECK(f.until(HINT_MAIN));
  CHECK(d.state.cards.get(s).zone == f.zone(0, "ena"));
  CHECK(d.state.cards.get(acce).zone == f.zone(0, "trash"));
}

TEST_CASE("rule2: 레벨이 루리그를 넘으면 트래시", "용어집: ルール処理 2") {
  Fixture f;
  base(f);
  f.lrig(5, COLOR_WHITE, 1, 9);
  f.signi(110, 1000, COLOR_WHITE, 1);
  Duel& d = f.start();
  stock(f);
  f.put(5, 0, "lrig_center");
  CardIdx s = f.put(110, 0, "signi_left");
  f.single(s, EFFECT_UPDATE_LEVEL, 1, 1);
  d.test_begin(0, PHASE_END);
  CHECK(f.until(HINT_MAIN));
  CHECK(d.state.cards.get(s).zone == f.zone(0, "trash"));
}

TEST_CASE("rule2: 리미트 초과면 레벨이 바뀐 시그니부터", "용어집: ルール処理 2 (A→B→C)") {
  Fixture f;
  base(f);
  f.lrig(5, COLOR_WHITE, 3, 6);
  f.signi(113, 1000, COLOR_WHITE, 3);
  f.signi(112, 1000, COLOR_WHITE, 2);
  f.signi(111, 1000, COLOR_WHITE, 1);
  Duel& d = f.start();
  stock(f);
  f.put(5, 0, "lrig_center");
  CardIdx a = f.put(113, 0, "signi_left");
  CardIdx b = f.put(112, 0, "signi_center");
  CardIdx c = f.put(111, 0, "signi_right");
  d.test_begin(0, PHASE_GROW);  // 그로우 페이즈 끝 룰 처리에서 레벨이 기록된다
  CHECK(f.until(HINT_MAIN));
  f.single(c, EFFECT_UPDATE_LEVEL, 1, 1);  // 합 7 > 6
  CHECK(f.answer({f.action(ActionKind::EndPhase)}));
  CHECK(f.until(HINT_ATTACK_SIGNI));
  CHECK(!f.saw(HINT_RULE_TRASH));  // 후보가 하나라 묻지 않는다
  CHECK(d.state.cards.get(c).zone == f.zone(0, "trash"));
  CHECK(d.state.cards.get(a).zone == f.zone(0, "signi_left"));
  CHECK(d.state.cards.get(b).zone == f.zone(0, "signi_center"));
}

TEST_CASE("rule6·7: 레조나는 루리그 덱으로, 루리그는 루리그 트래시로", "용어집: ルール処理 6·7") {
  Fixture f;
  base(f);
  f.cards[120] = CardData{};
  f.cards[120].type = TYPE_SIGNI | TYPE_RESONA;
  f.cards[120].power = 10000;
  Duel& d = f.start();
  CardIdx resona = f.put(120, 0, "trash");
  CardIdx lrig = f.put(1, 0, "hand");
  d.test_begin(0, PHASE_END);
  CHECK(f.until(HINT_MAIN));
  CHECK(d.state.cards.get(resona).zone == f.zone(0, "lrig_deck"));
  CHECK(d.state.cards.get(lrig).zone == f.zone(0, "lrig_trash"));
}

TEST_CASE("rule9: 한정 조건이 센터 루리그 타입과 다르면 트래시", "용어집: ルール処理 9, 限定条件") {
  Fixture f;
  base(f);
  f.signi(130, 1000);
  f.cards[130].limit_cond = {"ピルルク"};
  f.signi(131, 1000);
  f.cards[131].limit_cond = {"タマ"};
  Duel& d = f.start();
  stock(f);
  f.put(1, 0, "lrig_center");
  CardIdx bad = f.put(130, 0, "signi_left");
  CardIdx ok = f.put(131, 0, "signi_center");
  d.test_begin(0, PHASE_END);
  CHECK(f.until(HINT_MAIN));
  CHECK(d.state.cards.get(bad).zone == f.zone(0, "trash"));
  CHECK(d.state.cards.get(ok).zone == f.zone(0, "signi_center"));
}

TEST_CASE("rule10: 루리그 타입이 같은 루리그는 센터가 아닌 쪽이 루리그 트래시로", "용어집: ルール処理 10") {
  Fixture f;
  base(f);
  f.cards[6] = CardData{};
  f.cards[6].type = TYPE_ASSIST_LRIG;
  f.cards[6].classes = {"タマ"};
  Duel& d = f.start();
  f.put(1, 0, "lrig_center");
  CardIdx assist = f.put(6, 0, "lrig_assist_left");
  d.test_begin(0, PHASE_END);
  CHECK(f.until(HINT_MAIN));
  CHECK(d.state.cards.get(assist).zone == f.zone(0, "lrig_trash"));
  CHECK(d.center_lrig(0) != kNoCard);
}

TEST_CASE("battle: 어택한 쪽 파워가 같거나 높으면 바니시, 낮으면 둘 다 남는다", "용어집: バトル") {
  Fixture f;
  base(f);
  Duel& d = f.start();
  CardIdx big = f.put(100, 0, "signi_left");      // 5000
  CardIdx small = f.put(101, 0, "signi_center");  // 3000
  CardIdx d1 = f.put(100, 1, "signi_right");      // big의 정면, 5000
  CardIdx d2 = f.put(100, 1, "signi_center");     // small의 정면, 5000
  f.fill(100, 1, "main_deck", 5);
  d.test_begin(0, PHASE_ATTACK);
  CHECK(f.until(HINT_ATTACK_SIGNI));
  CHECK(f.answer({big}));
  CHECK(f.until(HINT_ATTACK_SIGNI));
  CHECK(d.state.cards.get(d1).zone == f.zone(1, "ena"));
  CHECK(f.answer({small}));
  CHECK(f.until(HINT_MAIN));
  CHECK(d.state.cards.get(d2).zone == f.zone(1, "signi_center"));
  CHECK(d.state.cards.get(small).flags & CF_DOWN);
}

TEST_CASE("damage: 정면 존이 지워졌으면 데미지, 지운 존의 카드는 트래시·트리거 발동", "WXK03-005 FAQ 1·4·6") {
  Fixture f;
  base(f);
  f.signi(301, 1000);
  f.script(301, kDrawOn("EVENT_LEAVE_FIELD"));
  Duel& d = f.start();
  stock(f);
  CardIdx a = f.put(100, 0, "signi_left");
  CardIdx victim = f.put(301, 1, "signi_right");
  CardIdx acce = f.put(100, 1, "trash");
  d.state.attach(acce, victim);
  f.fill(100, 1, "life_cloth", 2);
  d.remove_zone(f.zone(1, "signi_right"), 0);
  d.test_begin(0, PHASE_ATTACK);
  CHECK(f.until(HINT_ATTACK_SIGNI));  // 시작 시 resolve에서 장을 떠난 트리거가 처리된다
  CHECK(d.state.cards.get(victim).zone == f.zone(1, "trash"));
  CHECK(d.state.cards.get(acce).zone == f.zone(1, "trash"));
  CHECK(f.count(1, "hand") == 1);
  CHECK(f.answer({a}));
  CHECK(f.until(HINT_MAIN));
  CHECK(f.count(1, "life_cloth") == 1);
  CHECK(f.count(1, "ena") == 1);  // 버스트 없는 크러시 카드는 에나로
}

TEST_CASE("damage: 라이프 클로스가 없으면 패배", "용어집: ダメージ") {
  Fixture f;
  base(f);
  Duel& d = f.start();
  CardIdx a = f.put(100, 0, "signi_left");
  d.test_begin(0, PHASE_ATTACK);
  CHECK(f.until(HINT_ATTACK_SIGNI));
  CHECK(f.answer({a}));
  CHECK(!f.until(HINT_MAIN));
  CHECK(d.ended() && d.winner() == 0);
}

TEST_CASE("guard: 가드하면 루리그 어택 데미지를 막는다", "용어집: ガード, ガードステップ") {
  Fixture f;
  base(f);
  f.signi(140, 1000);
  f.cards[140].guard = true;
  Duel& d = f.start();
  stock(f);
  CardIdx lrig = f.put(1, 0, "lrig_center");
  CardIdx g = f.put(140, 1, "hand");
  f.put(100, 1, "hand");  // 가드 없는 카드는 후보가 아니다
  f.fill(100, 1, "life_cloth", 2);
  d.test_begin(0, PHASE_ATTACK);
  CHECK(f.until(HINT_ATTACK_LRIG));
  CHECK(f.answer({lrig}));
  CHECK(f.until(HINT_GUARD));
  CHECK(d.request()->player == 1);
  CHECK(d.request()->options == std::vector<uint32_t>{g});
  CHECK(f.answer({g}));
  CHECK(f.until(HINT_MAIN));
  CHECK(f.count(1, "life_cloth") == 2);
  CHECK(d.state.cards.get(g).zone == f.zone(1, "trash"));
}

TEST_CASE("burst: 크러시된 카드의 라이프 버스트를 고르면 발동하고 에나로", "용어집: クラッシュ, ライフバースト, ルール処理 4") {
  Fixture f;
  base(f);
  f.signi(302, 1000);
  f.cards[302].life_burst = true;
  f.script(302, R"(
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_LIFEBURST)
  e1:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e1)
end
)");
  Duel& d = f.start();
  stock(f);
  CardIdx a = f.put(100, 0, "signi_left");
  f.put(100, 1, "life_cloth");
  CardIdx burst = f.put(302, 1, "life_cloth");  // 맨 위
  d.test_begin(0, PHASE_ATTACK);
  CHECK(f.until(HINT_ATTACK_SIGNI));
  CHECK(f.answer({a}));
  CHECK(f.until(HINT_LIFEBURST));
  CHECK(d.request()->player == 1);
  CHECK(f.answer({1}));
  CHECK(f.until(HINT_MAIN));  // 상대 턴 메인: 버스트 1장 + 드로 2장
  CHECK(f.count(1, "hand") == 3);
  CHECK(d.state.cards.get(burst).zone == f.zone(1, "ena"));
  CHECK(f.logs.empty());
}

TEST_CASE("trigger: 턴 플레이어 먼저, 새로 트리거한 턴 플레이어 것도 먼저", "faq.txt 「トリガー能力」, 용어집: トリガー能力 4") {
  Fixture f;
  base(f);
  const char* push = "ORDER = ORDER or {}; table.insert(ORDER, '%s')";
  auto op = [&](const char* name) {
    char buf[96];
    std::snprintf(buf, sizeof buf, push, name);
    return std::string(buf);
  };
  f.signi(310, 5000);
  f.script(310, R"(
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp) )" + op("A") + R"( end)
  c:RegisterEffect(e1)
end
)");
  for (Cid w : {311u, 312u}) {
    f.signi(w, 1000);
    f.script(w, R"(
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetCode(EVENT_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg) return eg:GetFirst():GetControler()~=tp end)
  e1:SetOperation(function(e,tp) )" + op(w == 311 ? "W1" : "W2") + R"( Duel.Draw(tp,1) end)
  c:RegisterEffect(e1)
end
)");
  }
  f.signi(313, 1000);
  f.script(313, R"(
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetCode(EVENT_DRAW)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg,ep) return ep~=tp end)
  e1:SetOperation(function(e,tp) )" + op("D") + R"( end)
  c:RegisterEffect(e1)
end
)");
  Duel& d = f.start();
  CardIdx a = f.put(310, 0, "signi_left");
  f.put(313, 0, "signi_right");
  f.put(311, 1, "signi_left");
  f.put(312, 1, "signi_center");
  f.fill(100, 1, "main_deck", 5);
  f.fill(100, 1, "life_cloth", 3);
  d.test_begin(0, PHASE_ATTACK);
  CHECK(f.until(HINT_ATTACK_SIGNI));
  CHECK(f.answer({a}));
  CHECK(f.until(HINT_TRIGGER_ORDER));
  CHECK(d.request()->player == 1);
  CHECK(f.answer({0}));  // 먼저 트리거한 W1부터
  CHECK(f.until(HINT_ATTACK_SIGNI));

  lua_State* L = d.lua();
  lua_getglobal(L, "ORDER");
  std::string got;
  for (lua_Integer i = 1; lua_rawgeti(L, -1, i) == LUA_TSTRING; ++i) {
    got += lua_tostring(L, -1);
    got += ' ';
    lua_pop(L, 1);
  }
  lua_pop(L, 2);
  CHECK(got == "A W1 D W2 D ");
  CHECK(f.logs.empty());
}

TEST_CASE("lki: 장을 떠날 때 능력이 없었으면 트리거하지 않는다", "설계: LKI") {
  Fixture f;
  base(f);
  f.signi(301, 1000);
  f.script(301, kDrawOn("EVENT_LEAVE_FIELD"));
  Duel& d = f.start();
  f.put(1, 0, "lrig_center");
  f.fill(100, 0, "main_deck", 5);
  CardIdx with = f.put(301, 0, "signi_left");
  CardIdx without = f.put(301, 0, "signi_center");
  f.single(with, EFFECT_UPDATE_POWER, -5000, 1);
  f.single(without, EFFECT_UPDATE_POWER, -5000, 1);
  f.single(without, EFFECT_LOSE_ABILITY, 0, 1);
  d.test_begin(0, PHASE_END);
  CHECK(f.until(HINT_MAIN));
  CHECK(d.state.cards.get(with).zone == f.zone(0, "ena"));
  CHECK(d.state.cards.get(without).zone == f.zone(0, "ena"));
  CHECK(f.count(0, "hand") == 1);  // 능력이 있던 쪽만 뽑았다
}

TEST_CASE("end: 패 6장이 되게 버리고, 「ターン終了時まで」는 그 뒤에 끝난다", "용어집: エンドフェイズ, WX17-001 FAQ 12") {
  Fixture f;
  base(f);
  f.signi(320, 1000);
  f.script(320, R"(
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetCode(EVENT_TURN_END)
  e1:SetRange(LOCATION_SZONE)
  e1:SetOperation(function(e,tp) SEEN = e:GetHandler():GetPower() end)
  c:RegisterEffect(e1)
end
)");
  Duel& d = f.start();
  CardIdx s = f.put(320, 0, "signi_left");
  f.fill(100, 0, "hand", 8);
  f.single(s, EFFECT_UPDATE_POWER, 3000, 0, RESET_PHASE | PHASE_END);
  d.test_begin(0, PHASE_END);
  CHECK(f.until(HINT_DISCARD));
  CHECK(d.request()->min == 2 && d.request()->max == 2);
  CHECK(d.power_of(s) == 4000);
  CHECK(f.until(HINT_MAIN));
  CHECK(f.count(0, "hand") == 6);
  CHECK(d.power_of(s) == 1000);
  lua_getglobal(d.lua(), "SEEN");
  CHECK(lua_tointeger(d.lua(), -1) == 4000);  // 턴 종료 시 트리거는 효과가 끝나기 전에 처리
  lua_pop(d.lua(), 1);
}

TEST_CASE("main: 리무브는 턴에 한 번, 여러 체를 동시에", "용어집: リムーブする") {
  Fixture f;
  base(f);
  Duel& d = f.start();
  stock(f);
  f.put(1, 0, "lrig_center");
  CardIdx a = f.put(100, 0, "signi_left");
  CardIdx b = f.put(101, 0, "signi_center");
  d.test_begin(0, PHASE_MAIN);
  CHECK(f.until(HINT_MAIN));
  CHECK(f.answer({f.action(ActionKind::Remove)}));
  CHECK(f.until(HINT_REMOVE));
  CHECK(f.answer({a, b}));
  CHECK(f.until(HINT_MAIN));
  CHECK(f.count(0, "trash") == 2);
  CHECK(f.action(ActionKind::Remove) == 0xFFFFFFFF);
}

TEST_CASE("ask: 할 수 있는 게 없으면 묻지 않고 넘어간다", "설계: 묻는 시점") {
  Fixture f;
  f.always_ask = false;
  base(f);
  Duel& d = f.start();
  stock(f);
  f.put(1, 0, "lrig_center");
  f.put(1, 1, "lrig_center");
  d.test_begin(0, PHASE_MAIN);
  CHECK(f.until(HINT_ATTACK_LRIG));  // 메인에서 할 게 없어 바로 어택 페이즈
  CHECK(!f.saw(HINT_MAIN));
  CHECK(d.turn_player == 0);
}

TEST_CASE("trigger: 임의 트리거는 쓸지 묻는다", "설계: 능력 종류 대응 TRIGGER_O") {
  Fixture f;
  base(f);
  f.signi(304, 1000);
  f.script(304, R"(
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e1)
end
)");
  Duel& d = f.start();
  stock(f);
  f.put(1, 0, "lrig_center");
  CardIdx c = f.put(304, 0, "hand");
  d.test_begin(0, PHASE_MAIN);
  CHECK(f.until(HINT_MAIN));
  CHECK(f.answer({f.action(ActionKind::PlaySigni, c, f.zone(0, "signi_left"))}));
  CHECK(f.until(HINT_USE_TRIGGER));
  CHECK(f.answer({1}));
  CHECK(f.until(HINT_MAIN));
  CHECK(f.count(0, "hand") == 1);
}

TEST_CASE("start: 레벨 0 루리그가 여럿이면 1장 또는 3장을 고르고, 3장이면 센터를 고른다", "faq.txt 「ゲーム開始時」 1, 용어집: ピース") {
  Fixture f;
  base(f);
  for (Cid c : {2u, 3u, 4u, 5u}) {
    f.lrig(c, COLOR_WHITE, 0, 0);
    f.cards[c].classes = {"L" + std::to_string(c)};
  }
  f.first = 0;
  Duel& d = f.start();
  std::vector<Cid> main(40, 100);
  d.set_deck(0, main, {2, 3, 4, 5});
  d.set_deck(1, main, {2, 3});
  d.start();
  CHECK(f.until(HINT_START_LRIG));
  CHECK(d.request()->player == 0 && d.request()->max == 3);
  const auto opts = d.request()->options;
  std::string why;
  CHECK(!d.respond(Response{{opts[0], opts[1]}}, &why));  // 2장은 안 된다
  CHECK(f.answer({opts[0], opts[1], opts[3]}));
  CHECK(f.until(HINT_CENTER_LRIG));
  CHECK(f.answer({opts[3]}));
  CHECK(f.until(HINT_START_LRIG));
  CHECK(d.request()->player == 1 && d.request()->max == 1);  // 2장뿐이면 1장
  CHECK(f.answer({d.request()->options[1]}));
  CHECK(f.until(HINT_MAIN));
  CHECK(d.center_lrig(0) == opts[3]);
  CHECK(f.count(0, "lrig_assist_left") == 1 && f.count(0, "lrig_assist_right") == 1);
  CHECK(f.count(0, "lrig_deck") == 1);
  CHECK(d.state.cards.get(d.center_lrig(1)).cid == 3);
  CHECK(f.count(1, "lrig_deck") == 1);
}

TEST_CASE("refresh: 강제 턴 종료 중 새로 트리거한 능력은 처리한다", "용어집: ターンを終了する 2·5, 사용자 결정") {
  Fixture f;
  base(f);
  f.signi(305, 1000);
  f.script(305, kDrawOn("EVENT_TO_TRASH"));
  Duel& d = f.start();
  f.put(1, 0, "lrig_center");
  f.fill(100, 0, "main_deck", 1);
  f.fill(101, 0, "trash", 3);
  f.fill(100, 0, "life_cloth", 3);
  f.fill(100, 1, "main_deck", 5);
  f.fill(100, 0, "hand", 6);
  CardIdx x = f.put(305, 0, "hand");  // 패 7장 + 드로 1장
  d.test_begin(0, PHASE_DRAW);
  CHECK(f.until(HINT_MAIN));
  for (CardIdx c : std::vector<CardIdx>(d.state.zones.get(f.zone(0, "main_deck")).cards))
    d.state.move(c, f.zone(0, "trash"));
  CHECK(f.answer({f.action(ActionKind::EndPhase)}));
  CHECK(f.until(HINT_DISCARD));
  CHECK(d.request()->min == 2);
  std::vector<uint32_t> picks{x};
  for (uint32_t c : d.request()->options)
    if (c != x && picks.size() < 2) picks.push_back(c);
  CHECK(f.answer(picks));
  CHECK(f.until(HINT_MAIN));
  CHECK(d.turn_player == 1);
  CHECK(f.count(0, "hand") == 7);  // 6장 + 버린 카드의 트리거로 1장
}
