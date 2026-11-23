#pragma once
#include <unordered_map>
#include <vector>

#include "common.h"

namespace wx {

// 카드 상태 플래그. 상태는 효과가 아니다(설계: 효과 모델).
enum CardFlag : uint32_t {
  CF_DOWN = 1u << 0,
  CF_FROZEN = 1u << 1,
  CF_INFECTED = 1u << 2,
  CF_CROSS = 1u << 3,
  CF_DRIVE = 1u << 4,
  CF_BLOOD = 1u << 5,  // 血晶武装状態: 장을 떠날 때까지(밑의 카드가 없어져도. 용어집: 血晶武装)
  CF_BLOOD_ARMED = 1u << 5,  // 血晶武装
  // 효과로 크러시된 카드: 에나로 갈 때 대신 트래시에 놓고 덱 위 1장을 라이프 클로스에(WD06-009 幻水 シィラ). 내부용
  CF_CRUSH_REFILL = 1u << 6,
};

struct Card {
  CardIdx idx = kNoCard;
  Cid cid = 0;
  PlayerId owner = kNoPlayer;
  PlayerId controller = kNoPlayer;
  ObjId oid = kNoObj;
  uint64_t obj_time = 0;  // 지금 객체가 생긴 시각. 인쇄 효과의 타임스탬프로 쓴다
  ZoneId zone = kNoZone;
  uint32_t prev_loc = 0;  // 직전에 있던 곳(LOCATION_* 비트). 「デッキから場に出た」「場から手札に戻った」
  bool face_up = false;
  uint8_t known_by = 0;  // bit p: 플레이어 p가 이 카드가 뭔지 안다. 셔플하면 0
  uint32_t flags = 0;
  uint16_t print = 1;  // 판본(prints.idx). 덱에서 정한다. 화면용이라 룰과 무관하다

  std::vector<CardIdx> under;     // 아래 카드(순서 있음, back()이 맨 위 바로 아래)
  std::vector<CardIdx> attached;  // 붙은 카드(악세·참·소울)
  CardIdx host = kNoCard;         // 이 카드가 아래/붙은 카드일 때 주인 카드
};

class CardTable {
 public:
  CardIdx create(Cid cid, PlayerId owner);
  Card& get(CardIdx i) { return cards_[i]; }
  const Card& get(CardIdx i) const { return cards_[i]; }
  size_t size() const { return cards_.size(); }

  // 객체 번호로 찾는다. 이미 새 객체가 된 번호면 nullptr.
  Card* by_oid(ObjId oid);
  // 새 객체 번호를 발급한다. 이전 번호는 끊긴다.
  void renew(CardIdx i);

  // 대전 시계. 객체 생성과 효과 등록이 같은 시계를 쓴다(타임스탬프).
  uint64_t tick() { return ++clock_; }

 private:
  std::vector<Card> cards_;
  std::unordered_map<ObjId, CardIdx> by_oid_;
  ObjId next_oid_ = 1;
  uint64_t clock_ = 0;
};

}  // namespace wx
