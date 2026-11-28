// 카드 이동과 이벤트, 트리거 수집.
// 트리거는 사건이 일어난 순간에 모아 두고, 룰 처리 뒤에 순서대로 발동한다(용어집: トリガー能力 2·3).
#include <algorithm>

#include "duel.h"

namespace wx {

// 지금 이 카드가 가진 SINGLE 트리거 능력. 이동 전에 불러 두면 LKI가 된다.
std::vector<EffectId> Duel::active_single_triggers(CardIdx c) {
  std::vector<Effect*> cand;
  effects.for_each([&](Effect& e) {
    if (e.handler == c && (e.type & (EFFECT_TYPE_SINGLE | EFFECT_TYPE_FIELD)) && e.is_trigger()) cand.push_back(&e);
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
      if (std::find(list.begin(), list.end(), e->id) == list.end() || ability_disabled(*e)) continue;
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
  struct Scope {
    bool& flag;
    bool old;
    ~Scope() { flag = old; }
  } scope{collecting, collecting};
  collecting = true;
  sync_grants();
  // 사건의 대상 카드 자신의 능력. 옮겨진 카드는 옮기기 직전의 능력으로(LKI). FIELD도 그 카드의 것은 여기서
  // (자기 자신이 장에서 패로 돌아갔을 때도 「シグニが場から手札に戻ったとき」가 트리거한다. WDK-F03-11 FAQ 2)
  std::vector<EffectId> done;
  for (CardIdx c : ev.cards) {
    std::vector<EffectId> list = pre_single ? *pre_single : active_single_triggers(c);
    // 「それの【出】能力は発動しない」
    const bool no_play = ev.code == EVENT_ON_PLAY && no_play_trigger;
    for (EffectId id : list) {
      Effect& e = *effects.get(id);
      if (e.code != ev.code || (no_play && (ability_type_of(e) & ABILITY_ON_PLAY))) continue;
      push_pending(e, (e.type & EFFECT_TYPE_FIELD) ? e.handler : c, ev);
      done.push_back(id);
    }
  }
  // FIELD: 다른 카드·플레이어가 지켜보는 능력
  std::vector<Effect*> cand;
  effects.for_each([&](Effect& e) {
    if ((e.type & EFFECT_TYPE_FIELD) && e.is_trigger() && e.code == ev.code) cand.push_back(&e);
  });
  for (Effect* e : cand) {
    if (!effect_live(*e) || std::find(done.begin(), done.end(), e->id) != done.end()) continue;
    if (e->handler != kNoCard) {
      if (e->is_ability() ? !ability_active(*e) : (e->range && !(location_of(e->handler) & e->range)))
        continue;
    }
    if (effect_suppressed(*e)) continue;
    push_pending(*e, e->handler, ev);
  }
}

void Duel::raise(const Event& ev) { collect(ev, nullptr); }

bool Duel::move_card(CardIdx c, ZoneId to, uint32_t reason, PlayerId rp, Pos pos, EffectId re) {
  Card& card = state.cards.get(c);
  const ZoneId from = card.zone;
  // 「自分のターンの間、グロウフェイズとドローフェイズ以外でカードを引いたり手札に加えることができない」(WX05-022)
  if (state.zones.get(to).kind == ZoneKind::Hand && state.zones.get(to).owner == turn_player && phase != PHASE_DRAW &&
      phase != PHASE_GROW && from != kNoZone && state.zones.get(from).kind != ZoneKind::Hand &&
      player_affected(turn_player, EFFECT_NO_HAND_ADD))
    return false;
  // 「このターン、あなたのシグニは場から手札に戻らない」(WX13-029)
  if (state.zones.get(to).kind == ZoneKind::Hand && (location_of(c) & LOCATION_SZONE) && has_keyword(c, EFFECT_NO_BOUNCE)) return false;
  // 「自分でこのシグニを場からトラッシュに置くことができない」(WX07-033): 자기 코스트·효과로
  if ((reason & (REASON_EFFECT | REASON_COST)) && rp == card.controller && state.zones.get(to).kind == ZoneKind::Trash &&
      (location_of(c) & LOCATION_SZONE) && has_keyword(c, EFFECT_NO_SELF_TRASH))
    return false;
  if ((reason & REASON_EFFECT) && card.host == kNoCard) {
    if (const Effect* src = effects.get(re); src && immune(c, *src)) return false;
    note_arts_hit(c, re);
  }
  // 레조나가 루리그 덱·루리그 트래시·시그니 존·치어 존 밖으로 가려 하면 그곳에 놓이지 않고 대신 루리그 덱으로
  // (용어집: レゾナ 2·3, WXK11-013 FAQ 3 「実際にトラッシュには置かれていません」). 룰이라 능력을 잃어도 적용(WX07-008 FAQ 5).
  // 레조나가 아닌 상태면 그곳에 갔다가 룰 처리로 돌아간다(용어집: レゾナ 6, WX21-027 FAQ 4)
  if (!resona_raw_ && (data(card.cid).type & TYPE_RESONA) && (type_of(c) & TYPE_RESONA)) {
    const ZoneKind k = state.zones.get(to).kind;
    if (k != ZoneKind::LrigDeck && k != ZoneKind::LrigTrash && k != ZoneKind::Signi && k != ZoneKind::Cheer) {
      // 「バニッシュされる場合、ルリグデッキに戻る代わりにルリグトラッシュ」(WX10-008)
      const bool lt = (reason & REASON_BANISH) && has_keyword(c, EFFECT_RESONA_TO_LTRASH);
      to = state.zones.find(card.owner, lt ? ZoneKind::LrigTrash : ZoneKind::LrigDeck);
      pos = Pos::Top;
    }
  }
  const bool set = state.is_set(c), seed = state.is_seed(c);
  const bool leftover = state.is_leftover(c) || set;  // 【トラップ】, 붙어 있던·아래 카드는 장의 시그니가 아니다
  const bool from_field = from != kNoZone && card.host == kNoCard && !leftover && state.zones.has_group(from, ZG_FIELD);
  if (from_field) card.prev_acce = state.has_acce(c);
  if (from_field) card.prev_infected = infected(c);
  card.prev_charm = card.charm && card.host != kNoCard;
  // 傀儡状態(주인이 아닌 플레이어의 장)의 시그니가 장을 떠나면 대신 주인의 트래시로(WDK17-007 주석, WDK17-012 FAQ)
  if (from_field && !state.zones.has_group(to, ZG_FIELD) && card.controller != card.owner) {
    to = state.zones.find(card.owner, ZoneKind::Trash);
    pos = Pos::Top;
  }
  if (from_field && !state.zones.has_group(to, ZG_FIELD) && has_keyword(c, EFFECT_LEAVE_TO_LTRASH)) {
    to = state.zones.find(card.owner, ZoneKind::LrigTrash);
    pos = Pos::Top;
  }
  if (from_field && !state.zones.has_group(to, ZG_FIELD) && has_keyword(c, EFFECT_LEAVE_EXCLUDE)) {
    to = state.zones.find(card.owner, ZoneKind::Exclude);
    pos = Pos::Top;
  }
  // 상대 효과로 옮겨진 것(룰 처리는 아니다. PR-463 FAQ 3)
  if ((reason & REASON_EFFECT) && !(reason & REASON_RULE) && rp != kNoPlayer && rp != card.owner && from != kNoZone) {
    const ZoneKind fk = state.zones.get(from).kind, tk = state.zones.get(to).kind;
    uint8_t& m = players[card.owner].moved_by_opp_this_turn;
    if (from_field && (type_of(c) & TYPE_SIGNI) && !state.zones.has_group(to, ZG_FIELD)) m |= 1;
    if (fk == ZoneKind::Ena && tk == ZoneKind::Trash) m |= 2;
    if (fk == ZoneKind::Hand && tk == ZoneKind::Trash) m |= 4;
  }
  // 떠나는 쪽 트리거는 이동 직전의 능력으로 판정한다(설계: LKI)
  const std::vector<EffectId> before = active_single_triggers(c);
  // 【ライズ】: 놓는 존에 시그니가 있으면 그 위에. 밑이 되는 시그니는 장을 떠난 것으로 트리거하지 않는다(용어집: ライズ)
  CardIdx base = kNoCard;
  std::vector<EffectId> base_before;
  if (state.zones.get(to).kind == ZoneKind::Signi && occupant(to) != kNoCard && occupant(to) != c && has_rise(c)) {
    base = occupant(to);
    base_before = active_single_triggers(base);
  }
  card.prev_zone = from;
  card.prev_loc = seed ? LOCATION_SEED : set ? LOCATION_TRAP : from != kNoZone && !leftover ? loc_bit(state.zones.get(from).kind) : 0;

  state.move(c, to, pos);
  if (base != kNoCard) state.stack_on(base, c);
  if (enter_down_ && state.zones.has_group(to, ZG_FIELD)) set_flags(c, state.cards.get(c).flags | CF_DOWN);

  // 효과로 메인 덱에 들어왔다(덱 → 덱 제외). 효과 처리가 끝날 때 한 번에 이벤트로 낸다
  const ZoneKind to_kind = state.zones.get(to).kind;
  if (to_kind == ZoneKind::MainDeck && (from == kNoZone || state.zones.get(from).kind != ZoneKind::MainDeck) &&
      (reason & REASON_EFFECT) && rp != kNoPlayer) {
    deck_moved_.push_back(c);
    deck_moved_effect_ = re;
    deck_moved_player_ = rp;
    if (state.cards.get(c).owner != rp) ++players[rp].opp_to_deck_this_turn;
  }

  if ((reason & REASON_DISCARD) && (card.prev_loc & LOCATION_HAND)) ++players[card.owner].discarded_this_turn;
  const bool to_field = state.zones.has_group(to, ZG_FIELD);
  Event ev;
  ev.cards = {c};
  ev.player = card.controller;
  ev.reason = reason;
  ev.reason_player = rp;
  ev.reason_effect = re;

  if (from_field && !to_field && !set) {  // 【トラップ】·【シード】는 시그니가 아니다
    ev.code = EVENT_LEAVE_FIELD;
    collect(ev, &before);
  }
  if (to_field && !from_field) {
    ev.code = EVENT_ON_PLAY;
    ev.value = play_value_;
    collect(ev, nullptr);
    ev.value = 0;
  }
  switch (state.zones.get(to).kind) {
    case ZoneKind::Trash: ev.code = EVENT_TO_TRASH; break;
    case ZoneKind::Ena: ev.code = EVENT_TO_ENA; break;
    case ZoneKind::LrigTrash: ev.code = EVENT_TO_LTRASH; break;
    case ZoneKind::Hand: ev.code = EVENT_TO_HAND; break;
    case ZoneKind::Beat: ev.code = EVENT_BEAT; break;
    case ZoneKind::LifeCloth:
      // 라이프 클로스 안에서 순서를 바꾼 것은 「加えられた」가 아니다(WD06-007 FAQ 2)
      ev.code = (from != kNoZone && state.zones.get(from).kind == ZoneKind::LifeCloth) ? 0 : EVENT_LIFE_ADDED;
      ev.player = card.owner;
      break;
    default: ev.code = 0;
  }
  if (ev.code) collect(ev, &before);
  if (base != kNoCard) {
    Event rise;
    rise.code = EVENT_RISEN;
    rise.cards = {base};
    rise.player = card.controller;
    rise.reason = reason;
    rise.reason_player = rp;
    rise.source = c;
    collect(rise, &base_before);
  }
  return true;
}

// 바니시: 에나 존으로(용어집: バニッシュ)
bool Duel::banish(CardIdx c, uint32_t reason, PlayerId rp, EffectId re, CardIdx by) {
  if (has_keyword(c, EFFECT_CANNOT_BANISH)) return false;
  if (const Effect* src = effects.get(re); src && (reason & REASON_EFFECT) && (immune(c, *src) || banish_immune(c, *src))) return false;
  // 「次にバニッシュされる場合、バニッシュされない」(WX15-010): 한 번 막고 지워진다
  if (effects.seen(EFFECT_BANISH_ONCE) && has_keyword(c, EFFECT_BANISH_ONCE)) {
    delete_effect(affecting(c, EFFECT_BANISH_ONCE).front()->id);
    return false;
  }
  // 파워 0 이하로 룰에 의해 바니시될 때 대신 트래시(WX04-038)
  const bool zero = (reason & REASON_RULE) && player_affected(state.cards.get(c).controller, EFFECT_ZERO_TO_TRASH);
  // 「このシグニによってバニッシュされる場合…トラッシュ」(WX09-022): 배틀은 by, 효과는 그 효과의 카드
  CardIdx killer = by;
  if (killer == kNoCard)
    if (const Effect* src = effects.get(re)) killer = src->handler;
  const bool kill = killer != kNoCard && effects.seen(EFFECT_KILL_TO_TRASH) && (location_of(killer) & LOCATION_SZONE) &&
                    state.cards.get(killer).controller != state.cards.get(c).controller && has_keyword(killer, EFFECT_KILL_TO_TRASH);
  const ZoneKind to = has_keyword(c, EFFECT_BANISH_TO_TRASH) || zero || kill ? ZoneKind::Trash : ZoneKind::Ena;
  const Card& card = state.cards.get(c);
  const std::vector<EffectId> before = active_single_triggers(c);
  Event ev;
  ev.code = EVENT_BANISHED;
  ev.value = level_of(c);  // 바니시되기 직전의 레벨
  ev.cards = {c};
  ev.player = card.controller;
  ev.reason = reason;
  ev.reason_player = rp;
  ev.reason_effect = re;
  // 「シグニが…バニッシュしたとき」: 배틀한 시그니나, 장에 있는 시그니의 능력(WX07-036 FAQ, WXK09-048 FAQ)
  if (by == kNoCard && (reason & REASON_EFFECT))
    if (const Effect* e = effects.get(re); e && e->handler != kNoCard && (location_of(e->handler) & LOCATION_SZONE))
      by = e->handler;
  ++players[card.controller].banished_this_turn;
  move_card(c, state.zones.find(card.owner, to), reason | REASON_BANISH, rp, Pos::Top, re);
  ev.source = banisher = by;
  collect(ev, &before);
  banisher = kNoCard;
  return true;
}

bool Duel::same_name(CardIdx a, CardIdx b) {
  auto key = [&](CardIdx c) {
    const Cid t = text_of(c);
    const Cid alias = data(t).alias;
    return alias ? alias : t;
  };
  return key(a) == key(b);
}

void Duel::blood_arm(CardIdx host, CardIdx from, PlayerId rp) {
  state.put_under(from, host);
  Card& h = state.cards.get(host);
  if (h.flags & CF_BLOOD) return;  // 이미 血晶武装状態면 「なったとき」는 트리거하지 않는다(WDK08-L01 FAQ 2)
  set_flags(host, h.flags | CF_BLOOD);
  Event ev;
  ev.code = EVENT_BLOOD_ARMED;
  ev.cards = {host};
  ev.player = h.controller;
  ev.reason_player = rp;
  raise(ev);
}

std::vector<CardIdx> Duel::ena_charge(PlayerId p, uint32_t n, uint32_t reason, PlayerId rp, EffectId re) {
  const ZoneId deck = state.zones.find(p, ZoneKind::MainDeck);
  const ZoneId ena = state.zones.find(p, ZoneKind::Ena);
  std::vector<CardIdx> moved;
  while (moved.size() < n) {
    const CardIdx c = top_of(deck);
    if (c == kNoCard) break;  // 도중에 덱이 없어지면 거기서 끝(WXDi-D01-013 FAQ 1). 리프레시는 룰 처리에서
    move_card(c, ena, reason, rp, Pos::Top, re);
    moved.push_back(c);
  }
  return moved;
}

void Duel::flush_deck_moves() {
  if (deck_moved_.empty()) return;
  Event ev;
  ev.code = EVENT_MOVED_TO_DECK;
  ev.cards = std::exchange(deck_moved_, {});
  ev.reason = REASON_EFFECT;
  ev.reason_player = deck_moved_player_;
  ev.reason_effect = deck_moved_effect_;
  ev.player = deck_moved_player_;
  raise(ev);
}

void Duel::move_to_deck_position(CardIdx c, uint32_t n, uint32_t reason, PlayerId rp, EffectId re) {
  const ZoneId deck = state.zones.find(state.cards.get(c).owner, ZoneKind::MainDeck);
  const size_t before = state.zones.get(deck).cards.size();
  if (n <= 1) {
    move_card(c, deck, reason, rp, Pos::Top, re);
    return;
  }
  if (before < n - 1) {
    move_card(c, deck, reason, rp, Pos::Bottom, re);
    return;
  }
  move_card(c, deck, reason, rp, Pos::Top, re);
  // 맨 위(back)에 놓인 것을 위에서 n번째로. 다른 카드는 아무도 보지 못하고 순서도 바뀌지 않는다(WDK09-011 FAQ 3)
  auto& cards = state.zones.get(deck).cards;
  cards.pop_back();
  cards.insert(cards.end() - static_cast<std::ptrdiff_t>(n - 1), c);
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
    if (!move_card(c, hand, reason, p)) break;  // 패에 넣을 수 없다(WX05-022)
    ev.cards.push_back(c);
  }
  if (drawn) {
    if (phase == PHASE_ATTACK) players[p].drawn_attack_this_turn += drawn;
    ev.value = static_cast<int32_t>(drawn);
    raise(ev);
    const std::vector<CardIdx> cards = ev.cards;
    for (CardIdx c : cards) {
      ev.code = EVENT_DRAW_ONE;
      ev.cards = {c};
      ev.value = 1;
      raise(ev);
    }
  }
  return drawn;
}

void Duel::restore_zone(ZoneId z) {
  state.zones.set_absent(z, false);
  msg_zones();
}

void Duel::remove_zone(ZoneId z, PlayerId rp, EffectId re) {
  Zone& zone = state.zones.get(z);
  auto trash_of = [&](CardIdx c) { return state.zones.find(state.cards.get(c).owner, ZoneKind::Trash); };
  // 시그니 → 그 아래 카드·붙은 카드(이동하면 leftovers로 남는다) → 트랩
  // 존이 없어지는 것이라 「効果を受けない」 시그니도 남지 못한다
  for (CardIdx c : std::vector<CardIdx>(zone.cards))
    if (!move_card(c, trash_of(c), REASON_EFFECT, rp, Pos::Top, re)) move_card(c, trash_of(c), REASON_RULE, rp);
  for (CardIdx c : std::vector<CardIdx>(zone.leftovers)) {
    const bool lrig = data(state.cards.get(c).cid).type & (TYPE_LRIG | TYPE_ASSIST_LRIG);
    move_card(c, lrig ? state.zones.find(state.cards.get(c).owner, ZoneKind::LrigTrash) : trash_of(c), REASON_RULE, rp);
  }
  for (CardIdx c : {zone.set_card, zone.seed_card})
    if (c != kNoCard) move_card(c, trash_of(c), REASON_EFFECT, rp, Pos::Top, re);
  // 【ゲート】·【ウィルス】는 카드가 아니라 그냥 사라진다(WXK03-005 FAQ 5)
  for (bool* mark : {&zone.gate, &zone.virus})
    if (*mark) {
      *mark = false;
      msg_marker(z, mark == &zone.gate ? 1 : 2);
    }
  state.zones.set_absent(z, true);
  msg_zones();
}

}  // namespace wx
