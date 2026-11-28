#include "state.h"

#include <algorithm>

namespace wx {

namespace {
void erase_one(std::vector<CardIdx>& v, CardIdx c) {
  auto it = std::find(v.begin(), v.end(), c);
  if (it != v.end()) v.erase(it);
}
}  // namespace

MoveRecord State::begin_record(CardIdx c, MoveKind kind) const {
  const Card& card = cards.get(c);
  MoveRecord r;
  r.card = c;
  r.kind = kind;
  r.old_oid = card.oid;
  r.from = card.zone;
  r.seen_before = static_cast<uint8_t>(viewers(c) | card.known_by);
  r.public_before = viewers(c) == 0b11;
  return r;
}

void State::finish_record(MoveRecord& r) {
  const Card& card = cards.get(r.card);
  r.new_oid = card.oid;
  r.to = card.zone;
  r.host = card.host;
  r.seen_after = static_cast<uint8_t>(viewers(r.card) | card.known_by);
  r.public_after = viewers(r.card) == 0b11;
  if (on_move) on_move(r);
}

State::State(uint64_t seed) : rng(seed) { zones.init_default(); }

CardIdx State::create_card(Cid cid, PlayerId owner, ZoneId zone, Pos pos, uint16_t print) {
  CardIdx c = cards.create(cid, owner);
  cards.get(c).print = print ? print : 1;  // 만들어지는 MOVE 메시지에 실린다
  Zone& z = zones.get(zone);
  if (z.ordered && pos == Pos::Bottom)
    z.cards.insert(z.cards.begin(), c);
  else
    z.cards.push_back(c);
  Card& card = cards.get(c);
  card.zone = zone;
  card.face_up = z.vis == ZoneVis::Public;
  card.known_by = viewers(c);
  MoveRecord r;
  r.card = c;
  r.pos = pos;
  finish_record(r);
  return c;
}

uint8_t State::viewers(CardIdx c) const {
  const Card& card = cards.get(c);
  if (card.zone == kNoZone) return 0;
  const Zone& z = zones.get(card.zone);
  switch (z.vis) {
    // 앞/뒷면은 공개 영역에서만 의미가 있다(장의 트랩·뒷면 시그니)
    case ZoneVis::Public: return card.face_up ? 0b11 : 0;
    case ZoneVis::OwnerOnly: return static_cast<uint8_t>(1u << z.owner);
    case ZoneVis::Hidden: return 0;
  }
  return 0;
}

bool State::can_see(PlayerId p, CardIdx c) const {
  return ((viewers(c) | cards.get(c).known_by) >> p) & 1u;
}

void State::detach_from_source(CardIdx c) {
  Card& card = cards.get(c);
  if (card.host != kNoCard) {
    Card& host = cards.get(card.host);
    erase_one(host.under, c);
    erase_one(host.attached, c);
    card.host = kNoCard;
    return;
  }
  if (card.zone == kNoZone) return;
  Zone& z = zones.get(card.zone);
  erase_one(z.cards, c);
  erase_one(z.leftovers, c);
  if (z.set_card == c) z.set_card = kNoCard;
  if (z.seed_card == c) z.seed_card = kNoCard;
}

void State::move(CardIdx c, ZoneId to, Pos pos) {
  Card& card = cards.get(c);
  const ZoneId from = card.zone;
  const bool was_hosted = card.host != kNoCard || is_leftover(c) || is_set(c);
  const bool from_field = from != kNoZone && zones.has_group(from, ZG_FIELD);
  const bool to_field = zones.has_group(to, ZG_FIELD);
  // 장 안 이동만 같은 객체. 아래/붙은 카드였던 카드는 장의 객체가 아니었으므로 새 객체.
  const bool same_object = from_field && to_field && !was_hosted;
  MoveRecord rec = begin_record(c, MoveKind::Move);
  rec.pos = pos;

  card.known_by |= viewers(c);
  detach_from_source(c);
  card.acce = card.charm = false;

  auto carry = [&](std::vector<CardIdx>& list) {
    if (same_object) {
      for (CardIdx u : list) cards.get(u).zone = to;
    } else if (from_field && !was_hosted) {
      // 장을 떠남: 아래/붙은 카드는 남는다(용어집: ルール処理 3)
      auto& left = zones.get(from).leftovers;
      for (CardIdx u : list) {
        cards.get(u).host = kNoCard;
        left.push_back(u);
      }
      list.clear();
    }
  };
  carry(card.under);
  carry(card.attached);

  Zone& z = zones.get(to);
  if (z.ordered && pos == Pos::Bottom)
    z.cards.insert(z.cards.begin(), c);
  else
    z.cards.push_back(c);
  card.zone = to;
  card.face_up = z.vis == ZoneVis::Public;

  if (!same_object) {
    cards.renew(c);
    card.flags = 0;
    // 장에서는 그 존의 플레이어가 컨트롤한다(상대의 카드를 내 장에 내면 傀儡状態. WDK17-012)
    card.controller = zones.has_group(to, ZG_FIELD) ? z.owner : card.owner;
  }
  card.known_by |= viewers(c);
  finish_record(rec);
}

void State::host_card(CardIdx c, CardIdx host, bool under) {
  MoveRecord rec = begin_record(c, under ? MoveKind::Under : MoveKind::Attach);
  detach_from_source(c);
  Card& card = cards.get(c);
  card.acce = card.charm = false;
  Card& h = cards.get(host);
  (under ? h.under : h.attached).push_back(c);
  card.host = host;
  card.zone = h.zone;
  card.face_up = true;
  card.flags = 0;
  card.known_by = 0b11;  // 장(공개 영역)에 앞면으로 놓인다
  cards.renew(c);
  finish_record(rec);
}

void State::stack_on(CardIdx base, CardIdx host) {
  Card& old = cards.get(base);
  Card& top = cards.get(host);
  for (CardIdx u : old.under) {
    top.under.push_back(u);
    cards.get(u).host = host;
  }
  old.under.clear();
  for (CardIdx a : old.attached) {
    cards.get(a).host = kNoCard;
    zones.get(old.zone).leftovers.push_back(a);
  }
  old.attached.clear();
  put_under(base, host);
}

void State::put_under(CardIdx c, CardIdx host) { host_card(c, host, true); }
void State::attach(CardIdx c, CardIdx host, bool acce) {
  host_card(c, host, false);
  cards.get(c).acce = acce;
}

bool State::has_acce(CardIdx host) const {
  const auto& list = cards.get(host).attached;
  return std::any_of(list.begin(), list.end(), [&](CardIdx a) { return cards.get(a).acce; });
}

CardIdx State::charm_of(CardIdx host) const {
  for (CardIdx a : cards.get(host).attached)
    if (cards.get(a).charm) return a;
  return kNoCard;
}

void State::set_face_down(CardIdx c, ZoneId z, bool seed) {
  MoveRecord rec = begin_record(c, seed ? MoveKind::Seed : MoveKind::Set);
  Card& card = cards.get(c);
  card.known_by |= viewers(c);
  detach_from_source(c);
  card.acce = card.charm = false;
  (seed ? zones.get(z).seed_card : zones.get(z).set_card) = c;
  card.zone = z;
  card.face_up = false;
  card.flags = 0;
  card.controller = card.owner;
  card.known_by |= static_cast<uint8_t>(1u << card.owner);
  cards.renew(c);
  finish_record(rec);
}

bool State::is_set(CardIdx c) const {
  const Card& card = cards.get(c);
  return card.zone != kNoZone && card.host == kNoCard && (zones.get(card.zone).set_card == c || zones.get(card.zone).seed_card == c);
}

bool State::is_seed(CardIdx c) const {
  const Card& card = cards.get(c);
  return card.zone != kNoZone && card.host == kNoCard && zones.get(card.zone).seed_card == c;
}

void State::swap_field(CardIdx a, CardIdx b) {
  Card& ca = cards.get(a);
  Card& cb = cards.get(b);
  const ZoneId za = ca.zone, zb = cb.zone;
  MoveRecord ra = begin_record(a, MoveKind::Move);
  std::replace(zones.get(za).cards.begin(), zones.get(za).cards.end(), a, b);
  std::replace(zones.get(zb).cards.begin(), zones.get(zb).cards.end(), b, a);
  ca.zone = zb;
  cb.zone = za;
  for (CardIdx u : ca.under) cards.get(u).zone = zb;
  for (CardIdx u : ca.attached) cards.get(u).zone = zb;
  for (CardIdx u : cb.under) cards.get(u).zone = za;
  for (CardIdx u : cb.attached) cards.get(u).zone = za;
  ra.to = zb;
  finish_record(ra);
  MoveRecord rb = begin_record(b, MoveKind::Move);
  rb.from = zb;
  rb.to = za;
  finish_record(rb);
}

void State::bloom(CardIdx c) {
  MoveRecord rec = begin_record(c, MoveKind::Move);
  Card& card = cards.get(c);
  const ZoneId z = card.zone;
  card.known_by |= viewers(c);
  detach_from_source(c);
  zones.get(z).cards.push_back(c);
  card.zone = z;
  card.face_up = true;
  card.flags = 0;
  card.known_by = 0b11;
  cards.renew(c);
  finish_record(rec);
}

bool State::is_leftover(CardIdx c) const {
  const Card& card = cards.get(c);
  if (card.zone == kNoZone || card.host != kNoCard) return false;
  const auto& left = zones.get(card.zone).leftovers;
  return std::find(left.begin(), left.end(), c) != left.end();
}

void State::turn_face_down(CardIdx c) {
  Card& card = cards.get(c);
  if (!card.face_up) return;
  MoveRecord rec = begin_record(c, MoveKind::FaceDown);
  card.known_by |= viewers(c);
  card.face_up = false;
  cards.renew(c);
  card.flags = 0;
  // 뒷면은 시그니가 아니므로 붙은 카드는 룰 처리로 트래시(용어집: 付けられているカード)
  if (card.zone != kNoZone) {
    auto& left = zones.get(card.zone).leftovers;
    for (CardIdx u : card.attached) {
      cards.get(u).host = kNoCard;
      left.push_back(u);
    }
  }
  card.attached.clear();
  finish_record(rec);
}

void State::shuffle_bottom(ZoneId zone, size_t n) {
  Zone& z = zones.get(zone);
  n = std::min(n, z.cards.size());
  if (n == 0) return;
  std::vector<CardIdx> part(z.cards.begin(), z.cards.begin() + static_cast<std::ptrdiff_t>(n));
  rng.shuffle(part);
  std::copy(part.begin(), part.end(), z.cards.begin());
  for (CardIdx c : part) {
    cards.get(c).known_by = 0;
    cards.renew(c);
  }
  if (on_shuffle) on_shuffle(zone);
}

void State::shuffle(ZoneId zone) {
  Zone& z = zones.get(zone);
  rng.shuffle(z.cards);
  // 인지 기록을 지우고 객체 번호도 새로 준다. 번호로 덱 속 카드를 추적하지 못하게
  for (CardIdx c : z.cards) {
    cards.get(c).known_by = 0;
    cards.renew(c);
  }
  if (on_shuffle) on_shuffle(zone);
}

}  // namespace wx
