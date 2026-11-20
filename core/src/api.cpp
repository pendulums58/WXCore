// 공개 C API. 콜백·handle 변환만 하고 나머지는 Duel에 넘긴다.
#include <cstdio>
#include <cstring>
#include <memory>
#include <string>

#include "session.h"
#include "wx_api.h"

using namespace wx;

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
      d.power = c.power;
      d.classes = split_lines(c.classes);
      d.limit_cond = split_lines(c.limit_cond);
      d.cost_ena = c.cost_ena ? c.cost_ena : "";
      d.grow_ena = c.grow_ena ? c.grow_ena : "";
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
                     host = u32(), face = u8();
      static const char* kinds[] = {"move", "under", "attach", "facedown"};
      add("MOVE #%u->#%u cid=%u zone %u->%u %s%s host=#%u %s", o, nw, cid, from == 0xFFFF ? 9999 : from, to,
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
      add("REVEAL #%u cid=%u", h, u32());
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
      const uint32_t p = u8();
      add("TRIGGER p%u #%u", p, u32());
      break;
    }
    case WX_MSG_REQUEST: {
      const uint32_t t = u8(), p = u8(), hint = u32(), mn = u32(), mx = u32(), n = u16();
      static const char* types[] = {"yesno", "cards", "option", "action"};
      add("REQUEST p%u %s hint=%u %u..%u [", p, types[t & 3], hint, mn, mx);
      for (uint32_t i = 0; i < n; ++i) {
        if (t == WX_REQ_SELECT_ACTION) {
          const uint32_t k = u8(), h = u32(), z = u16(), e = u32();
          add("%s(k%u #%u z%u e%u)", i ? " " : "", k, h, z, e);
        } else {
          add(t == WX_REQ_SELECT_CARDS ? "%s#%u" : "%s%u", i ? " " : "", u32());
        }
      }
      s += "]";
      if (u8()) s += " cancelable";
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
