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
  HINT_MODE,    // 모드 선택(「以下の２つから１つを選ぶ」). 선택지 = 0부터 번호
  HINT_SELECT,  // 효과의 카드 선택(대상 아님)
  HINT_ZONE,    // 놓을 존 고르기. 선택지 = 존 번호
  HINT_EXCEED,  // 엑시드 코스트로 루리그 아래 카드 고르기
  HINT_ENCORE,  // 앙코르 코스트를 낼까(예/아니오)
  HINT_DECLARE, // 숫자 선언. 선택지 = 그 숫자
  HINT_ORDER,   // 순서 정하기(고른 순서대로 놓는다)
  HINT_BET,     // ベット할까(예/아니오. 용어집: ベット)
};

struct Request {
  ReqType type = ReqType::YesNo;
  PlayerId player = 0;
  uint32_t hint = HINT_NONE;
  std::vector<uint32_t> options;
  uint32_t min = 1, max = 1;
  bool cancelable = false;  // 확정 전 선택이면 취소해서 처음으로 돌아갈 수 있다(아레나식)
  // 무엇에 대한 요청인가(카드). 비어 있으면 처리 중인 효과의 카드로 채운다
  CardIdx source = kNoCard;
  // SELECT_OPTION: 선택지마다의 카드(동시 트리거 순서 등). 비어 있으면 없음
  std::vector<CardIdx> option_cards;
  // 효과 설명 번호(0 = 없음). source_desc가 비면 처리 중인 효과의 것으로 채운다
  uint32_t source_desc = 0;
  std::vector<uint32_t> option_descs;  // SELECT_OPTION 선택지마다
  // 개수·후보 검사 뒤의 추가 검증(에나 지불 등). 거부하면 이유를 채운다.
  std::function<bool(const std::vector<uint32_t>&, std::string&)> check;
};

struct Response {
  std::vector<uint32_t> picks;
  bool cancel = false;
};

bool validate(const Request& req, const Response& res, std::string& why);

enum class ActionKind : uint8_t { EndPhase, PlaySigni, Remove, UseCard, UseAbility, Grow, PlayKey };

struct Action {
  ActionKind kind = ActionKind::EndPhase;
  CardIdx card = kNoCard;
  ZoneId zone = kNoZone;
  EffectId effect = 0;  // UseCard: 카드의 ACTIVATE 효과, UseAbility: 【起】
  // Grow: card = 루리그 덱의 그로우할 카드, zone = 그 아래가 될 루리그가 있는 존(어시스트)
  PlayerId player = 0;
};

}  // namespace wx
