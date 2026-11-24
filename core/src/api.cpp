// 공개 C API. 콜백·handle 변환만 하고 나머지는 Duel에 넘긴다.
#include <cstdio>
#include <cstring>
#include <memory>
#include <string>

#include "session.h"
#include "wx_api.h"

using namespace wx;

// 공개 헤더의 번호가 내부 enum과 같아야 한다
static_assert(WX_HINT_NONE == HINT_NONE);
static_assert(WX_HINT_MULLIGAN == HINT_MULLIGAN);
static_assert(WX_HINT_START_LRIG == HINT_START_LRIG);
static_assert(WX_HINT_CENTER_LRIG == HINT_CENTER_LRIG);
static_assert(WX_HINT_ENA_CHARGE == HINT_ENA_CHARGE);
static_assert(WX_HINT_GROW == HINT_GROW);
static_assert(WX_HINT_PAY_ENA == HINT_PAY_ENA);
static_assert(WX_HINT_MAIN == HINT_MAIN);
static_assert(WX_HINT_REMOVE == HINT_REMOVE);
static_assert(WX_HINT_ATTACK_SIGNI == HINT_ATTACK_SIGNI);
static_assert(WX_HINT_ATTACK_LRIG == HINT_ATTACK_LRIG);
static_assert(WX_HINT_GUARD == HINT_GUARD);
static_assert(WX_HINT_DISCARD == HINT_DISCARD);
static_assert(WX_HINT_TRIGGER_ORDER == HINT_TRIGGER_ORDER);
static_assert(WX_HINT_USE_TRIGGER == HINT_USE_TRIGGER);
static_assert(WX_HINT_LIFEBURST == HINT_LIFEBURST);
static_assert(WX_HINT_RULE_TRASH == HINT_RULE_TRASH);
static_assert(WX_HINT_SCRIPT == HINT_SCRIPT);
static_assert(WX_HINT_PRE_ATTACK == HINT_PRE_ATTACK);
static_assert(WX_HINT_DEFENSE == HINT_DEFENSE);
static_assert(WX_HINT_CUTIN == HINT_CUTIN);
static_assert(WX_HINT_TARGET == HINT_TARGET);
static_assert(WX_HINT_MODE == HINT_MODE);
static_assert(WX_HINT_SELECT == HINT_SELECT);
static_assert(WX_HINT_ZONE == HINT_ZONE);
static_assert(WX_HINT_EXCEED == HINT_EXCEED);
static_assert(WX_HINT_ENCORE == HINT_ENCORE);
static_assert(WX_HINT_DECLARE == HINT_DECLARE);
static_assert(WX_HINT_ORDER == HINT_ORDER);
static_assert(WX_HINT_BET == HINT_BET && WX_HINT_RESONA == HINT_RESONA);
static_assert(WX_ACT_RESONA == static_cast<int>(ActionKind::PlayResona));
static_assert(WX_PHASE_MAIN == PHASE_MAIN && WX_PHASE_END == PHASE_END && WX_PHASE_ATTACK == PHASE_ATTACK);
static_assert(WX_ACT_KEY == static_cast<int>(ActionKind::PlayKey) && WX_ACT_GROW == static_cast<int>(ActionKind::Grow));

struct wx_duel {
  wx_duel_options opt{};
  std::unique_ptr<Session> s;
  Duel& d() { return s->duel(); }
  bool test_mode() const { return (opt.flags & WX_FLAG_TEST_MODE) != 0; }
};

namespace {
std::vector<std::string> split_lines(const char* s) {
  std::vector<std::string> out;
  if (!s) return out;
  std::string cur;
  for (const char* p = s; *p; ++p) {
    if (*p == '\n') {
      if (!cur.empty()) out.push_back(cur);
      cur.clear();
    } else {
      cur += *p;
    }
  }
  if (!cur.empty()) out.push_back(cur);
  return out;
}
}  // namespace

extern "C" {

uint32_t wx_api_version(void) { return (WX_API_VERSION_MAJOR << 16) | WX_API_VERSION_MINOR; }
uint32_t wx_schema_version(void) { return WX_SCHEMA_VERSION; }

int wx_create_duel(const wx_duel_options* opt, wx_duel** out) {
  if (!opt || !out) return WX_ERR_ARGS;
  if (opt->schema_version != WX_SCHEMA_VERSION) return WX_ERR_VERSION;
  auto* duel = new wx_duel;
  duel->opt = *opt;
  DuelConfig cfg;
  cfg.seed = opt->seed;
  cfg.test_mode = (opt->flags & WX_FLAG_TEST_MODE) != 0;
  cfg.always_ask = (opt->flags & WX_FLAG_ALWAYS_ASK) != 0;
  cfg.first_player = opt->first_player <= 1 ? opt->first_player : kNoPlayer;
  const wx_duel_options o = *opt;
  if (o.card_reader)
    cfg.card_data = [o](Cid cid, CardData& d) {
      wx_card_data c{};
      if (!o.card_reader(o.user, cid, &c)) return false;
      d.alias = c.alias;
      d.type = c.type;
      d.color = c.color;
      d.level = c.level;
      d.limit = c.limit;
      d.limit_cost = c.limit_cost;
      d.power = c.power;
      auto ids = [](const uint32_t* p, size_t n) { return p ? std::vector<uint32_t>(p, p + n) : std::vector<uint32_t>{}; };
      d.classes = ids(c.classes, c.n_classes);
      d.lrig_types = ids(c.lrig_types, c.n_lrig_types);
      d.limit_cond = ids(c.limit_cond, c.n_limit_cond);
      d.teams = split_lines(c.teams);
      d.coin = c.coin;
      d.cost_coin = c.cost_coin;
      d.cost_ena = c.cost_ena ? c.cost_ena : "";
      d.guard = c.guard != 0;
      d.life_burst = c.life_burst != 0;
      d.timing = c.timing;
      return true;
    };
  if (o.script_reader)
    cfg.script = [o](const std::string& name, std::string& code) {
      size_t len = 0;
      const char* buf = o.script_reader(o.user, name.c_str(), &len);
      if (!buf) return false;
      code.assign(buf, len);
      return true;
    };
  if (o.log_handler) cfg.log = [o](const std::string& m) { o.log_handler(o.user, m.c_str()); };
  duel->s = std::make_unique<Session>(std::move(cfg));
  *out = duel;
  return WX_OK;
}

void wx_destroy_duel(wx_duel* duel) { delete duel; }

int wx_add_deck(wx_duel* duel, uint8_t player, const uint32_t* main, size_t n_main, const uint32_t* lrig,
                size_t n_lrig) {
  if (!duel || player > 1) return WX_ERR_ARGS;
  duel->s->command([player, m = std::vector<Cid>(main, main + n_main), l = std::vector<Cid>(lrig, lrig + n_lrig)](
                       Duel& d) { d.set_deck(player, m, l); });
  return WX_OK;
}

int wx_add_deck_prints(wx_duel* duel, uint8_t player, const uint32_t* main, const uint16_t* main_prints, size_t n_main,
                       const uint32_t* lrig, const uint16_t* lrig_prints, size_t n_lrig) {
  if (!duel || player > 1) return WX_ERR_ARGS;
  auto prints = [](const uint16_t* p, size_t n) { return p ? std::vector<uint16_t>(p, p + n) : std::vector<uint16_t>{}; };
  duel->s->command([player, m = std::vector<Cid>(main, main + n_main), l = std::vector<Cid>(lrig, lrig + n_lrig),
                    mp = prints(main_prints, n_main), lp = prints(lrig_prints, n_lrig)](Duel& d) {
    d.set_deck(player, m, l, mp, lp);
  });
  return WX_OK;
}

int wx_start(wx_duel* duel) {
  if (!duel) return WX_ERR_ARGS;
  duel->s->command([](Duel& d) { d.start(); });
  return WX_OK;
}

int wx_process(wx_duel* duel) {
  switch (duel->d().process()) {
    case Duel::Result::Continue: return WX_CONTINUE;
    case Duel::Result::NeedResponse: return WX_NEED_RESPONSE;
    case Duel::Result::End: return WX_END;
  }
  return WX_END;
}

size_t wx_get_messages(wx_duel* duel, uint8_t view, uint8_t* buf, size_t cap) {
  if (!duel || view > WX_VIEW_ALL) return 0;
  const size_t n = duel->d().message_size(view);  // 크기만 물으면 꺼내지 않는다
  if (buf && cap >= n) {
    const auto bytes = duel->d().take_messages(view);
    std::memcpy(buf, bytes.data(), n);
  }
  return n;
}

int wx_set_response(wx_duel* duel, const uint32_t* picks, size_t n) {
  if (!duel) return WX_ERR_ARGS;
  Duel& d = duel->d();
  const Request* req = d.request();
  if (!req) return WX_ERR_STATE;
  Response r;
  for (size_t i = 0; i < n; ++i) {
    uint32_t v = picks[i];
    if (req->type == ReqType::SelectCards) {
      Card* c = d.state.cards.by_oid(v);  // handle → 카드
      if (!c) {
        d.msg_retry(req->player, "모르는 카드 handle");
        return WX_ERR_INVALID;
      }
      v = c->idx;
    }
    r.picks.push_back(v);
  }
  return duel->s->respond(std::move(r)) ? WX_OK : WX_ERR_INVALID;
}

int wx_cancel(wx_duel* duel) {
  if (!duel || !duel->d().request()) return WX_ERR_STATE;
  Response r;
  r.cancel = true;
  return duel->s->respond(std::move(r)) ? WX_OK : WX_ERR_INVALID;
}

int wx_test_add_card(wx_duel* duel, uint32_t cid, uint8_t owner, uint16_t zone, uint32_t* handle) {
  if (!duel || owner > 1) return WX_ERR_ARGS;
  if (!duel->test_mode()) return WX_ERR_TEST_MODE;
  if (zone >= duel->d().state.zones.size()) return WX_ERR_ARGS;
  const CardIdx c = duel->s->command([=](Duel& d) { return d.new_card(cid, owner, zone); });
  if (handle) *handle = duel->d().handle(c);
  return WX_OK;
}

int wx_test_begin(wx_duel* duel, uint8_t turn_player, uint32_t phase, int first_turn) {
  if (!duel || turn_player > 1) return WX_ERR_ARGS;
  if (!duel->test_mode()) return WX_ERR_TEST_MODE;
  const bool first = first_turn != 0;
  return duel->s->command([=](Duel& d) { return d.test_begin(turn_player, phase, first); }) ? WX_OK : WX_ERR_STATE;
}

int wx_test_move_card(wx_duel* duel, uint32_t handle, uint16_t zone, int bottom, uint32_t* new_handle) {
  if (!duel) return WX_ERR_ARGS;
  if (!duel->test_mode()) return WX_ERR_TEST_MODE;
  Card* card = duel->d().state.cards.by_oid(handle);
  if (!card || zone >= duel->d().state.zones.size()) return WX_ERR_ARGS;
  const CardIdx c = card->idx;
  const Pos pos = bottom ? Pos::Bottom : Pos::Top;
  duel->s->command([=](Duel& d) { d.state.move(c, zone, pos); });
  if (new_handle) *new_handle = duel->d().handle(c);
  return WX_OK;
}

int wx_test_set_power(wx_duel* duel, uint32_t handle, int32_t power) {
  if (!duel) return WX_ERR_ARGS;
  if (!duel->test_mode()) return WX_ERR_TEST_MODE;
  Card* card = duel->d().state.cards.by_oid(handle);
  if (!card) return WX_ERR_ARGS;
  const CardIdx c = card->idx;
  // [まで] 그 객체에 고정. 해제 없음
  duel->s->command([=](Duel& d) {
    const EffectId id = d.effects.create();
    Effect& e = *d.effects.get(id);
    e.type = EFFECT_TYPE_SINGLE;
    e.code = EFFECT_SET_POWER;
    e.value = power;
    d.register_effect(id, c);
  });
  return WX_OK;
}

int wx_test_undo(wx_duel* duel) {
  if (!duel) return WX_ERR_ARGS;
  if (!duel->test_mode()) return WX_ERR_TEST_MODE;
  return duel->s->undo() ? WX_OK : WX_ERR_STATE;
}

// ── 상태 조회 ──

namespace {
bool view_sees(Duel& d, uint8_t view, CardIdx c) {
  if (view == WX_VIEW_ALL) return true;
  const Card& card = d.state.cards.get(c);
  // 아래 카드·붙은 카드는 호스트와 같은 영역(루리그 아래는 공개)
  const CardIdx owner_card = card.host != kNoCard ? card.host : c;
  if (card.host != kNoCard && d.state.zones.get(d.state.cards.get(owner_card).zone).vis == ZoneVis::Public)
    return view == WX_VIEW_SPECTATOR ? card.face_up : true;
  if (view == WX_VIEW_SPECTATOR) return d.state.viewers(c) == 0b11;
  return d.state.can_see(static_cast<PlayerId>(view), c);
}
}  // namespace

int wx_query_card(wx_duel* duel, uint8_t view, uint32_t handle, wx_card_info* out) {
  if (!duel || !out || view > WX_VIEW_ALL) return WX_ERR_ARGS;
  Duel& d = duel->d();
  Card* card = d.state.cards.by_oid(handle);
  if (!card) return WX_ERR_ARGS;
  const CardIdx c = card->idx;
  *out = wx_card_info{};
  out->handle = handle;
  out->owner = card->owner;
  out->controller = card->controller;
  out->face_up = card->face_up;
  out->host = card->host != kNoCard ? d.handle(card->host) : 0;
  const CardIdx place = card->host != kNoCard ? card->host : c;
  out->zone = static_cast<uint16_t>(d.state.cards.get(place).zone == kNoZone ? 0xFFFF : d.state.cards.get(place).zone);
  out->flags = card->flags | (d.is_cross(c) ? CF_CROSS : 0);
  out->n_under = static_cast<uint16_t>(card->under.size());
  out->n_attached = static_cast<uint16_t>(card->attached.size());
  if (!view_sees(d, view, c)) return WX_OK;
  out->known = 1;
  out->cid = d.text_of(c);
  out->print = d.state.cards.get(c).print;
  out->type = d.type_of(c);
  out->color = d.color_of(c);
  out->level = d.level_of(c);
  out->limit = d.limit_of(c);
  out->power = d.power_of(c);
  if (d.has_keyword(c, EFFECT_LANCER)) out->keywords |= WX_KW_LANCER;
  if (d.has_keyword(c, EFFECT_S_LANCER)) out->keywords |= WX_KW_S_LANCER;
  if (d.has_keyword(c, EFFECT_DOUBLE_CRUSH)) out->keywords |= WX_KW_DOUBLE_CRUSH;
  if (d.has_keyword(c, EFFECT_ASSASSIN)) out->keywords |= WX_KW_ASSASSIN;
  if (!d.can_attack(c)) out->keywords |= WX_KW_CANNOT_ATTACK;
  const CardData& data = d.data(out->cid);
  if (data.guard) out->keywords |= WX_KW_GUARD;
  if (data.life_burst) out->keywords |= WX_KW_LIFE_BURST;
  return WX_OK;
}

size_t wx_query_zone(wx_duel* duel, uint8_t view, uint16_t zone, uint32_t* buf, size_t cap) {
  if (!duel || view > WX_VIEW_ALL) return 0;
  Duel& d = duel->d();
  if (zone >= d.state.zones.size()) return 0;
  const auto& cards = d.state.zones.get(zone).cards;
  for (size_t i = 0; buf && i < cards.size() && i < cap; ++i) buf[i] = d.handle(cards[i]);
  return cards.size();
}

size_t wx_query_granted(wx_duel* duel, uint8_t view, uint32_t handle, wx_granted_info* buf, size_t cap) {
  if (!duel || view > WX_VIEW_ALL) return 0;
  Duel& d = duel->d();
  Card* card = d.state.cards.by_oid(handle);
  if (!card || !view_sees(d, view, card->idx)) return 0;
  size_t n = 0;
  for (EffectId id : d.abilities_of(card->idx)) {
    const Effect* e = d.effects.get(id);
    if (!e || !e->granted) continue;
    if (buf && n < cap) {
      wx_granted_info& g = buf[n];
      g.desc = e->desc;
      g.keyword = e->code == EFFECT_LANCER        ? WX_KW_LANCER
                  : e->code == EFFECT_S_LANCER    ? WX_KW_S_LANCER
                  : e->code == EFFECT_DOUBLE_CRUSH ? WX_KW_DOUBLE_CRUSH
                  : e->code == EFFECT_ASSASSIN    ? WX_KW_ASSASSIN
                                                  : 0;
      g.source_cid = e->owner_card != kNoCard ? d.state.cards.get(e->owner_card).cid : 0;
    }
    ++n;
  }
  return n;
}

size_t wx_query_under(wx_duel* duel, uint8_t view, uint32_t handle, uint32_t* buf, size_t cap) {
  if (!duel || view > WX_VIEW_ALL) return 0;
  Duel& d = duel->d();
  Card* card = d.state.cards.by_oid(handle);
  if (!card) return 0;
  for (size_t i = 0; buf && i < card->under.size() && i < cap; ++i) buf[i] = d.handle(card->under[i]);
  return card->under.size();
}

int wx_query_player(wx_duel* duel, uint8_t player, wx_player_info* out) {
  if (!duel || !out || player > 1) return WX_ERR_ARGS;
  Duel& d = duel->d();
  out->coins = d.players[player].coins;
  out->hand_limit = d.hand_limit(player);
  out->refreshes_this_turn = d.players[player].refreshes_this_turn;
  return WX_OK;
}

int wx_query_game(wx_duel* duel, wx_game_info* out) {
  if (!duel || !out) return WX_ERR_ARGS;
  Duel& d = duel->d();
  out->turn_player = d.turn_player;
  out->turn_count = d.turn_count;
  out->phase = d.phase;
  out->ended = d.ended() ? 1 : 0;
  out->winner = d.winner() <= 1 ? d.winner() : 0xFF;
  return WX_OK;
}

size_t wx_zone_count(wx_duel* duel) { return duel ? duel->d().state.zones.size() : 0; }

int wx_query_zone_info(wx_duel* duel, uint16_t zone, char* name, size_t cap, uint8_t* owner, uint8_t* markers) {
  if (!duel) return WX_ERR_ARGS;
  Duel& d = duel->d();
  if (zone >= d.state.zones.size()) return WX_ERR_ARGS;
  const Zone& z = d.state.zones.get(zone);
  if (name && cap) {
    const size_t n = std::min(z.name.size(), cap - 1);
    std::memcpy(name, z.name.data(), n);
    name[n] = 0;
  }
  if (owner) *owner = z.owner;
  if (markers) *markers = static_cast<uint8_t>((z.gate ? 1 : 0) | (z.virus ? 2 : 0));
  return WX_OK;
}

// ── 덤프 ──

size_t wx_dump_message(const uint8_t* msg, size_t len, char* out, size_t cap) {
  size_t pos = 0;
  auto need = [&](size_t n) { return pos + n <= len; };
  auto u8 = [&]() -> uint32_t { return need(1) ? msg[pos++] : 0; };
  auto u16 = [&]() -> uint32_t {
    uint32_t v = 0;
    for (int i = 0; i < 2 && need(1); ++i) v |= static_cast<uint32_t>(msg[pos++]) << (8 * i);
    return v;
  };
  auto u32 = [&]() -> uint32_t {
    uint32_t v = 0;
    for (int i = 0; i < 4 && need(1); ++i) v |= static_cast<uint32_t>(msg[pos++]) << (8 * i);
    return v;
  };
  std::string s;
  auto add = [&](const char* fmt, auto... args) {
    char tmp[256];
    std::snprintf(tmp, sizeof tmp, fmt, args...);
    s += tmp;
  };
  u32();  // size
  const uint32_t type = u16();
  switch (type) {
    case WX_MSG_START: add("START first=p%u", u8()); break;
    case WX_MSG_ZONES: add("ZONES n=%u", u16()); break;
    case WX_MSG_NEW_TURN: {
      const uint32_t p = u8();
      add("TURN %u p%u", u32(), p);
      break;
    }
    case WX_MSG_NEW_PHASE: add("PHASE 0x%02x", u32()); break;
    case WX_MSG_MOVE: {
      const uint32_t o = u32(), nw = u32(), cid = u32(), from = u16(), to = u16(), bottom = u8(), kind = u8(),
                     host = u32(), face = u8(), print = u16();
      static const char* kinds[] = {"move", "under", "attach", "facedown"};
      add("MOVE #%u->#%u cid=%u print=%u zone %u->%u %s%s host=#%u %s", o, nw, cid, print, from == 0xFFFF ? 9999 : from, to,
          kinds[kind & 3], bottom ? " bottom" : "", host, face ? "up" : "down");
      break;
    }
    case WX_MSG_SHUFFLE: {
      const uint32_t z = u16();
      add("SHUFFLE zone %u n=%u", z, u16());
      break;
    }
    case WX_MSG_FLAGS: {
      const uint32_t h = u32();
      add("FLAGS #%u 0x%x", h, u32());
      break;
    }
    case WX_MSG_REVEAL: {
      const uint32_t h = u32();
      const uint32_t cid = u32();
      add("REVEAL #%u cid=%u print=%u", h, cid, u16());
      break;
    }
    case WX_MSG_ATTACK: add("ATTACK #%u", u32()); break;
    case WX_MSG_BATTLE: {
      const uint32_t a = u32(), b = u32();
      const int32_t ap = static_cast<int32_t>(u32()), bp = static_cast<int32_t>(u32());
      add("BATTLE #%u(%d) vs #%u(%d)", a, ap, b, bp);
      break;
    }
    case WX_MSG_DAMAGE: add("DAMAGE p%u", u8()); break;
    case WX_MSG_REFRESH: add("REFRESH p%u", u8()); break;
    case WX_MSG_TRIGGER: {
      const uint32_t p = u8(), h = u32(), desc = u32();
      add("TRIGGER p%u #%u", p, h);
      if (desc) add(" d%u", desc);
      break;
    }
    case WX_MSG_REQUEST: {
      const uint32_t t = u8(), p = u8(), hint = u32(), mn = u32(), mx = u32(), n = u16();
      static const char* types[] = {"yesno", "cards", "option", "action"};
      add("REQUEST p%u %s hint=%u %u..%u [", p, types[t & 3], hint, mn, mx);
      for (uint32_t i = 0; i < n; ++i) {
        if (t == WX_REQ_SELECT_ACTION) {
          const uint32_t k = u8(), h = u32(), z = u16(), e = u32();
          u32();
          add("%s(k%u #%u z%u e%u)", i ? " " : "", k, h, z, e);
        } else if (t == WX_REQ_SELECT_CARDS) {
          add("%s#%u", i ? " " : "", u32());
        } else {
          const uint32_t val = u32(), h = u32();
          u32();
          if (h) add("%s%u(#%u)", i ? " " : "", val, h);
          else add("%s%u", i ? " " : "", val);
        }
      }
      s += "]";
      if (u8()) s += " cancelable";
      if (const uint32_t src = u32()) add(" from #%u", src);
      u32();
      break;
    }
    case WX_MSG_WAITING: add("WAITING p%u", u8()); break;
    case WX_MSG_RETRY: {
      const uint32_t p = u8(), n = u16();
      std::string why;
      for (uint32_t i = 0; i < n && need(1); ++i) why += static_cast<char>(msg[pos++]);
      add("RETRY p%u ", p);
      s += why;
      break;
    }
    case WX_MSG_WIN: add("WIN p%u", u8()); break;
    case WX_MSG_RESET: s += "RESET"; break;
    case WX_MSG_COIN: {
      const uint32_t pl = u8();
      add("COIN p%u %u", pl, u8());
      break;
    }
    case WX_MSG_MARKER: {
      const uint32_t z = u16(), k = u8();
      add("MARKER zone %u kind %u n=%u", z, k, u8());
      break;
    }
    default: add("UNKNOWN %u", type);
  }
  if (out && cap) {
    const size_t n = std::min(s.size(), cap - 1);
    std::memcpy(out, s.data(), n);
    out[n] = 0;
  }
  return s.size();
}

}  // extern "C"
