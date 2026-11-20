// 카드 이동과 이벤트, 트리거 수집.
// 트리거는 사건이 일어난 순간에 모아 두고, 룰 처리 뒤에 순서대로 발동한다(용어집: トリガー能力 2·3).
#include <algorithm>

#include "duel.h"

namespace wx {

// 지금 이 카드가 가진 SINGLE 트리거 능력. 이동 전에 불러 두면 LKI가 된다.
std::vector<EffectId> Duel::active_single_triggers(CardIdx c) {
  std::vector<Effect*> cand;
  effects.for_each([&](Effect& e) {
    if (e.handler == c && (e.type & EFFECT_TYPE_SINGLE) && e.is_trigger()) cand.push_back(&e);
  });
  std::vector<EffectId> out;
  for (Effect* e : cand) {
    if (!effect_live(*e)) continue;
    if (e->range && !(location_of(c) & e->range)) continue;
    if (e->is_ability()) {
      if (e->printed) {
        auto [text, copy] = text_source(c);
        if (e->text_cid != text || e->copy_of != copy) continue;
      }
      auto list = abilities_of(c);
      if (std::find(list.begin(), list.end(), e->id) == list.end()) continue;
    }
    if (effect_suppressed(*e)) continue;
    out.push_back(e->id);
  }
  return out;
}

void Duel::push_pending(Effect& e, CardIdx handler, const Event& ev) {
  Pending t;
  t.effect = e.id;
  t.handler = handler;
  t.player = handler != kNoCard ? state.cards.get(handler).controller : e.owner_player;
  t.event = ev;
  if (e.condition_ref && !call_trigger_check(e.condition_ref, t, false)) return;
  pending_[t.player].push_back(std::move(t));
}

void Duel::collect(const Event& ev, const std::vector<EffectId>* pre_single) {
  // SINGLE: 사건의 대상 카드 자신의 능력
  for (CardIdx c : ev.cards) {
    std::vector<EffectId> list = pre_single ? *pre_single : active_single_triggers(c);
    for (EffectId id : list) {
      Effect& e = *effects.get(id);
      if (e.code == ev.code) push_pending(e, c, ev);
    }
  }
  // FIELD: 다른 카드·플레이어가 지켜보는 능력
  std::vector<Effect*> cand;
  effects.for_each([&](Effect& e) {
    if ((e.type & EFFECT_TYPE_FIELD) && e.is_trigger() && e.code == ev.code) cand.push_back(&e);
  });
  for (Effect* e : cand) {
    if (!effect_live(*e)) continue;
    if (e->handler != kNoCard) {
      if (e->is_ability() ? !ability_active(*e) : (e->range && !(location_of(e->handler) & e->range)))
        continue;
    }
    if (effect_suppressed(*e)) continue;
    push_pending(*e, e->handler, ev);
  }
}

void Duel::raise(const Event& ev) { collect(ev, nullptr); }

void Duel::move_card(CardIdx c, ZoneId to, uint32_t reason, PlayerId rp, Pos pos, EffectId re) {
  Card& card = state.cards.get(c);
  const ZoneId from = card.zone;
  const bool from_field = from != kNoZone && card.host == kNoCard && state.zones.has_group(from, ZG_FIELD);
  // 떠나는 쪽 트리거는 이동 직전의 능력으로 판정한다(설계: LKI)
  const std::vector<EffectId> before = active_single_triggers(c);

  state.move(c, to, pos);

  const bool to_field = state.zones.has_group(to, ZG_FIELD);
  Event ev;
  ev.cards = {c};
  ev.player = card.controller;
  ev.reason = reason;
  ev.reason_player = rp;
  ev.reason_effect = re;

  if (from_field && !to_field) {
    ev.code = EVENT_LEAVE_FIELD;
    collect(ev, &before);
  }
  if (to_field && !from_field) {
    ev.code = EVENT_ON_PLAY;
    collect(ev, nullptr);
  }
  switch (state.zones.get(to).kind) {
    case ZoneKind::Trash: ev.code = EVENT_TO_TRASH; break;
    case ZoneKind::Ena: ev.code = EVENT_TO_ENA; break;
    case ZoneKind::Hand: ev.code = EVENT_TO_HAND; break;
    default: ev.code = 0;
  }
  if (ev.code) collect(ev, &before);
}

// 바니시: 에나 존으로(용어집: バニッシュ)
void Duel::banish(CardIdx c, uint32_t reason, PlayerId rp, EffectId re) {
  const Card& card = state.cards.get(c);
  const std::vector<EffectId> before = active_single_triggers(c);
  Event ev;
  ev.code = EVENT_BANISHED;
  ev.cards = {c};
  ev.player = card.controller;
  ev.reason = reason;
  ev.reason_player = rp;
  ev.reason_effect = re;
  move_card(c, state.zones.find(card.owner, ZoneKind::Ena), reason, rp, Pos::Top, re);
  collect(ev, &before);
}

uint32_t Duel::draw(PlayerId p, uint32_t n, uint32_t reason) {
  const ZoneId deck = state.zones.find(p, ZoneKind::MainDeck);
  const ZoneId hand = state.zones.find(p, ZoneKind::Hand);
  uint32_t drawn = 0;
  Event ev;
  ev.code = EVENT_DRAW;
  ev.player = p;
  ev.reason = reason;
  for (; drawn < n; ++drawn) {
    CardIdx c = top_of(deck);
    if (c == kNoCard) break;  // 0장이면 더 못 뽑는다. 리프레시는 룰 처리에서
    move_card(c, hand, reason, p);
    ev.cards.push_back(c);
  }
  if (drawn) {
    ev.value = static_cast<int32_t>(drawn);
    raise(ev);
  }
  return drawn;
}

void Duel::remove_zone(ZoneId z, PlayerId rp, EffectId re) {
  Zone& zone = state.zones.get(z);
  auto trash_of = [&](CardIdx c) { return state.zones.find(state.cards.get(c).owner, ZoneKind::Trash); };
  // 시그니 → 그 아래 카드·붙은 카드(이동하면 leftovers로 남는다) → 트랩
  for (CardIdx c : std::vector<CardIdx>(zone.cards)) move_card(c, trash_of(c), REASON_EFFECT, rp, Pos::Top, re);
  for (CardIdx c : std::vector<CardIdx>(zone.leftovers)) state.move(c, trash_of(c));
  if (zone.set_card != kNoCard)
    move_card(zone.set_card, trash_of(zone.set_card), REASON_EFFECT, rp, Pos::Top, re);
  // 바이러스는 카드가 아니라 그냥 사라진다(WXK03-005 FAQ 5). 바이러스 표식은 아직 없음
  state.zones.set_absent(z, true);
}

}  // namespace wx
