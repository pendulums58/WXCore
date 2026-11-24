#pragma once
#include <functional>

#include "card.h"
#include "rng.h"
#include "zone.h"

namespace wx {

enum class Pos : uint8_t { Top, Bottom };

// 카드 위치·정체가 바뀔 때마다 훅으로 넘기는 기록. 메시지(가시성)는 이걸로 만든다.
enum class MoveKind : uint8_t { Move, Under, Attach, FaceDown, Set, Seed };
struct MoveRecord {
  CardIdx card = kNoCard;
  MoveKind kind = MoveKind::Move;
  ObjId old_oid = kNoObj, new_oid = kNoObj;
  ZoneId from = kNoZone, to = kNoZone;
  Pos pos = Pos::Top;
  CardIdx host = kNoCard;
  uint8_t seen_before = 0, seen_after = 0;  // bit p: 플레이어 p가 그 카드를 안다
  bool public_before = false, public_after = false;
};

// 게임 상태와 그 위의 기본 연산. 트리거·LKI는 상위 계층(대전 진행)이 붙인다.
class State {
 public:
  explicit State(uint64_t seed);

  Rng rng;
  ZoneRegistry zones;
  CardTable cards;

  // 대전 준비·테스트 모드용. 존에 바로 카드를 만든다.
  CardIdx create_card(Cid cid, PlayerId owner, ZoneId zone, Pos pos = Pos::Top, uint16_t print = 1);

  // 카드를 옮긴다. 장 안 이동이면 같은 객체, 그 외에는 새 객체(용어집: 領域, チアゾーン Q).
  // 장을 떠나면 아래 카드·붙은 카드는 원래 존의 leftovers로 남는다(룰 처리 3이 치운다).
  void move(CardIdx c, ZoneId to, Pos pos = Pos::Top);

  // 장의 객체 아래에 두거나(라이즈 등) 붙인다(악세·참·소울). 옮겨진 카드는 새 객체.
  // 존의 아래 n장만 섞는다(인지 기록을 지우고 객체 번호를 새로 준다)
  void shuffle_bottom(ZoneId zone, size_t n);
  // base와 그 아래 카드를 host 아래로 옮긴다(그로우·라이즈). base에 붙은 카드는 남는다(룰 처리 3)
  void stack_on(CardIdx base, CardIdx host);
  void put_under(CardIdx c, CardIdx host);
  void attach(CardIdx c, CardIdx host, bool acce = false);
  bool has_acce(CardIdx host) const;
  CardIdx charm_of(CardIdx host) const;  // 없으면 kNoCard
  // 장을 떠난 시그니에 붙어 있던·아래에 있던 카드(룰 처리 3 전). 장의 시그니가 아니다
  bool is_leftover(CardIdx c) const;
  // 존의 세트 층에 뒷면으로 둔다(【トラップ】). 주인은 언제나 볼 수 있다
  void set_face_down(CardIdx c, ZoneId z, bool seed = false);
  bool is_set(CardIdx c) const;   // 세트 층의 카드(【トラップ】·【シード】)
  bool is_seed(CardIdx c) const;
  void bloom(CardIdx c);  // 【シード】를 앞면으로 해서 그 존의 시그니로(장에 새로 나온 것이 아니다)

  // 뒷면으로 만든다. 새 객체가 되고, 앞면을 볼 수 있던 플레이어는 계속 안다.
  void turn_face_down(CardIdx c);

  // 셔플. 그 존 카드의 인지 기록을 지운다.
  void shuffle(ZoneId z);

  // 그 플레이어가 이 카드를 볼 수 있는가(메시지 가시성의 기준).
  bool can_see(PlayerId p, CardIdx c) const;
  // 지금 위치에서 이 카드를 볼 수 있는 플레이어(bit). 인지 기록은 빼고
  uint8_t viewers(CardIdx c) const;

  std::function<void(const MoveRecord&)> on_move;
  std::function<void(ZoneId)> on_shuffle;

 private:
  void detach_from_source(CardIdx c);
  MoveRecord begin_record(CardIdx c, MoveKind kind) const;
  void finish_record(MoveRecord& r);
  void host_card(CardIdx c, CardIdx host, bool under);
};

}  // namespace wx
