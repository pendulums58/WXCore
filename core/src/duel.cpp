#include "duel.h"

#include <lua.h>

namespace wx {

Duel::Duel(DuelConfig cfg) : state(cfg.seed), cfg_(std::move(cfg)) {
  strings_.push_back("");  // id 0 = 빈 문자열
  state.on_move = [this](const MoveRecord& r) { on_move(r); };
  state.on_shuffle = [this](ZoneId z) { on_shuffle(z); };
  msg_zones();
  init_lua();
}

Duel::~Duel() {
  if (L_) lua_close(L_);
}

const CardData& Duel::data(Cid cid) {
  auto it = data_.find(cid);
  if (it != data_.end()) return it->second;
  CardData d;
  d.cid = cid;
  if (!cfg_.card_data || !cfg_.card_data(cid, d)) log("카드 데이터 없음: cid " + std::to_string(cid));
  d.cid = cid;
  return data_.emplace(cid, std::move(d)).first->second;
}

void Duel::log(const std::string& msg) const {
  if (cfg_.log) cfg_.log(msg);
}

uint32_t Duel::intern(const std::string& s) {
  auto it = string_ids_.find(s);
  if (it != string_ids_.end()) return it->second;
  uint32_t id = static_cast<uint32_t>(strings_.size());
  strings_.push_back(s);
  string_ids_.emplace(s, id);
  return id;
}

CardIdx Duel::new_card(Cid cid, PlayerId owner, ZoneId zone, Pos pos) {
  CardIdx c = state.create_card(cid, owner, zone, pos);
  run_initial_effect(c, cid, kNoEffect);
  return c;
}

void Duel::set_deck(PlayerId p, const std::vector<Cid>& main, const std::vector<Cid>& lrig) {
  for (Cid cid : main) new_card(cid, p, state.zones.find(p, ZoneKind::MainDeck));
  for (Cid cid : lrig) new_card(cid, p, state.zones.find(p, ZoneKind::LrigDeck));
}

CardIdx Duel::occupant(ZoneId z) const {
  const Zone& zone = state.zones.get(z);
  return zone.cards.empty() ? kNoCard : zone.cards.back();
}

CardIdx Duel::top_of(ZoneId z) const { return occupant(z); }

CardIdx Duel::center_lrig(PlayerId p) const { return occupant(state.zones.find(p, ZoneKind::LrigCenter)); }

// 센터 리미트 + 어시스트 리미트(용어집: リミット)
int32_t Duel::total_limit(PlayerId p) {
  int32_t sum = 0;
  for (ZoneId z : state.zones.in_group(p, ZG_LRIG)) {
    const ZoneKind k = state.zones.get(z).kind;
    CardIdx c = occupant(z);
    if (c != kNoCard && (k == ZoneKind::LrigCenter || k == ZoneKind::LrigAssist)) sum += limit_of(c);
  }
  return sum;
}

// 한정 조건이 센터 루리그의 루리그 타입과 맞는가(용어집: 限定条件, ルール処理 9)
bool Duel::limit_cond_ok(CardIdx c, PlayerId p) {
  const auto& conds = data(text_of(c)).limit_cond;
  if (conds.empty()) return true;
  CardIdx center = center_lrig(p);
  if (center == kNoCard) return false;
  for (uint32_t t : classes_of(center))
    for (const auto& cond : conds)
      if (str(t) == cond) return true;
  return false;
}

// 메인 페이즈에 패에서 시그니를 낼 수 있는가(용어집: メインフェイズ 1, リミット)
bool Duel::can_play_signi(CardIdx c, ZoneId z) {
  const Card& card = state.cards.get(c);
  const Zone& zone = state.zones.get(z);
  if (zone.kind != ZoneKind::Signi || zone.absent || zone.owner != card.controller) return false;
  if (!zone.cards.empty()) return false;
  if (!(type_of(c) & TYPE_SIGNI)) return false;
  CardIdx center = center_lrig(card.controller);
  if (center == kNoCard || level_of(c) > level_of(center)) return false;
  int32_t sum = level_of(c);
  for (ZoneId s : state.zones.zones_of(card.controller, ZoneKind::Signi))
    if (CardIdx o = occupant(s); o != kNoCard) sum += level_of(o);
  if (sum > total_limit(card.controller)) return false;
  return limit_cond_ok(c, card.controller);
}

uint32_t Duel::location_of(CardIdx c) const {
  const Card& card = state.cards.get(c);
  if (card.host != kNoCard || card.zone == kNoZone) return 0;
  return loc_bit(state.zones.get(card.zone).kind);
}

// ── 등록 ──

void Duel::register_effect(EffectId id, CardIdx handler) {
  Effect& e = *effects.get(id);
  Card& card = state.cards.get(handler);
  e.handler = handler;
  e.registered = true;
  if (handler == init_card_) {
    e.printed = true;
    e.text_cid = init_text_;
    e.copy_of = init_copy_;
  } else {
    e.bind_oid = card.oid;
    e.timestamp = state.cards.tick();
  }
  if (e.owner_player == kNoPlayer) e.owner_player = card.controller;
}

void Duel::grant_effect(EffectId id, CardIdx handler) {
  Effect& e = *effects.get(id);
  Card& card = state.cards.get(handler);
  e.handler = handler;
  e.registered = true;
  e.granted = true;
  e.bind_oid = card.oid;
  e.timestamp = state.cards.tick();
  if (e.owner_player == kNoPlayer) e.owner_player = card.controller;
}

void Duel::register_player_effect(EffectId id, PlayerId p) {
  Effect& e = *effects.get(id);
  e.handler = kNoCard;
  e.registered = true;
  e.timestamp = state.cards.tick();
  if (e.owner_player == kNoPlayer) e.owner_player = p;
}

void Duel::delete_effect(EffectId id) {
  Effect* e = effects.get(id);
  if (!e || e->deleted) return;
  e->deleted = true;
  // Lua 참조는 남겨 둔다. 이미 트리거해서 대기 중인 능력은 지워진 뒤에도 처리된다.
  // 복사로 생긴 인쇄 효과는 복사와 함께 사라진다
  effects.for_each([&](Effect& x) {
    if (x.copy_of == id) delete_effect(x.id);
  });
}

bool Duel::effect_live(const Effect& e) const {
  if (!e.registered || e.deleted) return false;
  if (e.copy_of != kNoEffect) {
    const Effect* cp = effects.get(e.copy_of);
    if (!cp || !effect_live(*cp)) return false;
  }
  if (!e.printed && e.handler != kNoCard) return state.cards.get(e.handler).oid == e.bind_oid;
  return true;
}

// ── 조작 ──

EffectId Duel::become_copy(CardIdx c, Cid cid, PlayerId by, uint32_t reset) {
  // 제거: 그 객체에 걸린 고정 효과(수정·얻은 능력·이전 복사). 상태 플래그는 남는다(FAQ 8)
  effects.for_each([&](Effect& e) {
    if (e.handler == c && !e.printed && (e.type & EFFECT_TYPE_SINGLE) && effect_live(e))
      delete_effect(e.id);
  });
  EffectId id = effects.create();
  Effect& e = *effects.get(id);
  e.type = EFFECT_TYPE_SINGLE;
  e.code = EFFECT_COPY;
  e.value = static_cast<int32_t>(cid);  // 처리 시점 값으로 고정(FAQ 16)
  e.owner_player = by;
  e.reset = reset;
  register_effect(id, c);
  run_initial_effect(c, cid, id);
  return id;
}

EffectId Duel::suppress_opponent_effects(PlayerId by, uint32_t reset) {
  const PlayerId opp = opponent(by);
  EffectId id = effects.create();
  Effect& s = *effects.get(id);
  s.type = EFFECT_TYPE_FIELD;
  s.code = EFFECT_SUPPRESS;
  s.owner_player = by;
  s.reset = reset;
  effects.for_each([&](Effect& e) {
    if (!effect_live(e)) return;
    if (e.printed) {
      // 공개 영역에 있는 카드의 트리거가 아닌 【常】만(FAQ 5-1, 25·26)
      if (!e.is_continuous() || e.handler == kNoCard) return;
      const Card& h = state.cards.get(e.handler);
      if (h.controller != opp || h.zone == kNoZone || !h.face_up) return;
      if (state.zones.get(h.zone).vis != ZoneVis::Public) return;
      s.snapshot.push_back({e.id, h.oid});
    } else if (e.owner_player == opp) {
      // 이미 쓰인 효과와 그것이 만든 지속 효과·트리거(FAQ 5-2·3, 19)
      s.snapshot.push_back({e.id, kNoObj});
    }
  });
  register_player_effect(id, by);
  return id;
}

void Duel::reset_phase(uint32_t phase_bit) {
  effects.for_each([&](Effect& e) {
    if (!effect_live(e)) {
      if (!e.printed) delete_effect(e.id);  // 끊긴 생성 효과 정리
      return;
    }
    if ((e.reset & RESET_PHASE) && (e.reset & phase_bit)) {
      if (e.reset_count <= 1)
        delete_effect(e.id);
      else
        --e.reset_count;
    }
  });
}

}  // namespace wx
