#include "card.h"

namespace wx {

CardIdx CardTable::create(Cid cid, PlayerId owner) {
  Card c;
  c.idx = static_cast<CardIdx>(cards_.size());
  c.cid = cid;
  c.owner = owner;
  c.controller = owner;
  cards_.push_back(c);
  renew(c.idx);
  return c.idx;
}

Card* CardTable::by_oid(ObjId oid) {
  auto it = by_oid_.find(oid);
  return it == by_oid_.end() ? nullptr : &cards_[it->second];
}

void CardTable::renew(CardIdx i) {
  Card& c = cards_[i];
  if (c.oid != kNoObj) by_oid_.erase(c.oid);
  c.oid = next_oid_++;
  c.obj_time = tick();
  by_oid_[c.oid] = i;
}

}  // namespace wx
