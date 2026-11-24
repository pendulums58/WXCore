#pragma once
#include <string>
#include <string_view>
#include <vector>

#include "common.h"

namespace wx {

enum class ZoneKind : uint8_t {
  MainDeck,
  LifeCloth,
  LrigDeck,
  Hand,
  Trash,
  LrigTrash,
  Ena,
  Check,
  Exclude,
  LrigCenter,
  LrigAssist,
  Key,    // 루리그 존(루리그 옆). 용어집: キー
  Signi,
  Cheer,
};

enum class ZoneVis : uint8_t {
  Public,     // 모두 공개
  OwnerOnly,  // 주인만(패, 루리그 덱)
  Hidden,     // 아무도 못 봄(덱, 라이프). 카드별 known_by로 예외
};

// 존 그룹. 효과는 개별 존이나 그룹을 대상으로 지정한다.
enum ZoneGroup : uint32_t {
  ZG_NONE = 0,
  ZG_FIELD = 1u << 0,  // 場 = 시그니 존 + 치어 존 + 루리그 존 (용어집: 場)
  ZG_SIGNI = 1u << 1,
  ZG_LRIG = 1u << 2,   // 루리그 존(센터·어시스트·키)
};

// 스크립트용 위치 비트(LOCATION_*). 존 종류 하나가 비트 하나.
constexpr uint32_t loc_bit(ZoneKind k) { return 1u << static_cast<uint32_t>(k); }

enum Location : uint32_t {
  LOCATION_MDECK = loc_bit(ZoneKind::MainDeck),
  LOCATION_LIFE = loc_bit(ZoneKind::LifeCloth),
  LOCATION_LDECK = loc_bit(ZoneKind::LrigDeck),
  LOCATION_HAND = loc_bit(ZoneKind::Hand),
  LOCATION_TRASH = loc_bit(ZoneKind::Trash),
  LOCATION_LTRASH = loc_bit(ZoneKind::LrigTrash),
  LOCATION_ENA = loc_bit(ZoneKind::Ena),
  LOCATION_CHECK = loc_bit(ZoneKind::Check),
  LOCATION_EXCLUDE = loc_bit(ZoneKind::Exclude),
  LOCATION_LRIG = loc_bit(ZoneKind::LrigCenter),
  LOCATION_ASSIST = loc_bit(ZoneKind::LrigAssist),
  LOCATION_KEY = loc_bit(ZoneKind::Key),
  LOCATION_SIGNI = loc_bit(ZoneKind::Signi),
  LOCATION_CHEER = loc_bit(ZoneKind::Cheer),
  // 【アクセ】로 시그니에 붙어 있다(존이 아니라 붙은 카드의 위치). 「これにアクセされているシグニ…」의 SetRange
  LOCATION_ACCE = 1u << 30,
  // 존의 세트 층(【トラップ】). 시그니 존에 있지만 시그니가 아니다
  LOCATION_TRAP = 1u << 29,
  // 장의 시그니(시그니 존 + 치어 존). 용어집: チアゾーン 1
  LOCATION_SZONE = LOCATION_SIGNI | LOCATION_CHEER,
  // 장 전체. 용어집: 場
  LOCATION_FIELD = LOCATION_SZONE | LOCATION_LRIG | LOCATION_ASSIST | LOCATION_KEY,
};

struct Zone {
  ZoneId id = kNoZone;
  PlayerId owner = kNoPlayer;
  ZoneKind kind = ZoneKind::Trash;
  std::string name;
  uint32_t groups = ZG_NONE;
  ZoneVis vis = ZoneVis::Public;
  bool ordered = false;  // 덱·라이프 클로스만 순서가 의미 있다
  bool slot = false;     // 한 칸짜리 존(시그니·치어·루리그·키)
  bool absent = false;   // 지워진 존. 이름과 링크는 남는다(WXK03-005 FAQ 2·3)
  bool extra = false;    // 효과로 늘어난 존
  bool gate = false;     // 【ゲート】. 존 하나에 하나까지(WDK09-001 FAQ 1). 카드가 아닌 표식
  bool virus = false;    // 【ウィルス】. 시그니 존 하나에 하나까지(용어집: ウィルス). 같은 존의 시그니는 감염 상태

  std::vector<ZoneId> adjacent;  // 인접 링크(데이터)
  ZoneId front = kNoZone;        // 정면 링크(거울 대칭)
  ZoneId left = kNoZone, right = kNoZone;  // 바로 왼쪽·오른쪽(주인 기준). 크로스 조건이 쓴다

  // 들어 있는 객체. 순서 있는 존은 back()이 맨 위.
  std::vector<CardIdx> cards;
  // 세트 층: 트랩·씨앗·매직 박스 한 장
  CardIdx set_card = kNoCard;
  // 장을 떠난 객체가 남긴 아래 카드·붙은 카드. 룰 처리 3이 치운다.
  std::vector<CardIdx> leftovers;
};

class ZoneRegistry {
 public:
  // 플레이어 두 명의 기본 배치(시그니 존 3칸)를 등록한다.
  void init_default();

  ZoneId add(Zone z);
  Zone& get(ZoneId id) { return zones_[id]; }
  const Zone& get(ZoneId id) const { return zones_[id]; }
  size_t size() const { return zones_.size(); }

  ZoneId find(PlayerId p, std::string_view name) const;
  // 존이 하나뿐인 종류(덱, 패, 트래시…)용. 여러 개면 처음 것.
  ZoneId find(PlayerId p, ZoneKind kind) const;

  std::vector<ZoneId> zones_of(PlayerId p, ZoneKind kind, bool include_absent = false) const;
  std::vector<ZoneId> in_group(PlayerId p, uint32_t groups, bool include_absent = false) const;
  bool has_group(ZoneId id, uint32_t groups) const { return (get(id).groups & groups) != 0; }

  void link_adjacent(ZoneId a, ZoneId b);
  void link_front(ZoneId a, ZoneId b);
  // 왼쪽 존과 바로 오른쪽 존. 인접도 같이 건다
  void link_side(ZoneId left, ZoneId right);

  // 지워진 존은 결과에서 빠진다. 지워진 존을 사이에 둔 존끼리 새로 인접하지 않는다.
  std::vector<ZoneId> adjacent(ZoneId id) const;
  // 자신이나 정면 존이 지워졌으면 kNoZone.
  ZoneId front(ZoneId id) const;
  // 바로 왼쪽·오른쪽 존. 없거나 자신·그 존이 지워졌으면 kNoZone
  ZoneId left(ZoneId id) const { return side(id, zones_[id].left); }
  ZoneId right(ZoneId id) const { return side(id, zones_[id].right); }

  // 플래그만 바꾼다. 안에 있던 카드 처리는 상태 쪽 연산이 한다.
  void set_absent(ZoneId id, bool absent) { zones_[id].absent = absent; }

 private:
  ZoneId side(ZoneId id, ZoneId to) const {
    return zones_[id].absent || to == kNoZone || zones_[to].absent ? kNoZone : to;
  }
  std::vector<Zone> zones_;
};

}  // namespace wx
