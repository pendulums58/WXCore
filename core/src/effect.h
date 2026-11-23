#pragma once
#include <deque>
#include <string>
#include <utility>
#include <vector>

#include "common.h"

namespace wx {

using EffectId = uint32_t;
constexpr EffectId kNoEffect = 0;

// 효과 타입(유프로식). SINGLE/FIELD만 있고 발동 플래그가 없으면 지속 효과다.
enum EffectType : uint32_t {
  EFFECT_TYPE_SINGLE = 0x1,
  EFFECT_TYPE_FIELD = 0x2,
  EFFECT_TYPE_ACTIVATE = 0x10,   // 아츠·스펠·피스
  EFFECT_TYPE_IGNITION = 0x40,   // 【起】
  EFFECT_TYPE_TRIGGER_O = 0x80,  // 【自】 임의
  EFFECT_TYPE_TRIGGER_F = 0x200, // 【自】 강제
  EFFECT_TYPE_LIFEBURST = 0x400,
};
constexpr uint32_t kActionTypes = EFFECT_TYPE_ACTIVATE | EFFECT_TYPE_IGNITION | EFFECT_TYPE_TRIGGER_O |
                                  EFFECT_TYPE_TRIGGER_F | EFFECT_TYPE_LIFEBURST;

// 효과 코드. 지속 효과는 코드가 정하는 레이어에서 적용된다(설계: 레이어).
enum EffectCode : uint32_t {
  // 레이어 1: 정체·복사
  EFFECT_COPY = 1,  // value = cid. 그 카드와 같은 카드가 된다
  // 레이어 2: 특성
  EFFECT_CHANGE_COLOR = 100,
  EFFECT_ADD_COLOR = 101,
  EFFECT_ADD_CLASS = 102,  // value = 클래스 코드(aux.Class(sys, race))
  EFFECT_CHANGE_LEVEL = 103,
  EFFECT_UPDATE_LEVEL = 104,
  EFFECT_UPDATE_LIMIT = 105,
  // 레이어 3: 능력 획득·상실
  EFFECT_LOSE_ABILITY = 200,
  // 레이어 4·5: 파워
  EFFECT_SET_POWER = 300,
  EFFECT_UPDATE_POWER = 301,
  // 억제(何もしない). 코어 내부용 — 스크립트는 Duel 함수로 만든다
  EFFECT_SUPPRESS = 400,

  EFFECT_MULTI_ENA = 500,  // 【マルチエナ】: 에나 지불 때 모든 색(range = LOCATION_ENA)

  // 키워드 능력(용어집). 인쇄하거나 「得る」로 부여한다
  EFFECT_LANCER = 600,        // 【ランサー】: 배틀로 시그니를 바니시하면 라이프 클로스 1장 크러시(트리거)
  EFFECT_DOUBLE_CRUSH = 601,  // 【ダブルクラッシュ】: 어택 데미지로 2장 크러시
  EFFECT_ASSASSIN = 602,      // 【アサシン】: 정면 시그니가 없는 것처럼 데미지
  EFFECT_S_LANCER = 603,      // 【Ｓランサー】: 【ランサー】와 같고, 라이프 클로스가 없으면 대신 데미지. 둘 다 있으면 이쪽 1번(용어집: Sランサー)

  // 「…は以下の能力を得る」(FIELD, 동적). SetLabelObject의 효과를 대상마다 복제해 부여한다
  EFFECT_GRANT = 700,

  EFFECT_CANNOT_ATTACK = 800,       // 「アタックできない」
  EFFECT_UPDATE_HAND_LIMIT = 801,   // 손패 상한 ±(FIELD, SetTargetRange(1,0)=자기, (0,1)=상대. WDK09-009 FAQ 1)
  EFFECT_CANNOT_GUARD = 802,
  EFFECT_CANNOT_BANISH = 803,       // 「バニッシュされない」: 효과·배틀·룰 처리(파워 0 이하) 모두(룰 해설 160513_02 問1, WDK08-Y07 FAQ 3)
  EFFECT_PREVENT_DAMAGE = 804,      // 「次にダメージを受ける場合、代わりにダメージを受けない」(플레이어 효과, 한 번 쓰면 사라진다. WDK08-L06)        // 「レベルＮのシグニで【ガード】ができない」(플레이어 효과, value = 레벨. WDK-F03-09)
};

// 리셋. RESET_PHASE + PHASE_*: 그 페이즈 끝에 사라진다.
// 장을 떠나거나 뒷면이 되면 생성 효과는 객체와 함께 자동으로 끊기므로
// RESET_EVENT/RESETS_STANDARD는 유프로 스크립트 호환용으로만 받는다.
// RESET_PHASE | PHASE_END처럼 섞어 쓰므로 enum이 아니라 정수 상수로 둔다.
constexpr uint32_t RESET_PHASE = 0x40000000;
constexpr uint32_t RESET_EVENT = 0x00001000;
constexpr uint32_t RESETS_STANDARD = 0x01fe0000;

constexpr uint32_t PHASE_UP = 0x01;
constexpr uint32_t PHASE_DRAW = 0x02;
constexpr uint32_t PHASE_ENA = 0x04;
constexpr uint32_t PHASE_GROW = 0x08;
constexpr uint32_t PHASE_MAIN = 0x10;
constexpr uint32_t PHASE_ATTACK = 0x20;
constexpr uint32_t PHASE_END = 0x40;

struct Effect {
  EffectId id = kNoEffect;
  uint32_t type = 0;
  uint32_t code = 0;
  uint32_t property = 0;

  CardIdx owner_card = kNoCard;  // 만든 카드(e:GetOwner)
  CardIdx handler = kNoCard;     // 등록된 카드. kNoCard면 플레이어에 등록
  PlayerId owner_player = kNoPlayer;

  // 출처 분류. initial_effect 안에서 등록되면 인쇄(복사로 돌아도 인쇄).
  bool printed = false;
  bool granted = false;          // 능력 부여로 등록된 능력
  Cid text_cid = 0;              // 인쇄: 어느 텍스트의 능력인가
  EffectId copy_of = kNoEffect;  // 복사로 생긴 인쇄 효과면 그 복사 효과
  ObjId bind_oid = kNoObj;       // 생성: 등록 당시 객체. 객체가 바뀌면 끊긴다
  uint64_t timestamp = 0;        // 생성 효과의 등록 시각

  uint32_t range = 0;  // 핸들러가 있어야 하는 LOCATION. 0 = 어디서나
  uint32_t target_self = 0, target_opp = 0;  // FIELD 대상 범위

  int32_t value = 0;
  int value_ref = 0;      // Lua 함수(e,c) → 값
  int target_ref = 0;     // 지속 FIELD: (e,c) → bool 대상 필터. 트리거: (e,tp,eg,ep,ev,re,r,rp,chk)
  int condition_ref = 0;  // Lua 함수(e) → bool. 트리거는 (e,tp,eg,ep,ev,re,r,rp)
  int operation_ref = 0;  // Lua 함수(e,tp,eg,ep,ev,re,r,rp)
  int cost_ref = 0;       // 에나 외 코스트. 확정 뒤에 돈다
  std::string ena_cost;   // 【起】의 에나 코스트. 아츠·스펠은 카드 데이터의 비용
  uint32_t timing = 0;    // 【起】의 사용 타이밍(TIMING_*). 0이면 메인 페이즈

  uint32_t reset = 0;
  uint32_t reset_count = 1;

  int64_t label = 0;
  uint32_t desc = 0;  // 효과 설명 번호(aux.Ability·aux.Stringid). 0 = 없음(설계: 효과 설명 문자열)

  // 《ターン1回》·《ゲーム1回》(용어집: ターン１回, ゲーム１回). 0 = 제한 없음
  uint32_t count_limit = 0;
  bool count_game = false;
  uint32_t count_used = 0;
  ObjId count_oid = kNoObj;  // 센 객체. 장을 떠났다 오면 새 객체라 다시 센다(턴 제한만)

  uint32_t coin_cost = 0;    // 코인 코스트(プライマル 등)
  uint32_t exceed = 0;       // エクシードＮ
  uint32_t encore = 0;       // アンコール 코인 수(아츠)
  uint32_t bet = 0;          // ベット 코인 수(아츠. 용어집: ベット)
  bool has_bet_cost = false;  // ベット하면 사용 코스트가 bet_cost로 바뀐다(WDK08-Y06 「ベットする場合、使用コストは…になる」)
  std::string bet_cost;

  EffectId label_effect = kNoEffect;  // SetLabelObject(EFFECT_GRANT의 원형)
  EffectId grant_parent = kNoEffect;  // EFFECT_GRANT가 만든 복제면 그 부여 효과

  // EFFECT_SUPPRESS: 억제하는 (효과, 객체). 객체 kNoObj = 객체 무관(생성 효과)
  std::vector<std::pair<EffectId, ObjId>> snapshot;

  bool registered = false;
  bool deleted = false;

  bool is_continuous() const { return (type & kActionTypes) == 0; }
  bool is_ability() const { return printed || granted; }
  bool is_trigger() const { return (type & (EFFECT_TYPE_TRIGGER_F | EFFECT_TYPE_TRIGGER_O)) != 0; }
};

class EffectTable {
 public:
  EffectId create();
  Effect* get(EffectId id) { return valid(id) ? &list_[id - 1] : nullptr; }
  const Effect* get(EffectId id) const { return valid(id) ? &list_[id - 1] : nullptr; }
  size_t size() const { return list_.size(); }

  template <class F>
  void for_each(F&& f) {
    for (auto& e : list_)
      if (e.registered && !e.deleted) f(e);
  }

 private:
  bool valid(EffectId id) const { return id != kNoEffect && id <= list_.size(); }
  std::deque<Effect> list_;  // 추가해도 참조가 안 깨진다
};

}  // namespace wx
