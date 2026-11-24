#include "zone.h"

#include <algorithm>

namespace wx {

namespace {
Zone make(PlayerId p, ZoneKind kind, const char* name, ZoneVis vis, uint32_t groups = ZG_NONE,
          bool ordered = false, bool slot = false) {
  Zone z;
  z.owner = p;
  z.kind = kind;
  z.name = name;
  z.vis = vis;
  z.groups = groups;
  z.ordered = ordered;
  z.slot = slot;
  return z;
}
}  // namespace

void ZoneRegistry::init_default() {
  zones_.clear();
  constexpr uint32_t kSigni = ZG_FIELD | ZG_SIGNI;
  constexpr uint32_t kLrig = ZG_FIELD | ZG_LRIG;
  for (PlayerId p = 0; p < 2; ++p) {
    add(make(p, ZoneKind::MainDeck, "main_deck", ZoneVis::Hidden, ZG_NONE, true));
    add(make(p, ZoneKind::LifeCloth, "life_cloth", ZoneVis::Hidden, ZG_NONE, true));
    add(make(p, ZoneKind::LrigDeck, "lrig_deck", ZoneVis::OwnerOnly));
    add(make(p, ZoneKind::Hand, "hand", ZoneVis::OwnerOnly));
    add(make(p, ZoneKind::Trash, "trash", ZoneVis::Public));
    add(make(p, ZoneKind::LrigTrash, "lrig_trash", ZoneVis::Public));
    add(make(p, ZoneKind::Ena, "ena", ZoneVis::Public));
    add(make(p, ZoneKind::Check, "check", ZoneVis::Public));
    add(make(p, ZoneKind::Exclude, "exclude", ZoneVis::Public));
    add(make(p, ZoneKind::LrigCenter, "lrig_center", ZoneVis::Public, kLrig, false, true));
    add(make(p, ZoneKind::LrigAssist, "lrig_assist_left", ZoneVis::Public, kLrig, false, true));
    add(make(p, ZoneKind::LrigAssist, "lrig_assist_right", ZoneVis::Public, kLrig, false, true));
    add(make(p, ZoneKind::Key, "key", ZoneVis::Public, kLrig, false, true));
    ZoneId l = add(make(p, ZoneKind::Signi, "signi_left", ZoneVis::Public, kSigni, false, true));
    ZoneId c = add(make(p, ZoneKind::Signi, "signi_center", ZoneVis::Public, kSigni, false, true));
    ZoneId r = add(make(p, ZoneKind::Signi, "signi_right", ZoneVis::Public, kSigni, false, true));
    link_side(l, c);
    link_side(c, r);
    add(make(p, ZoneKind::Cheer, "cheer", ZoneVis::Public, ZG_FIELD, false, true));
  }
  // 정면은 거울 대칭: 내 왼쪽 ↔ 상대 오른쪽
  link_front(find(0, "signi_left"), find(1, "signi_right"));
  link_front(find(0, "signi_center"), find(1, "signi_center"));
  link_front(find(0, "signi_right"), find(1, "signi_left"));
}

ZoneId ZoneRegistry::add(Zone z) {
  z.id = static_cast<ZoneId>(zones_.size());
  zones_.push_back(std::move(z));
  return zones_.back().id;
}

ZoneId ZoneRegistry::find(PlayerId p, std::string_view name) const {
  for (const auto& z : zones_)
    if (z.owner == p && z.name == name) return z.id;
  return kNoZone;
}

ZoneId ZoneRegistry::find(PlayerId p, ZoneKind kind) const {
  for (const auto& z : zones_)
    if (z.owner == p && z.kind == kind) return z.id;
  return kNoZone;
}

std::vector<ZoneId> ZoneRegistry::zones_of(PlayerId p, ZoneKind kind, bool include_absent) const {
  std::vector<ZoneId> out;
  for (const auto& z : zones_)
    if (z.owner == p && z.kind == kind && (include_absent || !z.absent)) out.push_back(z.id);
  return out;
}

std::vector<ZoneId> ZoneRegistry::in_group(PlayerId p, uint32_t groups, bool include_absent) const {
  std::vector<ZoneId> out;
  for (const auto& z : zones_)
    if (z.owner == p && (z.groups & groups) && (include_absent || !z.absent)) out.push_back(z.id);
  return out;
}

void ZoneRegistry::link_adjacent(ZoneId a, ZoneId b) {
  auto add_one = [](std::vector<ZoneId>& v, ZoneId x) {
    if (std::find(v.begin(), v.end(), x) == v.end()) v.push_back(x);
  };
  add_one(zones_[a].adjacent, b);
  add_one(zones_[b].adjacent, a);
}

void ZoneRegistry::link_front(ZoneId a, ZoneId b) {
  zones_[a].front = b;
  zones_[b].front = a;
}

void ZoneRegistry::link_side(ZoneId left, ZoneId right) {
  link_adjacent(left, right);
  zones_[left].right = right;
  zones_[right].left = left;
}

std::vector<ZoneId> ZoneRegistry::adjacent(ZoneId id) const {
  std::vector<ZoneId> out;
  if (zones_[id].absent) return out;
  for (ZoneId a : zones_[id].adjacent)
    if (!zones_[a].absent) out.push_back(a);
  return out;
}

ZoneId ZoneRegistry::front(ZoneId id) const {
  const Zone& z = zones_[id];
  if (z.absent || z.front == kNoZone || zones_[z.front].absent) return kNoZone;
  return z.front;
}

}  // namespace wx
