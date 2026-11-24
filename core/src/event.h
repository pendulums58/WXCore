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
constexpr uint32_t EVENT_PHASE_START = 0x10000;  // + PHASE_* : 그 페이즈 開始時
constexpr uint32_t EVENT_CUSTOM = 0x10000000;    // 스크립트 정의 이벤트

// 이유
constexpr uint32_t REASON_RULE = 0x1;
constexpr uint32_t REASON_EFFECT = 0x2;
constexpr uint32_t REASON_BATTLE = 0x4;
constexpr uint32_t REASON_COST = 0x8;
constexpr uint32_t REASON_DISCARD = 0x10;
constexpr uint32_t REASON_DAMAGE = 0x20;

struct Event {
  uint32_t code = 0;
  std::vector<CardIdx> cards;  // eg
  PlayerId player = kNoPlayer;  // ep
  int32_t value = 0;            // ev
  EffectId reason_effect = kNoEffect;  // re
  uint32_t reason = 0;                 // r
  PlayerId reason_player = kNoPlayer;  // rp
};

// 코어가 직접 처리하는 트리거 능력(스크립트 없음)
enum class Builtin : uint8_t { None, LancerCrush, SLancer };

// 트리거해서 발동을 기다리는 능력
struct Pending {
  Builtin builtin = Builtin::None;
  EffectId effect = kNoEffect;
  CardIdx handler = kNoCard;
  PlayerId player = kNoPlayer;
  Event event;
  CardIdx burst_card = kNoCard;  // 라이프 버스트면 그 카드(처리 뒤 에나로)
};

}  // namespace wx
