#pragma once
#include <vector>

#include "common.h"
#include "effect.h"

namespace wx {

// 이벤트 코드. 트리거 효과의 SetCode에 쓴다.
constexpr uint32_t EVENT_ON_PLAY = 1001;      // 場に出たとき(【出】)
constexpr uint32_t EVENT_LEAVE_FIELD = 1002;  // 場を離れたとき
constexpr uint32_t EVENT_BANISHED = 1003;
constexpr uint32_t EVENT_TO_TRASH = 1004;
constexpr uint32_t EVENT_TO_ENA = 1005;
constexpr uint32_t EVENT_TO_HAND = 1006;
constexpr uint32_t EVENT_DRAW = 1007;
constexpr uint32_t EVENT_ATTACK = 1008;
constexpr uint32_t EVENT_CRUSHED = 1009;      // 라이프 클로스가 크러시됨
constexpr uint32_t EVENT_DAMAGE = 1010;
constexpr uint32_t EVENT_GROW = 1011;
constexpr uint32_t EVENT_REFRESH = 1012;
constexpr uint32_t EVENT_TURN_END = 1013;     // ターン終了時
// 효과 하나로 카드가 1장 이상 메인 덱으로 옮겨졌다(한 효과에 한 번. eg = 옮겨진 카드, rp = 그 효과의 플레이어).
// 덱 → 덱, 루리그 덱으로는 해당하지 않는다(WDK09-013 FAQ 2·3)
constexpr uint32_t EVENT_MOVED_TO_DECK = 1014;
// 【ウィルス】가 하나 치워졌다(하나마다 한 번. ep = 그 존의 주인, ev = 존 번호, rp = 치운 효과의 플레이어)
constexpr uint32_t EVENT_VIRUS_REMOVED = 1015;
// 시그니가 血晶武装状態가 됐다(이미 그 상태였으면 나지 않는다. 용어집: 血晶武装). eg = 그 시그니, ep = 그 컨트롤러
constexpr uint32_t EVENT_BLOOD_ARMED = 1016;
// 효과로 패의 카드를 공개했다(공개 한 번에 한 번. eg = 공개한 패의 카드, ep = 그 패의 주인, rp = 효과의 플레이어).
// 패에 있는 카드 자신의 【自】(range = LOCATION_HAND)도 트리거한다(WDK08-Y12 FAQ 1, WDK08-Y15 「同時に２枚以上公開しても一度」)
constexpr uint32_t EVENT_REVEALED_FROM_HAND = 1017;
// 라이프 클로스에 카드가 더해졌다(1장마다. ep = 그 라이프 클로스의 주인). 라이프 클로스 안에서 순서만 바꾸면 아니다(WD06-007 FAQ 2, WD06-008 FAQ 4)
constexpr uint32_t EVENT_LIFE_ADDED = 1018;
// 라이프 버스트를 발동했다(eg = 그 카드, ep = 주인. WD06-001)
constexpr uint32_t EVENT_LIFEBURST = 1019;
// 《ヘブン》했다(용어집: ヘブン): 크로스 상태의 시그니가 어택했을 때 크로스한 시그니가 모두 다운. eg = 그 시그니들, ep = 컨트롤러
constexpr uint32_t EVENT_HEAVEN = 1020;
// 이 시그니가 라이즈됐다(위에 【ライズ】 시그니가 놓였다). eg = 밑이 된 시그니, 처리에서 Duel.GetRiser() = 위에 놓인 시그니.
// 이미 밑에 있던 카드는 아니다(WX15-043 FAQ)
constexpr uint32_t EVENT_RISEN = 1021;
constexpr uint32_t EVENT_DRAW_ONE = 1022;  // 「カードを１枚引いたとき」: 1장마다. ep = 뽑은 플레이어
// 「ゲームを開始する際に、このルリグを表向きにしたとき」: 트리거가 아니라 오픈할 때 처리 함수를 바로 부른다
constexpr uint32_t EVENT_OPEN = 1023;
constexpr uint32_t EVENT_DRIVE = 1025;  // ドライブ状態になった(eg = 그 시그니나 루리그 하나, ep = 컨트롤러)
// 「あなたがアーツ(スペル)を使用したとき」(eg = 그 카드, ep = 쓴 플레이어). 코스트를 낸 뒤 나고, 그 카드를 처리한 뒤에 발동한다
constexpr uint32_t EVENT_USE_CARD = 1026;
constexpr uint32_t EVENT_BLOOM = 1027;  // 【シード】가 개화해 시그니가 됐다(eg = 그 시그니)
constexpr uint32_t EVENT_ACCE = 1028;   // 【アクセ】가 붙었다(eg = 붙은 쪽 시그니)
constexpr uint32_t EVENT_POWER_REACHED = 1029;  // 파워가 EFFECT_POWER_WATCH의 값 미만에서 그 이상이 됐다(eg = 그 시그니)
constexpr uint32_t EVENT_BATTLE = 1030;  // 시그니끼리 배틀한 뒤(eg = 두 시그니. 배틀로 떠났어도 그 직전 능력으로)
constexpr uint32_t EVENT_DOWN = 1031;      // 효과로 다운 상태가 됐다(코스트·어택은 아니다. eg = 그 카드)
constexpr uint32_t EVENT_GUARDED = 1032;   // 【ガード】했다(ep = 가드한 플레이어)
constexpr uint32_t EVENT_NEGATED = 1033;   // 어택을 효과로 무효로 했다(eg = 어택한 카드, rp = 무효로 한 플레이어)
constexpr uint32_t EVENT_ARTS_HIT = 1034;  // 장의 시그니가 상대 아츠의 효과를 받았다(수치·상태 변경, 이동. eg = 그 시그니)
constexpr uint32_t EVENT_FROZEN = 1035;    // 동결 상태가 됐다(eg = 그 카드)
constexpr uint32_t EVENT_TO_LTRASH = 1036;  // 루리그 트래시에 놓였다(엑시드 코스트면 r에 REASON_EXCEED)
constexpr uint32_t EVENT_VIRUS_PLACED = 1038;  // 【ウィルス】가 놓였다(ep = 그 존의 주인)
constexpr uint32_t EVENT_SHUFFLE = 1040;  // 덱이 셔플됐다(ep = 덱 주인. 리프레시 포함)
constexpr uint32_t EVENT_BEAT = 1039;  // 【ビート】가 됐다(eg = 그 카드)
constexpr uint32_t EVENT_SIGNI_MOVED = 1037;  // 장의 시그니가 효과로 다른 시그니 존으로 옮겨졌다(eg = 그 시그니, rp = 효과의 플레이어)
constexpr uint32_t REASON_EXCEED = 0x400;    // 엑시드 코스트
constexpr uint32_t EVENT_TRAP = 1024;  // 《トラップアイコン》이 발동했다(eg = 그 카드, ep = 주인)
constexpr uint32_t EVENT_PHASE_START = 0x10000;  // + PHASE_* : 그 페이즈 開始時
constexpr uint32_t EVENT_CUSTOM = 0x10000000;    // 스크립트 정의 이벤트

// 능력의 분류(ABILITY_*)
inline uint32_t ability_type_of(const Effect& e) {
  if (e.ability_type) return e.ability_type;
  if (e.registered && !e.is_ability()) return 0;  // 지연 트리거 등
  if (e.type & EFFECT_TYPE_ACTIVATE) return ABILITY_USE;
  if (e.type & EFFECT_TYPE_IGNITION) return ABILITY_IGNITION;
  if (e.type & EFFECT_TYPE_LIFEBURST) return ABILITY_LIFEBURST;
  if (e.type & EFFECT_TYPE_TRAP) return ABILITY_TRAP;
  if (e.is_trigger())  // 「このシグニが場に出たとき」의 【自】는 SetAbilityType(ABILITY_AUTO)
    return e.code == EVENT_ON_PLAY && (e.type & EFFECT_TYPE_SINGLE) ? ABILITY_ON_PLAY : ABILITY_AUTO;
  if (e.code == EFFECT_ACCE || e.code == EFFECT_RISE || e.code == EFFECT_RESONA || e.code == EFFECT_CROSS || e.code == EFFECT_GROW_PROC) return 0;
  return ABILITY_CONTINUOUS;
}

// 이유
constexpr uint32_t REASON_RULE = 0x1;
constexpr uint32_t REASON_EFFECT = 0x2;
constexpr uint32_t REASON_BATTLE = 0x4;
constexpr uint32_t REASON_COST = 0x8;
constexpr uint32_t REASON_DISCARD = 0x10;
constexpr uint32_t REASON_DAMAGE = 0x20;
constexpr uint32_t REASON_RESONA = 0x40;  // レゾナの出現条件
constexpr uint32_t REASON_GUARD = 0x100;  // 【ガード】로 버렸다(ガードステップ)
constexpr uint32_t REASON_LANCER = 0x200;  // 【ランサー】·【Ｓランサー】로 크러시했다(EVENT_CRUSHED의 r)
constexpr uint32_t REASON_BANISH = 0x80;  // 바니시로 옮겨졌다(바니시 대신 트래시에 놓여도)

struct Event {
  uint32_t code = 0;
  std::vector<CardIdx> cards;  // eg
  PlayerId player = kNoPlayer;  // ep
  int32_t value = 0;            // ev
  EffectId reason_effect = kNoEffect;  // re
  uint32_t reason = 0;                 // r
  PlayerId reason_player = kNoPlayer;  // rp
  CardIdx source = kNoCard;  // 바니시한 시그니, 크러시한 시그니·루리그
};

// 코어가 직접 처리하는 트리거 능력(스크립트 없음)
enum class Builtin : uint8_t { None, LancerCrush, SLancer, TrapOpen };

// 트리거해서 발동을 기다리는 능력
struct Pending {
  Builtin builtin = Builtin::None;
  EffectId effect = kNoEffect;
  CardIdx handler = kNoCard;
  PlayerId player = kNoPlayer;
  Event event;
  CardIdx trap_card = kNoCard;   // 《トラップアイコン》이면 그 카드(처리 뒤 트래시로)
  ObjId trap_oid = kNoObj;       // TrapOpen: 트리거했을 때의 객체
  CardIdx burst_card = kNoCard;  // 라이프 버스트면 그 카드(처리 뒤 에나로)
};

}  // namespace wx
