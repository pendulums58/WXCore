#include "duel.h"

#include <lua.h>

#include <algorithm>

#include "cost.h"

namespace wx {

Duel::Duel(DuelConfig cfg) : state(cfg.seed), cfg_(std::move(cfg)) {
  strings_.push_back("");  // id 0 = 빈 문자열
  state.on_move = [this](const MoveRecord& r) { on_move(r); };
  state.on_shuffle = [this](ZoneId z) { on_shuffle(z); };
  if (cfg_.reset_message) msg_reset();
  msg_zones();
  init_lua();
}

Duel::~Duel() {
  // 멈춘 코루틴 프레임(Lua 스레드 참조 등)을 Lua 상태보다 먼저 없앤다. 선택 요청 도중에 닫혀도 안전하게
  resume_at_ = {};
  root_ = Task<>{};
  // 요청의 검증 함수도 Lua 참조를 쥐고 있다
  pending_req_.reset();
  lua_request.reset();
  lua_reply = nullptr;
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

bool Duel::has_data(Cid cid) {
  CardData d;
  return cid && cfg_.card_data && cfg_.card_data(cid, d);
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

CardIdx Duel::new_card(Cid cid, PlayerId owner, ZoneId zone, Pos pos, uint16_t print) {
  CardIdx c = state.create_card(cid, owner, zone, pos, print);
  run_initial_effect(c, cid, kNoEffect);
  return c;
}

void Duel::set_deck(PlayerId p, const std::vector<Cid>& main, const std::vector<Cid>& lrig,
                    const std::vector<uint16_t>& main_prints, const std::vector<uint16_t>& lrig_prints) {
  auto print = [](const std::vector<uint16_t>& v, size_t i) -> uint16_t { return i < v.size() ? v[i] : 1; };
  for (size_t i = 0; i < main.size(); ++i)
    new_card(main[i], p, state.zones.find(p, ZoneKind::MainDeck), Pos::Top, print(main_prints, i));
  for (size_t i = 0; i < lrig.size(); ++i)
    new_card(lrig[i], p, state.zones.find(p, ZoneKind::LrigDeck), Pos::Top, print(lrig_prints, i));
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
  for (uint32_t t : lrig_types_of(center))
    if (std::find(conds.begin(), conds.end(), t) != conds.end()) return true;
  return false;
}

// 메인 페이즈에 패에서 시그니를 낼 수 있는가(용어집: メインフェイズ 1, リミット)
bool Duel::can_play_signi(CardIdx c, ZoneId z) {
  const Card& card = state.cards.get(c);
  const Zone& zone = state.zones.get(z);
  if (zone.kind != ZoneKind::Signi || zone.absent || zone.owner != card.controller) return false;
  if (!(type_of(c) & TYPE_SIGNI) || has_keyword(c, EFFECT_CANNOT_PLAY)) return false;
  CardIdx center = center_lrig(card.controller);
  if (center == kNoCard || level_of(c) > level_of(center)) return false;
  return zone_ok(c, z, card.controller) && limit_cond_ok(c, card.controller);
}

bool Duel::rise_ok(CardIdx c, ZoneId z, PlayerId p) {
  const Zone& zone = state.zones.get(z);
  const CardIdx o = occupant(z);
  if (zone.kind != ZoneKind::Signi || zone.absent || zone.owner != p || o == kNoCard || o == c || !state.cards.get(o).face_up)
    return false;
  for (Effect* e : affecting(c, EFFECT_RISE))
    if (!e->target_ref || call_filter(e->target_ref, e->id, o)) return true;
  return false;
}

int32_t Duel::signi_limit(PlayerId p) {
  int32_t n = 3;
  for (Effect* e : player_effects(p, EFFECT_SIGNI_LIMIT)) n = std::min(n, static_cast<int32_t>(e->value));
  return n;
}

bool Duel::zone_ok(CardIdx c, ZoneId z, PlayerId p) {
  const bool rise = has_rise(c);
  if (rise ? !rise_ok(c, z, p) : !state.zones.get(z).cards.empty()) return false;
  // 「シグニを１体しか場に出すことができない」(WX04-005)
  if (!rise && effects.seen(EFFECT_SIGNI_LIMIT)) {
    int32_t n = 0;
    for (ZoneId s : state.zones.zones_of(p, ZoneKind::Signi))
      if (occupant(s) != kNoCard) ++n;
    if (n >= signi_limit(p)) return false;
  }
  // 「…シグニゾーンにシグニを新たに配置することができない」(WX08-032)
  if (effects.seen(EFFECT_ZONE_LOCK))
    for (Effect* e : player_effects(p, EFFECT_ZONE_LOCK))
      if (e->value == static_cast<int64_t>(z)) return false;
  // 밑에 놓이는 시그니는 레벨·리미트에 들지 않는다(WX15-043 FAQ)
  int32_t sum = limit_cost_of(c);
  for (ZoneId s : state.zones.zones_of(p, ZoneKind::Signi))
    if (CardIdx o = occupant(s); o != kNoCard && o != c && s != z) sum += limit_cost_of(o);
  if (sum > total_limit(p)) return false;
  if (!rise) return front_ok(p, z);
  // 정면 강제(EFFECT_MUST_FRONT): 라이즈할 수 있는 정면 존이 있으면 그중 하나에
  bool forced = false;
  for (ZoneId s : state.zones.zones_of(opponent(p), ZoneKind::Signi)) {
    const CardIdx o = occupant(s);
    const ZoneId f = state.zones.front(s);
    if (o == kNoCard || f == kNoZone || !has_keyword(o, EFFECT_MUST_FRONT) || !rise_ok(c, f, p)) continue;
    if (f == z) return true;
    forced = true;
  }
  return !forced;
}

// 「対戦相手がシグニを配置する場合、可能ならばこのシグニの正面に配置しなければならない」(EFFECT_MUST_FRONT):
// 그런 상대 시그니의 정면 중 빈 칸이 하나라도 있으면 p는 그 칸들에만 놓는다. 여럿이면 p가 고른다(WD07-009 FAQ 1)
bool Duel::front_ok(PlayerId p, ZoneId z) {
  bool forced = false;
  for (ZoneId s : state.zones.zones_of(opponent(p), ZoneKind::Signi)) {
    CardIdx o = occupant(s);
    if (o == kNoCard || !has_keyword(o, EFFECT_MUST_FRONT)) continue;
    const ZoneId f = state.zones.front(s);
    if (f == kNoZone || state.zones.get(f).absent || !state.zones.get(f).cards.empty()) continue;
    if (f == z) return true;
    forced = true;
  }
  return !forced;
}

int Duel::lrig_count(PlayerId p) const {
  int n = 0;
  for (ZoneId z : state.zones.in_group(p, ZG_LRIG)) {
    const ZoneKind k = state.zones.get(z).kind;
    if ((k == ZoneKind::LrigCenter || k == ZoneKind::LrigAssist) && occupant(z) != kNoCard) ++n;
  }
  return n;
}

bool Duel::team_ok(PlayerId p, const std::string& team) {
  int n = 0;
  for (ZoneId z : state.zones.in_group(p, ZG_LRIG)) {
    const ZoneKind k = state.zones.get(z).kind;
    if (k != ZoneKind::LrigCenter && k != ZoneKind::LrigAssist) continue;
    const CardIdx c = occupant(z);
    if (c == kNoCard) continue;
    const auto& teams = data(text_of(c)).teams;
    if (std::find(teams.begin(), teams.end(), team) == teams.end()) return false;
    ++n;
  }
  return n == 3;
}

std::vector<ZoneId> Duel::signi_zones_for(CardIdx c, PlayerId p) {
  std::vector<ZoneId> out;
  const CardIdx center = center_lrig(p);
  if (center == kNoCard || !(type_of(c) & TYPE_SIGNI) || level_of(c) > level_of(center)) return out;
  if (!limit_cond_ok(c, p) || has_keyword(c, EFFECT_CANNOT_PLAY)) return out;
  for (ZoneId z : state.zones.zones_of(p, ZoneKind::Signi))
    if (!state.zones.get(z).absent && zone_ok(c, z, p)) out.push_back(z);
  return out;
}

void Duel::confirm(PlayerId p, const std::vector<CardIdx>& cards) {
  for (CardIdx c : cards) {
    state.cards.get(c).known_by |= static_cast<uint8_t>(1u << p);
    msg_reveal(c);
  }
}

void Duel::reveal(const std::vector<CardIdx>& cards) {
  for (CardIdx c : cards) {
    state.cards.get(c).known_by = 0b11;
    msg_reveal(c, true);
  }
}

bool Duel::attach_acce(CardIdx c, CardIdx host) {
  const Card& card = state.cards.get(c);
  if (c == host || card.zone == kNoZone || card.host != kNoCard || state.is_leftover(c)) return false;
  if (!(location_of(host) & LOCATION_SZONE) || !state.cards.get(host).face_up || state.has_acce(host)) return false;
  state.attach(c, host, true);
  Event ev;
  ev.code = EVENT_ACCE;
  ev.cards = {host};
  ev.player = state.cards.get(host).controller;
  raise(ev);
  return true;
}

bool Duel::attach_charm(CardIdx c, CardIdx host) {
  const Card& card = state.cards.get(c);
  if (c == host || card.zone == kNoZone || card.host != kNoCard || state.is_leftover(c)) return false;
  if (!(location_of(host) & LOCATION_SZONE) || !state.cards.get(host).face_up || state.charm_of(host) != kNoCard) return false;
  state.attach(c, host);
  state.cards.get(c).charm = true;
  return true;
}

std::vector<EffectId> Duel::leave_guards(CardIdx c) {
  std::vector<EffectId> out;
  for (Effect* e : affecting(c, EFFECT_LEAVE_GUARD))
    if (e->handler != c) out.push_back(e->id);
  return out;
}

bool Duel::can_charm_guard(CardIdx c, uint32_t reason, EffectId re) {
  if (!effects.seen(EFFECT_CHARM_GUARD) || !(location_of(c) & LOCATION_SZONE) || state.charm_of(c) == kNoCard) return false;
  if (has_keyword(c, EFFECT_CANNOT_BANISH) || !has_keyword(c, EFFECT_CHARM_GUARD)) return false;
  const Effect* src = effects.get(re);
  return !(src && (reason & REASON_EFFECT) && immune(c, *src));
}

Request Duel::charm_request(CardIdx c) {
  Request r;
  r.type = ReqType::YesNo;
  r.player = state.cards.get(c).controller;
  r.hint = HINT_SCRIPT;
  r.options = {0, 1};
  r.source = c;
  r.source_desc = desc_of(affecting(c, EFFECT_CHARM_GUARD).front()->id);
  return r;
}

void Duel::charm_trash(CardIdx c) {
  const CardIdx ch = state.charm_of(c);
  move_card(ch, state.zones.find(state.cards.get(ch).owner, ZoneKind::Trash), REASON_EFFECT, state.cards.get(c).controller);
}

void Duel::set_seed(CardIdx c, ZoneId z) {
  Zone& zone = state.zones.get(z);
  if (zone.kind != ZoneKind::Signi || zone.absent || zone.seed_card == c) return;
  // 이미 있던 【シード】는 앞면으로 트래시에(용어집: シード)
  if (const CardIdx old = zone.seed_card; old != kNoCard)
    move_card(old, state.zones.find(state.cards.get(old).owner, ZoneKind::Trash), REASON_RULE, kNoPlayer);
  state.cards.get(c).prev_loc = location_of(c);
  state.set_face_down(c, z, true);
}

bool Duel::bloom(CardIdx c) {
  if (!state.is_seed(c)) return false;
  Card& card = state.cards.get(c);
  if (!state.zones.get(card.zone).cards.empty()) return false;
  if (!(data(card.cid).type & TYPE_SIGNI)) {  // 시그니가 아니면 앞면으로 하고 트래시에
    card.face_up = true;
    card.known_by = 0b11;
    msg_reveal(c, true);
    move_card(c, state.zones.find(card.owner, ZoneKind::Trash), REASON_RULE, kNoPlayer);
    return true;
  }
  card.prev_loc = LOCATION_SEED;
  state.bloom(c);
  Event ev;
  ev.code = EVENT_BLOOM;
  ev.cards = {c};
  ev.player = card.controller;
  raise(ev);
  return true;
}

void Duel::set_trap(CardIdx c, ZoneId z) {
  Zone& zone = state.zones.get(z);
  if (zone.kind != ZoneKind::Signi || zone.absent || zone.set_card == c) return;
  // 이미 있던 【トラップ】은 트래시로(용어집: トラップ)
  if (const CardIdx old = zone.set_card; old != kNoCard)
    move_card(old, state.zones.find(state.cards.get(old).owner, ZoneKind::Trash), REASON_RULE, kNoPlayer);
  state.cards.get(c).prev_loc = location_of(c);
  state.set_face_down(c, z);
}

EffectId Duel::trap_ability(CardIdx c) {
  EffectId id = kNoEffect;
  const Cid text = text_of(c);
  effects.for_each([&](Effect& e) {
    if (e.handler == c && e.printed && (e.type & EFFECT_TYPE_TRAP) && e.text_cid == text) id = e.id;
  });
  return id;
}

void Duel::open_trap(CardIdx c) {
  if (!state.is_set(c) || state.is_seed(c)) return;
  Card& card = state.cards.get(c);
  card.face_up = true;
  card.known_by = 0b11;
  msg_reveal(c, true);
  const EffectId id = trap_ability(c);
  if (id == kNoEffect) {  // 《トラップアイコン》이 없으면 아무 일 없이 트래시로(WD23-034 FAQ 2)
    move_card(c, state.zones.find(card.owner, ZoneKind::Trash), REASON_RULE, kNoPlayer);
    return;
  }
  Pending t;
  t.effect = id;
  t.handler = c;
  t.player = card.owner;
  t.trap_card = c;
  pending_[card.owner].push_back(std::move(t));
}

bool Duel::can_put_all(const std::vector<CardIdx>& cards, PlayerId p) {
  const CardIdx center = center_lrig(p);
  if (center == kNoCard) return cards.empty();
  int32_t sum = 0;
  size_t empty = 0;
  for (ZoneId z : state.zones.zones_of(p, ZoneKind::Signi)) {
    if (state.zones.get(z).absent) continue;
    if (CardIdx o = occupant(z); o != kNoCard) sum += limit_cost_of(o);
    else if (state.zones.get(z).cards.empty()) ++empty;
  }
  for (CardIdx c : cards) {
    if (!(type_of(c) & TYPE_SIGNI) || level_of(c) > level_of(center) || has_keyword(c, EFFECT_CANNOT_PLAY) || has_rise(c) ||
        !limit_cond_ok(c, p))
      return false;
    sum += limit_cost_of(c);
  }
  return cards.size() <= empty && sum <= total_limit(p);
}

bool Duel::is_drive(CardIdx c) {
  const PlayerId p = state.cards.get(c).controller;
  if (p > 1) return false;
  for (const auto& [s, oid] : players[p].rides) {
    if (state.cards.get(s).oid != oid || !(location_of(s) & LOCATION_SZONE)) continue;
    if (s == c || center_lrig(p) == c) return true;
  }
  return false;
}

void Duel::ride_on(PlayerId p, CardIdx c) {
  const CardIdx center = center_lrig(p);
  if (center == kNoCard || !(location_of(c) & LOCATION_SZONE)) return;
  const bool signi_was = is_drive(c), lrig_was = is_drive(center);
  players[p].rides = {{c, state.cards.get(c).oid}};
  Event ev;
  ev.code = EVENT_DRIVE;
  ev.player = p;
  // 이미 ドライブ状態였으면 「ドライブ状態になったとき」가 아니다(WDK01-012 FAQ 2)
  if (!signi_was) {
    ev.cards = {c};
    raise(ev);
  }
  if (!lrig_was) {
    ev.cards = {center};
    raise(ev);
  }
}

void Duel::gain_coin(PlayerId p, int32_t n) {
  if (n <= 0) return;
  players[p].coins = std::min<uint32_t>(5, players[p].coins + static_cast<uint32_t>(n));
  msg_coin(p);
}

void Duel::gain_subscribers(PlayerId p, uint32_t n) {
  if (n == 0) return;
  players[p].subscribers += n;
  msg_subscribers(p);
}

bool Duel::pay_coin(PlayerId p, uint32_t n) {
  if (players[p].coins < n) return false;
  if (n == 0) return true;
  players[p].coins -= n;
  msg_coin(p);
  return true;
}

bool Duel::place_gate(ZoneId z) {
  Zone& zone = state.zones.get(z);
  if (zone.gate || zone.absent) return false;
  zone.gate = true;
  msg_marker(z, 1);
  return true;
}

bool Duel::place_virus(ZoneId z) {
  Zone& zone = state.zones.get(z);
  if (zone.virus || zone.absent || zone.kind != ZoneKind::Signi) return false;
  zone.virus = true;
  msg_marker(z, 2);
  Event ev;
  ev.code = EVENT_VIRUS_PLACED;
  ev.player = zone.owner;
  ev.value = static_cast<int32_t>(z);
  raise(ev);
  return true;
}

bool Duel::remove_virus(ZoneId z, PlayerId by) {
  Zone& zone = state.zones.get(z);
  if (!zone.virus) return false;
  zone.virus = false;
  msg_marker(z, 2);
  Event ev;
  ev.code = EVENT_VIRUS_REMOVED;
  ev.player = zone.owner;
  ev.value = static_cast<int32_t>(z);
  ev.reason_player = by;
  raise(ev);
  return true;
}

// 감염 상태: 【ウィルス】가 있는 시그니 존에 있는 시그니. 존을 떠나거나 옮기면 아니다(용어집: 感染状態)
bool Duel::infected(CardIdx c) {
  const Card& card = state.cards.get(c);
  if (card.zone == kNoZone || card.host != kNoCard) return false;
  const Zone& z = state.zones.get(card.zone);
  return z.kind == ZoneKind::Signi && z.virus;
}

std::vector<CardIdx> Duel::exceed_cards(PlayerId p) {
  std::vector<CardIdx> out;
  for (ZoneId z : state.zones.in_group(p, ZG_LRIG)) {
    const ZoneKind k = state.zones.get(z).kind;
    if (k != ZoneKind::LrigCenter && k != ZoneKind::LrigAssist) continue;
    if (CardIdx c = occupant(z); c != kNoCard)
      for (CardIdx u : state.cards.get(c).under) out.push_back(u);
  }
  return out;
}

bool Duel::can_play_key(PlayerId p, CardIdx key) {
  const ZoneId kz = state.zones.find(p, ZoneKind::Key);
  if (kz == kNoZone || state.zones.get(kz).absent || !(type_of(key) & TYPE_KEY)) return false;
  const CardData& d = data(text_of(key));
  return limit_cond_ok(key, p) && !has_keyword(key, EFFECT_CANNOT_PLAY) && players[p].coins >= d.cost_coin &&
         ena_can_pay(parse_ena_cost(d.cost_ena), ena_colors(p));
}

// 복제한 【起】의 원래 루리그가 아직 그곳(루리그 트래시 / 이 카드 아래)에 있는가
bool Duel::grant_source_ok(const Effect& x) {
  const Effect* src = effects.get(x.grant_src);
  const Effect* parent = effects.get(x.grant_parent);
  if (!src || !parent) return false;
  if (parent->code == EFFECT_UNDER_IGNITION) {
    const auto& u = state.cards.get(x.handler).under;
    return std::find(u.begin(), u.end(), src->handler) != u.end();
  }
  return (location_of(src->handler) & LOCATION_LTRASH) != 0;
}

void Duel::sync_grants() {
  // 부여 대상 함수가 다시 능력을 보면(「能力を持たないシグニ」 등) 여기로 돌아온다: 다시 들어오지 않는다
  if (in_sync_) return;
  in_sync_ = true;
  struct Done {
    bool& f;
    ~Done() { f = false; }
  } done{in_sync_};
  // 「ルリグトラッシュにあるルリグの【起】能力を持つ」(WX05-002 등): 루리그 트래시 루리그의 인쇄된 【起】를 복제한다
  // 「このカードの下にあるルリグの【起】能力を持つ」(WX12-001)도 같은 방법으로 한다
  if (effects.seen(EFFECT_LTRASH_IGNITION) || effects.seen(EFFECT_UNDER_IGNITION)) {
    std::vector<std::pair<EffectId, CardIdx>> holders;
    effects.for_each([&](Effect& e) {
      if ((e.code == EFFECT_LTRASH_IGNITION || e.code == EFFECT_UNDER_IGNITION) && e.handler != kNoCard && effect_live(e) &&
          (location_of(e.handler) & LOCATION_LRIG))
        holders.emplace_back(e.id, e.handler);
    });
    // 원래 루리그가 루리그 트래시를 떠났거나 가진 쪽이 바뀌었으면 복제를 지운다
    std::vector<EffectId> stale;
    effects.for_each([&](Effect& x) {
      if (!x.grant_src || x.deleted) return;
      const Effect* src = effects.get(x.grant_src);
      const bool held = std::any_of(holders.begin(), holders.end(), [&](auto& h) { return h.first == x.grant_parent && h.second == x.handler; });
      if (!held || !src || src->deleted || !grant_source_ok(x)) stale.push_back(x.id);
    });
    for (EffectId id : stale) delete_effect(id);
    for (auto [pid, c] : holders) {
      const ObjId oid = state.cards.get(c).oid;
      const PlayerId p = state.cards.get(c).controller;
      std::vector<EffectId> srcs;
      const bool under = effects.get(pid)->code == EFFECT_UNDER_IGNITION;
      for (CardIdx l : under ? state.cards.get(c).under : state.zones.get(state.zones.find(p, ZoneKind::LrigTrash)).cards) {
        if (!(type_of(l) & TYPE_LRIG)) continue;
        effects.for_each([&](Effect& e) {
          if (e.handler == l && e.printed && (e.type & EFFECT_TYPE_IGNITION)) srcs.push_back(e.id);
        });
      }
      for (EffectId sid : srcs) {
        bool have = false;
        effects.for_each([&](Effect& x) { have |= x.grant_parent == pid && x.grant_src == sid && x.handler == c && x.bind_oid == oid; });
        if (have) continue;
        const Effect tmpl = *effects.get(sid);
        const EffectId id = effects.create();
        Effect& n = *effects.get(id);
        n = tmpl;
        n.id = id;
        n.registered = n.deleted = n.printed = false;
        n.grant_parent = pid;
        n.grant_src = sid;
        n.count_used = 0;
        n.count_oid = kNoObj;
        grant_effect(id, c);
      }
    }
  }
  std::vector<EffectId> parents;
  effects.for_each([&](Effect& e) {
    if (e.code == EFFECT_GRANT && (e.type & (EFFECT_TYPE_FIELD | EFFECT_TYPE_SINGLE)) && e.label_effect && effect_live(e))
      parents.push_back(e.id);
  });
  for (EffectId pid : parents) {
    Effect& pe = *effects.get(pid);
    const PlayerId ctrl = pe.handler != kNoCard ? state.cards.get(pe.handler).controller : pe.owner_player;
    // SINGLE이면 자기 자신이 얻는다(「このシグニは…を得る」)
    const std::vector<CardIdx> cands = (pe.type & EFFECT_TYPE_SINGLE)
                                           ? std::vector<CardIdx>(pe.handler != kNoCard ? 1 : 0, pe.handler)
                                           : cards_in(ctrl, pe.target_self, pe.target_opp);
    for (CardIdx c : cands) {
      if (!affects(*effects.get(pid), c)) continue;
      const ObjId oid = state.cards.get(c).oid;
      bool have = false;
      effects.for_each([&](Effect& x) { have |= x.grant_parent == pid && x.handler == c && x.bind_oid == oid; });
      if (have) continue;
      const Effect tmpl = *effects.get(effects.get(pid)->label_effect);
      const EffectId id = effects.create();
      Effect& n = *effects.get(id);
      n = tmpl;
      n.id = id;
      n.registered = n.deleted = n.printed = false;
      n.grant_parent = pid;
      n.count_used = 0;
      n.count_oid = kNoObj;
      grant_effect(id, c);
    }
  }
}

int32_t Duel::hand_limit(PlayerId p) {
  int32_t v = 6;
  effects.for_each([&](Effect& e) {
    if (e.code != EFFECT_UPDATE_HAND_LIMIT || !(e.type & EFFECT_TYPE_FIELD) || !effect_live(e)) return;
    PlayerId ctrl = e.owner_player;
    if (e.handler != kNoCard) {
      if (e.is_ability() ? !ability_active(e) : (e.range && !(location_of(e.handler) & e.range))) return;
      ctrl = state.cards.get(e.handler).controller;
    }
    if (effect_suppressed(e) || (e.condition_ref && !call_condition(e.condition_ref, e.id))) return;
    if ((p == ctrl && e.target_self) || (p != ctrl && e.target_opp)) v += e.value;
  });
  return v;
}

bool Duel::count_ok(Effect& e) {
  if (!e.count_limit) return true;
  if (!e.count_game && e.handler != kNoCard && state.cards.get(e.handler).oid != e.count_oid) return true;
  return e.count_used < e.count_limit;
}

void Duel::count_use(Effect& e) {
  if (!e.count_limit) return;
  const ObjId oid = e.handler != kNoCard ? state.cards.get(e.handler).oid : kNoObj;
  if (!e.count_game && oid != e.count_oid) e.count_used = 0;
  e.count_oid = oid;
  ++e.count_used;
}

uint32_t Duel::location_of(CardIdx c) const {
  const Card& card = state.cards.get(c);
  if (card.host != kNoCard) return card.acce ? static_cast<uint32_t>(LOCATION_ACCE) : 0;
  if (card.zone == kNoZone || state.is_leftover(c)) return 0;
  if (state.is_set(c)) return static_cast<uint32_t>(state.is_seed(c) ? LOCATION_SEED : LOCATION_TRAP);
  return loc_bit(state.zones.get(card.zone).kind);
}

// ── 등록 ──

void Duel::register_effect(EffectId id, CardIdx handler) {
  Effect& e = *effects.get(id);
  Card& card = state.cards.get(handler);
  e.handler = handler;
  e.registered = true;
  effects.mark(e.code);
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
  effects.mark(e.code);
  e.granted = true;
  e.bind_oid = card.oid;
  e.timestamp = state.cards.tick();
  if (e.owner_player == kNoPlayer) e.owner_player = card.controller;
}

void Duel::register_player_effect(EffectId id, PlayerId p) {
  Effect& e = *effects.get(id);
  e.handler = kNoCard;
  e.registered = true;
  effects.mark(e.code);
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

// 「…の【常】【自】【起】能力を得る」(PR-K065B): cid의 스크립트를 이 카드에서 돌려 얻은 능력으로 바꾼다(라이프 버스트는 뺀다)
void Duel::gain_abilities(CardIdx c, Cid cid) {
  EffectId mark = effects.create();
  Effect& m = *effects.get(mark);
  m.type = EFFECT_TYPE_SINGLE;
  m.code = EFFECT_SUPPRESS + 1;  // 표식(어떤 효과도 아니다)
  run_initial_effect(c, cid, mark);
  const ObjId oid = state.cards.get(c).oid;
  effects.for_each([&](Effect& x) {
    if (x.copy_of != mark || x.handler != c) return;
    if (x.type & EFFECT_TYPE_LIFEBURST) {
      delete_effect(x.id);
      return;
    }
    x.printed = false;
    x.granted = true;
    x.copy_of = kNoEffect;
    x.text_cid = 0;
    x.bind_oid = oid;
    x.timestamp = state.cards.tick();
  });
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
  if (phase_bit == PHASE_END) players[0].rides.clear(), players[1].rides.clear();  // 「ターン終了時まで…乗る」
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
