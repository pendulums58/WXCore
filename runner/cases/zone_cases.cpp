#include <algorithm>

#include "state.h"
#include "test.h"

using namespace wx;

namespace {
bool has(const std::vector<ZoneId>& v, ZoneId z) {
  return std::find(v.begin(), v.end(), z) != v.end();
}
}  // namespace

TEST_CASE("zone: 기본 시그니 존 3칸과 인접", "용어집: シグニゾーン") {
  ZoneRegistry zr;
  zr.init_default();
  for (PlayerId p = 0; p < 2; ++p) {
    auto s = zr.zones_of(p, ZoneKind::Signi);
    CHECK(s.size() == 3);
    ZoneId l = zr.find(p, "signi_left"), c = zr.find(p, "signi_center"), r = zr.find(p, "signi_right");
    CHECK(has(zr.adjacent(l), c));
    CHECK(has(zr.adjacent(c), l) && has(zr.adjacent(c), r));
    CHECK(!has(zr.adjacent(l), r));
  }
}

TEST_CASE("zone: 정면은 거울 대칭", "설계: 존과 장") {
  ZoneRegistry zr;
  zr.init_default();
  CHECK(zr.front(zr.find(0, "signi_left")) == zr.find(1, "signi_right"));
  CHECK(zr.front(zr.find(0, "signi_center")) == zr.find(1, "signi_center"));
  CHECK(zr.front(zr.find(1, "signi_left")) == zr.find(0, "signi_right"));
}

TEST_CASE("zone: 장 그룹 = 시그니·치어·루리그 존", "용어집: 場") {
  ZoneRegistry zr;
  zr.init_default();
  auto field = zr.in_group(0, ZG_FIELD);
  CHECK(has(field, zr.find(0, "signi_center")));
  CHECK(has(field, zr.find(0, "cheer")));
  CHECK(has(field, zr.find(0, "lrig_center")));
  CHECK(has(field, zr.find(0, "key")));
  CHECK(!has(field, zr.find(0, "ena")));
  CHECK(!has(field, zr.find(0, "trash")));
}

TEST_CASE("zone: 오른쪽을 지워도 중앙은 오른쪽이 되지 않는다", "WXK03-005 FAQ 2") {
  ZoneRegistry zr;
  zr.init_default();
  ZoneId r = zr.find(1, "signi_right");
  zr.set_absent(r, true);
  auto s = zr.zones_of(1, ZoneKind::Signi);
  CHECK(s.size() == 2);
  CHECK(zr.find(1, "signi_center") != kNoZone);
  CHECK(zr.get(zr.find(1, "signi_center")).name == "signi_center");
  CHECK(!has(s, r));
}

TEST_CASE("zone: 중앙을 지워도 좌우는 인접하지 않는다", "WXK03-005 FAQ 3") {
  ZoneRegistry zr;
  zr.init_default();
  ZoneId l = zr.find(1, "signi_left"), c = zr.find(1, "signi_center"), r = zr.find(1, "signi_right");
  zr.set_absent(c, true);
  CHECK(zr.adjacent(l).empty());
  CHECK(zr.adjacent(r).empty());
  CHECK(zr.adjacent(c).empty());
}

TEST_CASE("zone: 정면 존이 지워지면 정면이 없다", "WXK03-005 FAQ 4") {
  ZoneRegistry zr;
  zr.init_default();
  ZoneId mine = zr.find(0, "signi_left");
  zr.set_absent(zr.find(1, "signi_right"), true);
  CHECK(zr.front(mine) == kNoZone);
}

TEST_CASE("zone: 지운 존이 돌아오면 링크도 그대로", "WXK03-005 FAQ 1") {
  ZoneRegistry zr;
  zr.init_default();
  ZoneId l = zr.find(1, "signi_left"), c = zr.find(1, "signi_center");
  zr.set_absent(c, true);
  zr.set_absent(c, false);
  CHECK(has(zr.adjacent(l), c));
  CHECK(zr.front(c) == zr.find(0, "signi_center"));
}

TEST_CASE("zone: 늘린 존은 새 ID, 링크는 만드는 쪽이 정한다", "설계: 가변 시그니 존") {
  ZoneRegistry zr;
  zr.init_default();
  const size_t before = zr.size();
  Zone z;
  z.owner = 0;
  z.kind = ZoneKind::Signi;
  z.name = "signi_extra_1";
  z.groups = ZG_FIELD | ZG_SIGNI;
  z.slot = true;
  z.extra = true;
  ZoneId x = zr.add(z);
  CHECK(x == before);
  CHECK(zr.zones_of(0, ZoneKind::Signi).size() == 4);
  CHECK(zr.adjacent(x).empty());
  CHECK(zr.front(x) == kNoZone);
  zr.link_adjacent(x, zr.find(0, "signi_right"));
  CHECK(has(zr.adjacent(zr.find(0, "signi_right")), x));
}
