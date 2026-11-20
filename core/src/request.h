#pragma once
// 선택 요청. 코어는 후보와 개수 조건을 보내고, 응답을 검증한다(propose → validate).
// 메시지·가시성·확정 전 취소는 1d에서 붙인다.
#include <functional>
#include <string>
#include <vector>

#include "common.h"
#include "effect.h"

namespace wx {

enum class ReqType : uint8_t {
  YesNo,         // options = {0,1}, 하나 고름
  SelectCards,   // options = CardIdx
  SelectOption,  // options = 선택지 번호(트리거 순서 등)
  SelectAction,  // options = actions() 인덱스
};

enum ReqHint : uint32_t {
  HINT_NONE,
  HINT_MULLIGAN,
  HINT_START_LRIG,
  HINT_CENTER_LRIG,
  HINT_ENA_CHARGE,
  HINT_GROW,
  HINT_PAY_ENA,
  HINT_MAIN,
  HINT_REMOVE,
  HINT_ATTACK_SIGNI,
  HINT_ATTACK_LRIG,
  HINT_GUARD,
  HINT_DISCARD,
  HINT_TRIGGER_ORDER,
  HINT_USE_TRIGGER,
  HINT_LIFEBURST,
  HINT_RULE_TRASH,
  HINT_SCRIPT,
  HINT_PRE_ATTACK,  // 프리어택 스텝(턴 플레이어)
  HINT_DEFENSE,     // 디펜스 스텝(비턴 플레이어)
  HINT_CUTIN,       // 스펠 컷인
  HINT_TARGET,
};

struct Request {
  ReqType type = ReqType::YesNo;
  PlayerId player = 0;
  uint32_t hint = HINT_NONE;
  std::vector<uint32_t> options;
  uint32_t min = 1, max = 1;
  bool cancelable = false;  // 확정 전 선택이면 취소해서 처음으로 돌아갈 수 있다(아레나식)
  // 개수·후보 검사 뒤의 추가 검증(에나 지불 등). 거부하면 이유를 채운다.
  std::function<bool(const std::vector<uint32_t>&, std::string&)> check;
};

struct Response {
  std::vector<uint32_t> picks;
  bool cancel = false;
};

bool validate(const Request& req, const Response& res, std::string& why);

enum class ActionKind : uint8_t { EndPhase, PlaySigni, Remove, UseCard, UseAbility };

struct Action {
  ActionKind kind = ActionKind::EndPhase;
  CardIdx card = kNoCard;
  ZoneId zone = kNoZone;
  EffectId effect = 0;  // UseCard: 카드의 ACTIVATE 효과, UseAbility: 【起】
  PlayerId player = 0;
};

}  // namespace wx
