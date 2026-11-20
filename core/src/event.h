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

// 트리거해서 발동을 기다리는 능력
struct Pending {
  EffectId effect = kNoEffect;
  CardIdx handler = kNoCard;
  PlayerId player = kNoPlayer;
  Event event;
  CardIdx burst_card = kNoCard;  // 라이프 버스트면 그 카드(처리 뒤 에나로)
};

}  // namespace wx
