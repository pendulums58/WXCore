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

bool Duel::ability_active(Effect& e) {
  if (e.handler == kNoCard) return false;
  if (e.range && !(location_of(e.handler) & e.range)) return false;
  if (e.printed) {
    auto [text, copy] = text_source(e.handler);
    if (e.text_cid != text || e.copy_of != copy) return false;
  }
  // 능력 목록을 계산하는 중이면 가진 것으로 본다
  if (computing(e.handler, Calc::Abilities)) return true;
  auto list = abilities_of(e.handler);
  return std::find(list.begin(), list.end(), e.id) != list.end();
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
  return !effect_suppressed(e);
}

std::vector<Effect*> Duel::affecting(CardIdx c, uint32_t code) {
  std::vector<Effect*> out;
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

uint32_t Duel::type_of(CardIdx c) { return data(text_of(c)).type; }

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
  std::vector<uint32_t> v;
  for (const auto& s : data(text_of(c)).classes) v.push_back(intern(s));
  Guard g(*this, c, Calc::Classes);
  if (!g.active) return v;
  for (Effect* e : affecting(c, EFFECT_ADD_CLASS)) {
    const uint32_t id = static_cast<uint32_t>(eval_value(*e, c));
    if (std::find(v.begin(), v.end(), id) == v.end()) v.push_back(id);
  }
  return v;
}

bool Duel::has_class(CardIdx c, const std::string& query) {
  for (uint32_t id : classes_of(c))
    if (class_matches(str(id), query)) return true;
  return false;
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
  return v;
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
    // EFFECT_GRANT의 복제는 부여가 지금도 이 카드에 걸려 있을 때만(동적)
    if (e->grant_parent) {
      Effect* parent = effects.get(e->grant_parent);
      if (!parent || !affects(*parent, c)) continue;
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

int32_t Duel::power_raw(CardIdx c) {
  int32_t base = data(text_of(c)).power;
  if (base < 0) base = kPowerInfinity;
  Guard g(*this, c, Calc::Power);
  if (!g.active) return base;
  int32_t v = base;
  for (Effect* e : affecting(c, EFFECT_SET_POWER)) v = eval_value(*e, c);
  for (Effect* e : affecting(c, EFFECT_UPDATE_POWER)) v += eval_value(*e, c);
  return v;
}

int32_t Duel::power_of(CardIdx c) { return std::max(0, power_raw(c)); }

bool Duel::has_keyword(CardIdx c, uint32_t code) { return !affecting(c, code).empty(); }

uint8_t Duel::pay_color(CardIdx c) {
  if (!affecting(c, EFFECT_MULTI_ENA).empty()) return COLOR_WHITE | COLOR_RED | COLOR_BLUE | COLOR_GREEN | COLOR_BLACK;
  return color_of(c);
}

}  // namespace wx
