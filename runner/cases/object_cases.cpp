#include "state.h"
#include "test.h"

using namespace wx;

namespace {
ZoneId Z(State& s, PlayerId p, const char* name) { return s.zones.find(p, name); }
}  // namespace

TEST_CASE("obj: 다른 영역으로 옮기면 새 객체", "용어집: 領域") {
  State s(1);
  CardIdx c = s.create_card(100, 0, Z(s, 0, "hand"));
  ObjId before = s.cards.get(c).oid;
  s.move(c, Z(s, 0, "signi_left"));
  CHECK(s.cards.get(c).oid != before);
  CHECK(s.cards.by_oid(before) == nullptr);
}

TEST_CASE("obj: 시그니 존끼리 이동은 같은 객체, 아래 카드도 같이", "WXK07-037 FAQ 1, 용어집: 下に置かれているカード") {
  State s(1);
  ZoneId l = Z(s, 0, "signi_left"), r = Z(s, 0, "signi_right");
  CardIdx c = s.create_card(100, 0, l);
  CardIdx u = s.create_card(101, 0, Z(s, 0, "trash"));
  s.put_under(u, c);
  CHECK(s.zones.get(Z(s, 0, "trash")).cards.empty());

  s.cards.get(c).flags |= CF_DOWN;
  ObjId before = s.cards.get(c).oid;
  s.move(c, r);
  CHECK(s.cards.get(c).oid == before);
  CHECK(s.cards.get(c).flags & CF_DOWN);
  CHECK(s.cards.get(c).under.size() == 1);
  CHECK(s.cards.get(u).zone == r);
  CHECK(s.zones.get(l).cards.empty());
}

TEST_CASE("obj: 시그니 존 → 치어 존은 장을 떠나지 않는다", "용어집: チアゾーン Q") {
  State s(1);
  CardIdx c = s.create_card(100, 0, Z(s, 0, "signi_center"));
  ObjId before = s.cards.get(c).oid;
  s.move(c, Z(s, 0, "cheer"));
  CHECK(s.cards.get(c).oid == before);
}

TEST_CASE("obj: 장을 떠나면 아래·붙은 카드는 남고 상태는 초기화", "용어집: ルール処理 3") {
  State s(1);
  ZoneId l = Z(s, 0, "signi_left");
  CardIdx c = s.create_card(100, 0, l);
  CardIdx acce = s.create_card(102, 0, Z(s, 0, "trash"));
  s.attach(acce, c);
  s.cards.get(c).flags |= CF_FROZEN;

  s.move(c, Z(s, 0, "trash"));
  CHECK(s.cards.get(c).attached.empty());
  CHECK(s.cards.get(c).flags == 0);
  CHECK(s.zones.get(l).leftovers.size() == 1);
  CHECK(s.cards.get(acce).host == kNoCard);
}

TEST_CASE("obj: 뒷면이 되면 새 객체, 본 사람은 계속 안다", "설계: 객체 동일성 / 정보 공개") {
  State s(1);
  CardIdx c = s.create_card(100, 0, Z(s, 0, "signi_left"));
  ObjId before = s.cards.get(c).oid;
  s.turn_face_down(c);
  CHECK(s.cards.get(c).oid != before);
  CHECK(s.can_see(0, c));
  CHECK(s.can_see(1, c));
}

TEST_CASE("info: 패는 주인만, 공개 영역은 모두", "설계: 정보 공개") {
  State s(1);
  CardIdx h = s.create_card(100, 0, Z(s, 0, "hand"));
  CardIdx t = s.create_card(101, 0, Z(s, 0, "trash"));
  CardIdx d = s.create_card(102, 0, Z(s, 0, "main_deck"));
  CHECK(s.can_see(0, h) && !s.can_see(1, h));
  CHECK(s.can_see(0, t) && s.can_see(1, t));
  CHECK(!s.can_see(0, d) && !s.can_see(1, d));
}

TEST_CASE("info: 공개된 카드를 덱 위에 두면 알고, 셔플하면 잊는다", "설계: 카드 인지 기록") {
  State s(1);
  ZoneId deck = Z(s, 0, "main_deck");
  for (int i = 0; i < 10; ++i) s.create_card(200 + i, 0, deck);
  CardIdx t = s.create_card(100, 0, Z(s, 0, "trash"));
  s.move(t, deck, Pos::Top);
  CHECK(s.zones.get(deck).cards.back() == t);
  CHECK(s.can_see(0, t) && s.can_see(1, t));
  s.shuffle(deck);
  CHECK(!s.can_see(0, t) && !s.can_see(1, t));
}

TEST_CASE("info: 패에서 덱으로 간 카드는 주인만 안다", "설계: 카드 인지 기록") {
  State s(1);
  CardIdx h = s.create_card(100, 0, Z(s, 0, "hand"));
  s.move(h, Z(s, 0, "main_deck"), Pos::Bottom);
  CHECK(s.zones.get(Z(s, 0, "main_deck")).cards.front() == h);
  CHECK(s.can_see(0, h) && !s.can_see(1, h));
}
