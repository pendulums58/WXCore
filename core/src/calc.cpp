// 카드 값 계산. 값은 저장하지 않고 레이어 순서대로 매번 다시 계산한다.
// 레이어: 1 정체·복사 → 2 특성 → 3 능력 → 4 파워 설정 → 5 파워 수정.
// 같은 레이어 안에서는 타임스탬프 순서.
#include <algorithm>
#include <initializer_list>

#include "duel.h"

namespace wx {

// 같은 카드의 같은 값을 계산하는 도중 다시 들어오면(서로 참조) 기본값을 쓴다.
struct Duel::Guard {
  Duel& d;
  uint64_t key;
  bool active;
  Guard(Duel& duel, CardIdx c, Calc k)
      : d(duel), key((static_cast<uint64_t>(c) << 8) | static_cast<uint64_t>(k)) {
    active = d.computing_.insert(key).second;
  }
  ~Guard() {
    if (active) d.computing_.erase(key);
  }
};

bool Duel::computing(CardIdx c, Calc k) const {
  return computing_.count((static_cast<uint64_t>(c) << 8) | static_cast<uint64_t>(k)) != 0;
}

uint64_t Duel::time_of(const Effect& e) const {
  if (!e.printed) return e.timestamp;
  uint64_t t = e.handler != kNoCard ? state.cards.get(e.handler).obj_time : 0;
  if (e.copy_of != kNoEffect) t = std::max(t, effects.get(e.copy_of)->timestamp);
  return t;
}

int32_t Duel::eval_value(Effect& e, CardIdx c) {
  return e.value_ref ? call_value(e.value_ref, e.id, c) : e.value;
}

bool Duel::effect_suppressed(const Effect& e) {
  // 억제 효과의 스냅샷은 그보다 먼저 있던 효과만 담으므로 재귀는 끝난다
  bool found = false;
  if (!effects.seen(EFFECT_SUPPRESS)) return false;
  effects.for_each([&](Effect& s) {
    if (found || s.code != EFFECT_SUPPRESS || &s == &e || !effect_live(s)) return;
    for (auto [id, oid] : s.snapshot) {
      if (id != e.id) continue;
      if (oid != kNoObj && (e.handler == kNoCard || state.cards.get(e.handler).oid != oid)) continue;
      if (!effect_suppressed(s)) found = true;
      break;
    }
  });
  return found;
}

// 그 카드의 이 분류 능력이 막혀 있는가. 막는 효과 자신을 판정하는 중이면 막히지 않은 것으로 본다
bool Duel::ability_disabled(const Effect& e) {
  if (!effects.seen(EFFECT_DISABLE_ABILITY) || e.handler == kNoCard) return false;
  const uint32_t kind = ability_type_of(e);
  if (!kind) return false;
  Guard g(*this, e.handler, Calc::Disabled);
  if (!g.active) return false;
  for (Effect* d : affecting(e.handler, EFFECT_DISABLE_ABILITY))
    if (static_cast<uint32_t>(eval_value(*d, e.handler)) & kind) return true;
  return false;
}

bool Duel::ability_active(Effect& e) {
  // 범위 검사가 먼저다. 영역 밖 카드끼리 봉쇄 판정이 서로 재귀하지 않게(WX14-023 미러)
  if (e.handler == kNoCard) return false;
  if (e.range && !(location_of(e.handler) & e.range)) return false;
  if (ability_disabled(e)) return false;
  if (e.printed) {
    auto [text, copy] = text_source(e.handler);
    if (e.text_cid != text || e.copy_of != copy) return false;
  }
  // 능력 목록을 계산하는 중이면 가진 것으로 본다
  if (computing(e.handler, Calc::Abilities)) return true;
  auto list = abilities_of(e.handler);
  return std::find(list.begin(), list.end(), e.id) != list.end();
}

namespace {
// 「効果を受けない」가 막는 지속 효과: 파워나 텍스트를 바꾸는 것, 색 등(용어집: 効果を受けない 1·3)
bool immune_code(uint32_t code) {
  return (code >= EFFECT_COPY && code < EFFECT_SUPPRESS) || code == EFFECT_GRANT;
}
}  // namespace

bool Duel::immune(CardIdx c, const Effect& src) { return immune_by(c, src, EFFECT_IMMUNE); }
bool Duel::banish_immune(CardIdx c, const Effect& src) { return immune_by(c, src, EFFECT_BANISH_IMMUNE); }

bool Duel::immune_by(CardIdx c, const Effect& src, uint32_t code) {
  if (!effects.seen(code) || !(location_of(c) & (LOCATION_SZONE | LOCATION_LRIG))) return false;
  std::vector<Effect*> list = affecting(c, code);
  if (list.empty()) return false;
  // 능력은 그것을 가진 카드, 능력이 만든 지속 효과는 만든 카드가 출처
  const bool own = (src.type & kActionTypes) || src.printed;
  const CardIdx from = own && src.handler != kNoCard ? src.handler : src.owner_card;
  if (from == kNoCard) return false;
  // 라이프 버스트(또는 그것이 처리 중에 만든 효과)인가: 「ライフバーストの効果を受けない」(WX11-027)
  bool burst = (src.type & EFFECT_TYPE_LIFEBURST) != 0;
  if (!burst && !chain.empty())
    if (const Effect* top = effects.get(chain.back().effect)) burst = (top->type & EFFECT_TYPE_LIFEBURST) && top->handler == from;
  for (Effect* e : list)
    if (e->value_ref && call_immune(e->value_ref, e->id, from, src.owner_player, burst)) return true;
  return false;
}

std::vector<Effect*> Duel::player_effects(PlayerId p, uint32_t code) {
  std::vector<Effect*> list, out;
  if (!effects.seen(code)) return out;
  effects.for_each([&](Effect& e) {
    if (e.code == code && (e.type & EFFECT_TYPE_FIELD)) list.push_back(&e);
  });
  for (Effect* e : list) {
    if (!effect_live(*e)) continue;
    PlayerId ctrl = e->owner_player;
    if (e->handler != kNoCard) {
      if (e->is_ability() ? !ability_active(*e) : (e->range && !(location_of(e->handler) & e->range))) continue;
      ctrl = state.cards.get(e->handler).controller;
    }
    if (!(p == ctrl ? e->target_self : e->target_opp)) continue;
    if (effect_suppressed(*e) || (e->condition_ref && !call_condition(e->condition_ref, e->id))) continue;
    out.push_back(e);
  }
  return out;
}

bool Duel::affects(Effect& e, CardIdx c) {
  if (!effect_live(e) || !e.is_continuous()) return false;
  if (e.type & EFFECT_TYPE_SINGLE) {
    if (e.handler != c) return false;
    if (e.is_ability() && !ability_active(e)) return false;
  } else if (e.type & EFFECT_TYPE_FIELD) {
    if (e.handler != kNoCard) {
      if (e.is_ability()) {
        if (!ability_active(e)) return false;
      } else if (e.range && !(location_of(e.handler) & e.range)) {
        return false;
      }
    }
    const Card& card = state.cards.get(c);
    const uint32_t loc = location_of(c);
    if (!loc) return false;
    const PlayerId ctrl = e.handler != kNoCard ? state.cards.get(e.handler).controller : e.owner_player;
    const uint32_t mask = state.zones.get(card.zone).owner == ctrl ? e.target_self : e.target_opp;
    if (!(loc & mask)) return false;
    if (e.target_ref && !call_filter(e.target_ref, e.id, c)) return false;
  } else {
    return false;
  }
  if (e.condition_ref && !call_condition(e.condition_ref, e.id)) return false;
  if (effect_suppressed(e)) return false;
  return !(immune_code(e.code) && !(e.printed && e.handler == c) && immune(c, e));
}

std::vector<Effect*> Duel::affecting(CardIdx c, uint32_t code) {
  std::vector<Effect*> out;
  if (!effects.seen(code)) return out;
  effects.for_each([&](Effect& e) {
    if (e.code == code) out.push_back(&e);
  });
  // for_each 도중 Lua가 효과를 만들 수 있어서 판정은 모은 뒤에 한다
  std::erase_if(out, [&](Effect* e) { return !affects(*e, c); });
  std::stable_sort(out.begin(), out.end(),
                   [&](Effect* a, Effect* b) { return time_of(*a) < time_of(*b); });
  return out;
}

// ── 레이어 1 ──

std::pair<Cid, EffectId> Duel::text_source(CardIdx c) {
  const Cid own = state.cards.get(c).cid;
  Guard g(*this, c, Calc::Text);
  if (!g.active) return {own, kNoEffect};
  auto list = affecting(c, EFFECT_COPY);
  if (list.empty()) return {own, kNoEffect};
  return {static_cast<Cid>(list.back()->value), list.back()->id};
}

Cid Duel::text_of(CardIdx c) { return text_source(c).first; }

// 레조나는 시그니의 한 종류(용어집: レゾナ 1, 설계: 종류). DB에는 レゾナ 비트만 있으므로 여기서 시그니 비트를 붙인다
uint32_t Duel::type_of(CardIdx c) {
  const uint32_t t = data(text_of(c)).type;
  return (t & TYPE_RESONA) ? (t | TYPE_SIGNI) : t;
}

// ── 레이어 2 ──

uint8_t Duel::color_of(CardIdx c) {
  uint8_t v = data(text_of(c)).color;
  Guard g(*this, c, Calc::Color);
  if (!g.active) return v;
  std::vector<Effect*> list = affecting(c, EFFECT_CHANGE_COLOR);
  auto add = affecting(c, EFFECT_ADD_COLOR);
  list.insert(list.end(), add.begin(), add.end());
  std::stable_sort(list.begin(), list.end(),
                   [&](Effect* a, Effect* b) { return time_of(*a) < time_of(*b); });
  for (Effect* e : list) {
    const uint8_t x = static_cast<uint8_t>(eval_value(*e, c));
    v = e->code == EFFECT_CHANGE_COLOR ? x : static_cast<uint8_t>(v | x);
  }
  return v;
}

std::vector<uint32_t> Duel::classes_of(CardIdx c) {
  std::vector<uint32_t> v = data(text_of(c)).classes;
  Guard g(*this, c, Calc::Classes);
  if (!g.active) return v;
  for (Effect* e : affecting(c, EFFECT_ADD_CLASS)) {
    const uint32_t id = static_cast<uint32_t>(eval_value(*e, c));
    if (std::find(v.begin(), v.end(), id) == v.end()) v.push_back(id);
  }
  return v;
}

bool Duel::has_class(CardIdx c, uint32_t sys, uint32_t race) {
  for (uint32_t code : classes_of(c))
    if (class_matches(code, sys, race)) return true;
  return false;
}

// 루리그 타입(용어집: ルリグタイプ). 바꾸는 효과는 아직 없다
std::vector<uint32_t> Duel::lrig_types_of(CardIdx c) {
  const auto& chosen = state.cards.get(c).chosen_lrig_types;
  std::vector<uint32_t> v = chosen.empty() ? data(text_of(c)).lrig_types : chosen;
  // 「ルリグタイプを追加で得る」(WDK17-001)
  for (Effect* e : affecting(c, EFFECT_ADD_LRIG_TYPE)) {
    const uint32_t t = static_cast<uint32_t>(eval_value(*e, c));
    if (t && std::find(v.begin(), v.end(), t) == v.end()) v.push_back(t);
  }
  return v;
}

int32_t Duel::level_of(CardIdx c) {
  int32_t v = data(text_of(c)).level;
  Guard g(*this, c, Calc::Level);
  if (!g.active) return v;
  std::vector<Effect*> list = affecting(c, EFFECT_CHANGE_LEVEL);
  auto upd = affecting(c, EFFECT_UPDATE_LEVEL);
  list.insert(list.end(), upd.begin(), upd.end());
  std::stable_sort(list.begin(), list.end(),
                   [&](Effect* a, Effect* b) { return time_of(*a) < time_of(*b); });
  for (Effect* e : list) {
    const int32_t x = eval_value(*e, c);
    v = e->code == EFFECT_CHANGE_LEVEL ? x : v + x;
  }
  return std::max(0, v);  // 레벨은 0 미만이 되지 않는다(WD22-018)
}

int32_t Duel::limit_of(CardIdx c) {
  int32_t v = data(text_of(c)).limit;
  Guard g(*this, c, Calc::Limit);
  if (!g.active) return v;
  for (Effect* e : affecting(c, EFFECT_UPDATE_LIMIT)) v += eval_value(*e, c);
  return v;
}

// ── 레이어 3 ──
// 인쇄 능력이 바탕이고, 획득·상실을 타임스탬프 순서로 적용한다.
// 상실은 그 시점에 가진 능력만 지우고 나중에 얻은 능력은 남는다(SPK01-13 FAQ 5, SP23-009 FAQ 3).

std::vector<EffectId> Duel::abilities_of(CardIdx c) {
  auto [text, copy] = text_source(c);
  std::vector<EffectId> set;
  effects.for_each([&](Effect& e) {
    if (e.handler == c && e.printed && e.text_cid == text && e.copy_of == copy && effect_live(e))
      set.push_back(e.id);
  });
  Guard g(*this, c, Calc::Abilities);
  if (!g.active) return set;

  struct Op {
    uint64_t t;
    EffectId add;  // kNoEffect = 전부 상실
  };
  std::vector<Op> ops;
  std::vector<Effect*> granted;
  effects.for_each([&](Effect& e) {
    if (e.handler == c && e.granted) granted.push_back(&e);
  });
  for (Effect* e : granted) {
    if (!effect_live(*e) || effect_suppressed(*e)) continue;
    // 부여한 쪽(만든 카드)의 효과를 받지 않으면 얻지 않는다
    if (!e->grant_parent && e->owner_card != c) {
      Effect from = *e;
      from.type = EFFECT_TYPE_SINGLE;
      if (immune(c, from)) continue;
    }
    // EFFECT_GRANT의 복제는 부여가 지금도 이 카드에 걸려 있을 때만(동적)
    if (e->grant_parent) {
      Effect* parent = effects.get(e->grant_parent);
      if (!parent || !affects(*parent, c)) continue;
      // 루리그 트래시에서 복제한 【起】는 원래 루리그가 아직 루리그 트래시에 있을 때만
      if (e->grant_src && !grant_source_ok(*e)) continue;
    }
    ops.push_back({time_of(*e), e->id});
  }
  for (Effect* e : affecting(c, EFFECT_LOSE_ABILITY)) ops.push_back({time_of(*e), kNoEffect});
  std::stable_sort(ops.begin(), ops.end(), [](const Op& a, const Op& b) { return a.t < b.t; });
  for (const Op& op : ops) {
    if (op.add == kNoEffect)
      set.clear();
    else
      set.push_back(op.add);
  }
  return set;
}

// ── 레이어 4·5 ──
// 설정을 먼저, 증감을 나중에 적용한다(WXK10-054 FAQ 2).

// 사용 리미트(WX22-025 FAQ: 「レベルは５ですが、…リミットは１０として扱われます」). 없으면 레벨
int32_t Duel::limit_cost_of(CardIdx c) {
  const int32_t v = data(text_of(c)).limit_cost;
  return v > 0 ? v : level_of(c);
}

int32_t Duel::power_raw(CardIdx c) {
  int32_t base = data(text_of(c)).power;
  if (base < 0) base = kPowerInfinity;
  Guard g(*this, c, Calc::Power);
  if (!g.active) return base;
  int32_t v = base;
  // 「対戦相手の効果によって、シグニのパワーは増減しない」(WX05-024): 그 능력을 가진 플레이어의 상대가 만든 변경은 무시
  uint8_t blocked = 0;  // 비트 p: p가 만든 변경은 무시
  if (effects.seen(EFFECT_NO_OPP_POWER))
    for (PlayerId p = 0; p < 2; ++p)
      if (player_affected(p, EFFECT_NO_OPP_POWER)) blocked |= static_cast<uint8_t>(1u << opponent(p));
  // 「対戦相手の効果によって、あなたの＜空獣＞…のパワーは増減しない」(WX12-033): 이 카드에 걸렸으면 컨트롤러의 상대가 만든 것은 무시
  if (effects.seen(EFFECT_NO_OPP_POWER_CARD) && !affecting(c, EFFECT_NO_OPP_POWER_CARD).empty())
    blocked |= static_cast<uint8_t>(1u << opponent(state.cards.get(c).controller));
  auto ok = [&](const Effect* e) {
    if (!blocked) return true;
    const PlayerId by = e->handler != kNoCard && (e->type & EFFECT_TYPE_FIELD) ? state.cards.get(e->handler).controller : e->owner_player;
    return by >= 2 || !(blocked & (1u << by)) || (e->printed && e->handler == c);
  };
  for (Effect* e : affecting(c, EFFECT_SET_BASE_POWER)) v = eval_value(*e, c);
  for (Effect* e : affecting(c, EFFECT_SET_POWER))
    if (ok(e)) v = eval_value(*e, c);
  // 「対戦相手のシグニのパワーが対戦相手の効果によって＋される場合、代わりに－」(WX09-021)
  uint8_t invert = 0;  // 비트 p: p의 시그니에 p가 만든 ＋는 －
  if (effects.seen(EFFECT_INVERT_PLUS))
    for (PlayerId p = 0; p < 2; ++p)
      if (player_affected(p, EFFECT_INVERT_PLUS)) invert |= static_cast<uint8_t>(1u << opponent(p));
  const PlayerId owner_c = state.cards.get(c).controller;
  for (Effect* e : affecting(c, EFFECT_UPDATE_POWER)) {
    if (!ok(e)) continue;
    int32_t x = eval_value(*e, c);
    if (x > 0 && owner_c < 2 && (invert & (1u << owner_c))) {
      const PlayerId by = e->handler != kNoCard && (e->type & EFFECT_TYPE_FIELD) ? state.cards.get(e->handler).controller : e->owner_player;
      if (by == owner_c) x = -x;
    }
    v += x;
  }
  return v;
}

int32_t Duel::power_of(CardIdx c) { return std::max(0, power_raw(c)); }

bool Duel::has_keyword(CardIdx c, uint32_t code) { return !affecting(c, code).empty(); }

// ── 크로스(용어집: クロスシグニ, クロス条件) ──

bool Duel::cross_to(CardIdx c, CardIdx partner, int64_t side) {
  const Cid t = text_of(partner);
  const Cid alias = data(t).alias;
  for (Effect* e : affecting(c, EFFECT_CROSS)) {
    const Cid want = static_cast<Cid>(e->value);
    if (e->label == side && (want == t || (alias && want == alias))) return true;
  }
  return false;
}

std::vector<CardIdx> Duel::cross_group(CardIdx c) {
  std::vector<CardIdx> group{c};
  for (size_t i = 0; i < group.size(); ++i) {
    const CardIdx x = group[i];
    const Card& card = state.cards.get(x);
    if (card.zone == kNoZone || card.host != kNoCard || state.zones.get(card.zone).kind != ZoneKind::Signi) continue;
    auto link = [&](ZoneId z, int64_t mine, int64_t theirs) {
      const CardIdx o = z == kNoZone ? kNoCard : occupant(z);
      if (o == kNoCard || std::find(group.begin(), group.end(), o) != group.end()) return;
      if (cross_to(x, o, mine) || cross_to(o, x, theirs)) group.push_back(o);
    };
    link(state.zones.left(card.zone), CROSS_RIGHT, CROSS_LEFT);
    link(state.zones.right(card.zone), CROSS_LEFT, CROSS_RIGHT);
  }
  if (group.size() == 1) group.clear();
  return group;
}

uint8_t Duel::pay_color(CardIdx c) {
  if (!affecting(c, EFFECT_MULTI_ENA).empty()) return COLOR_WHITE | COLOR_RED | COLOR_BLUE | COLOR_GREEN | COLOR_BLACK;
  uint8_t col = color_of(c);
  if (effects.seen(EFFECT_ADD_PAY_COLOR))
    for (Effect* e : affecting(c, EFFECT_ADD_PAY_COLOR)) col |= static_cast<uint8_t>(eval_value(*e, c));
  return col;
}

}  // namespace wx
