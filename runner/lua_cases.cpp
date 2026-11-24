// Lua 케이스 러너. runner/cases/*.lua를 읽어 case(name, ref, fn)로 등록된 케이스를 돌린다.
// 케이스 함수는 t(테스트 픽스처)를 받는다. 러너는 코어와 별개의 Lua 상태를 쓴다.
#include "lua_cases.h"

#include <lauxlib.h>
#include <lua.h>
#include <lualib.h>

#include <algorithm>
#include <cstdio>
#include <cstring>
#include <filesystem>
#include <fstream>
#include <sstream>

#include "fixture.h"
#include "wx_api.h"

using namespace wx;
using wxtest::Fixture;

namespace {

struct CaseState {
  Fixture f;
  std::vector<std::string> failures;
  bool allow_logs = false;
};

constexpr const char* kMeta = "WxTest";

CaseState& T(lua_State* L) { return **static_cast<CaseState**>(luaL_checkudata(L, 1, kMeta)); }
Duel& D(lua_State* L) {
  CaseState& t = T(L);
  if (!t.f.session) luaL_error(L, "t:start()를 먼저 불러야 함");
  return t.f.d();
}
CardIdx card_arg(lua_State* L, int i) { return static_cast<CardIdx>(luaL_checkinteger(L, i)); }
PlayerId player_arg(lua_State* L, int i) { return static_cast<PlayerId>(luaL_checkinteger(L, i)); }
uint32_t u32_arg(lua_State* L, int i, uint32_t def = 0) {
  return static_cast<uint32_t>(luaL_optinteger(L, i, static_cast<lua_Integer>(def)));
}

std::vector<std::string> string_list(lua_State* L, int idx, const char* field) {
  std::vector<std::string> out;
  lua_getfield(L, idx, field);
  if (lua_istable(L, -1)) {
    for (lua_Integer i = 1; lua_rawgeti(L, -1, i) == LUA_TSTRING; ++i) {
      out.emplace_back(lua_tostring(L, -1));
      lua_pop(L, 1);
    }
    lua_pop(L, 1);
  }
  lua_pop(L, 1);
  return out;
}

lua_Integer int_field(lua_State* L, int idx, const char* field, lua_Integer def) {
  lua_getfield(L, idx, field);
  const lua_Integer v = lua_isnil(L, -1) ? def : lua_tointeger(L, -1);
  lua_pop(L, 1);
  return v;
}

// true/false 또는 0/1
bool bool_field(lua_State* L, int idx, const char* field, bool def) {
  lua_getfield(L, idx, field);
  bool v = def;
  if (lua_isboolean(L, -1)) v = lua_toboolean(L, -1);
  else if (lua_isinteger(L, -1)) v = lua_tointeger(L, -1) != 0;
  lua_pop(L, 1);
  return v;
}

std::string str_field(lua_State* L, int idx, const char* field) {
  lua_getfield(L, idx, field);
  std::string v = lua_isstring(L, -1) ? lua_tostring(L, -1) : "";
  lua_pop(L, 1);
  return v;
}

// ── 카드 데이터·스크립트 ──

// 클래스 이름(「精械：迷宮」·「精元」) 목록 → 코드. 이름은 wixoss.db의 classes 표로 바꾼다. 모르는 이름은 케이스 오류
std::vector<uint32_t> class_list(lua_State* L, int idx, const char* field) {
  std::vector<uint32_t> out;
  for (const auto& s : string_list(L, idx, field)) {
    uint32_t code = 0;
    if (!Fixture::db().parse_class(s, code)) luaL_error(L, "모르는 클래스: %s", s.c_str());
    out.push_back(code);
  }
  return out;
}

// 루리그 타입 이름(「タマ」) 목록 → ID
std::vector<uint32_t> lrig_type_list(lua_State* L, int idx, const char* field) {
  std::vector<uint32_t> out;
  for (const auto& s : string_list(L, idx, field)) {
    const uint32_t id = Fixture::db().class_id(wxtest::CardDb::kClassLrig, s);
    if (!id) luaL_error(L, "모르는 루리그 타입: %s", s.c_str());
    out.push_back(id);
  }
  return out;
}

// t:card{cid=, type=, color=, level=, limit=, power=, classes={"精械：迷宮"}, lrig_types={"タマ"}, limit_cond={"タマ"},
//        cost=, grow=, guard=, burst=, timing=}
int t_card(lua_State* L) {
  luaL_checktype(L, 2, LUA_TTABLE);
  CardData d;
  d.cid = static_cast<Cid>(int_field(L, 2, "cid", 0));
  d.type = static_cast<uint32_t>(int_field(L, 2, "type", TYPE_SIGNI));
  d.color = static_cast<uint8_t>(int_field(L, 2, "color", COLOR_WHITE));
  d.level = static_cast<int32_t>(int_field(L, 2, "level", 0));
  d.limit = static_cast<int32_t>(int_field(L, 2, "limit", 0));
  d.limit_cost = static_cast<int32_t>(int_field(L, 2, "limit_cost", 0));
  d.power = static_cast<int32_t>(int_field(L, 2, "power", 0));
  d.classes = class_list(L, 2, "classes");
  d.lrig_types = lrig_type_list(L, 2, "lrig_types");
  d.limit_cond = lrig_type_list(L, 2, "limit_cond");
  d.teams = string_list(L, 2, "teams");
  d.coin = static_cast<int32_t>(int_field(L, 2, "coin", 0));
  d.cost_coin = static_cast<uint32_t>(int_field(L, 2, "cost_coin", 0));
  d.cost_ena = str_field(L, 2, "cost");
  if (const std::string grow = str_field(L, 2, "grow"); !grow.empty()) d.cost_ena = grow;  // 루리그는 그로우 코스트
  d.guard = int_field(L, 2, "guard", 0) != 0;
  d.life_burst = int_field(L, 2, "burst", 0) != 0;
  d.timing = static_cast<uint32_t>(int_field(L, 2, "timing", 0));
  T(L).f.cards[d.cid] = d;
  return 0;
}

// t:signi(cid, power, color, level)
int t_signi(lua_State* L) {
  T(L).f.signi(static_cast<Cid>(luaL_checkinteger(L, 2)), static_cast<int32_t>(luaL_checkinteger(L, 3)),
               static_cast<uint8_t>(luaL_optinteger(L, 4, COLOR_WHITE)), static_cast<int32_t>(luaL_optinteger(L, 5, 1)));
  return 0;
}

// t:lrig(cid, level, limit, {types}, color)
int t_lrig(lua_State* L) {
  CaseState& t = T(L);
  const Cid cid = static_cast<Cid>(luaL_checkinteger(L, 2));
  t.f.lrig(cid, static_cast<uint8_t>(luaL_optinteger(L, 6, COLOR_WHITE)), static_cast<int32_t>(luaL_optinteger(L, 3, 3)),
           static_cast<int32_t>(luaL_optinteger(L, 4, 6)));
  if (lua_istable(L, 5)) {
    lua_newtable(L);
    lua_pushvalue(L, 5);
    lua_setfield(L, -2, "types");
    t.f.cards[cid].lrig_types = lrig_type_list(L, lua_gettop(L), "types");
    lua_pop(L, 1);
  }
  return 0;
}

int t_script(lua_State* L) {
  T(L).f.script(static_cast<Cid>(luaL_checkinteger(L, 2)), luaL_checkstring(L, 3));
  return 0;
}

// ── 대전 ──

// t:start{seed=, always_ask=, test_mode=, first=, db=}
int t_start(lua_State* L) {
  CaseState& t = T(L);
  uint64_t seed = 1;
  if (lua_istable(L, 2)) {
    seed = static_cast<uint64_t>(int_field(L, 2, "seed", 1));
    t.f.use_db = bool_field(L, 2, "db", false);
    if (t.f.use_db && !Fixture::db().is_open())
      luaL_error(L, "카드 DB를 못 열었음(python tools/build_db.py 먼저): %s", Fixture::db().error().c_str());
    t.f.always_ask = bool_field(L, 2, "always_ask", true);
    t.f.test_mode = bool_field(L, 2, "test_mode", true);
    t.f.first = static_cast<PlayerId>(int_field(L, 2, "first", kNoPlayer));
  }
  t.f.logs.clear();
  t.f.seen.clear();
  t.f.start(seed);
  return 0;
}

int t_put(lua_State* L) {
  D(L);
  lua_pushinteger(L, T(L).f.put(static_cast<Cid>(luaL_checkinteger(L, 2)), player_arg(L, 3), luaL_checkstring(L, 4)));
  return 1;
}

int t_fill(lua_State* L) {
  D(L);
  T(L).f.fill(static_cast<Cid>(luaL_checkinteger(L, 2)), player_arg(L, 3), luaL_checkstring(L, 4),
              static_cast<int>(luaL_checkinteger(L, 5)));
  return 0;
}

int t_deck(lua_State* L) {
  D(L);
  const PlayerId p = player_arg(L, 2);
  auto list = [&](int idx) {
    std::vector<Cid> out;
    if (lua_istable(L, idx))
      for (lua_Integer i = 1; lua_rawgeti(L, idx, i) == LUA_TNUMBER; ++i) {
        out.push_back(static_cast<Cid>(lua_tointeger(L, -1)));
        lua_pop(L, 1);
      }
    lua_pop(L, 1);
    return out;
  };
  const auto main = list(3);
  const auto lrig = list(4);
  T(L).f.session->command([=](Duel& d) { d.set_deck(p, main, lrig); });
  return 0;
}

// t:no(card_no) → cid(없으면 nil). DB 필요
int t_no(lua_State* L) {
  const Cid c = wxtest::card_no_cid(luaL_checkstring(L, 2));
  if (c)
    lua_pushinteger(L, c);
  else
    lua_pushnil(L);
  return 1;
}

// t:deck_file(p, name) — decks/<name>.json을 그 플레이어 덱으로. → 성공, 덱 정보 표 또는 오류
int t_deck_file(lua_State* L) {
  D(L);
  const PlayerId p = player_arg(L, 2);
  const std::string path = wxtest::data_dir() + "/decks/" + luaL_checkstring(L, 3) + ".json";
  wxtest::DeckFile deck;
  std::string error;
  if (!wxtest::load_deck(path, Fixture::db(), deck, error)) {
    lua_pushboolean(L, false);
    lua_pushstring(L, error.c_str());
    return 2;
  }
  T(L).f.session->command([=](Duel& d) { d.set_deck(p, deck.main, deck.lrig); });
  lua_pushboolean(L, true);
  lua_newtable(L);
  lua_pushstring(L, deck.format.c_str());
  lua_setfield(L, -2, "format");
  lua_pushinteger(L, static_cast<lua_Integer>(deck.main.size()));
  lua_setfield(L, -2, "main");
  lua_pushinteger(L, static_cast<lua_Integer>(deck.lrig.size()));
  lua_setfield(L, -2, "lrig");
  lua_pushinteger(L, deck.start_center);
  lua_setfield(L, -2, "center");
  return 2;
}

int t_begin(lua_State* L) {
  D(L);
  const PlayerId p = player_arg(L, 2);
  const uint32_t phase = u32_arg(L, 3);
  const bool first = lua_toboolean(L, 4);
  lua_pushboolean(L, T(L).f.session->command([=](Duel& d) { return d.test_begin(p, phase, first); }));
  return 1;
}

int t_start_game(lua_State* L) {
  D(L);
  T(L).f.session->command([](Duel& d) { d.start(); });
  return 0;
}

int t_wait(lua_State* L) {
  D(L);
  lua_pushboolean(L, T(L).f.until(u32_arg(L, 2)));
  return 1;
}

// t:answer(a, b, ...) 또는 t:answer({a, b})
int t_answer(lua_State* L) {
  D(L);
  std::vector<uint32_t> picks;
  if (lua_istable(L, 2)) {
    for (lua_Integer i = 1; lua_rawgeti(L, 2, i) == LUA_TNUMBER; ++i) {
      picks.push_back(static_cast<uint32_t>(lua_tointeger(L, -1)));
      lua_pop(L, 1);
    }
    lua_pop(L, 1);
  } else {
    for (int i = 2; i <= lua_gettop(L); ++i) picks.push_back(static_cast<uint32_t>(luaL_checkinteger(L, i)));
  }
  D(L);
  std::string why;
  const bool ok = T(L).f.session->respond(Response{picks}, &why);
  lua_pushboolean(L, ok);
  lua_pushstring(L, why.c_str());
  return 2;
}

int t_cancel(lua_State* L) {
  D(L);
  Response r;
  r.cancel = true;
  std::string why;
  lua_pushboolean(L, T(L).f.session->respond(r, &why));
  lua_pushstring(L, why.c_str());
  return 2;
}

int t_request(lua_State* L) {
  const Request* r = D(L).request();
  if (!r) {
    lua_pushnil(L);
    return 1;
  }
  lua_newtable(L);
  lua_pushinteger(L, r->player);
  lua_setfield(L, -2, "player");
  lua_pushinteger(L, r->hint);
  lua_setfield(L, -2, "hint");
  lua_pushinteger(L, r->min);
  lua_setfield(L, -2, "min");
  lua_pushinteger(L, r->max);
  lua_setfield(L, -2, "max");
  lua_pushboolean(L, r->cancelable);
  lua_setfield(L, -2, "cancelable");
  lua_newtable(L);
  for (size_t i = 0; i < r->options.size(); ++i) {
    lua_pushinteger(L, r->options[i]);
    lua_rawseti(L, -2, static_cast<lua_Integer>(i + 1));
  }
  lua_setfield(L, -2, "options");
  // 무엇에 대한 요청인가, 선택지마다의 카드(없으면 nil·빈 표)
  if (r->source != wx::kNoCard) {
    lua_pushinteger(L, r->source);
    lua_setfield(L, -2, "source");
  }
  lua_newtable(L);
  for (size_t i = 0; i < r->option_cards.size(); ++i) {
    lua_pushinteger(L, r->option_cards[i]);
    lua_rawseti(L, -2, static_cast<lua_Integer>(i + 1));
  }
  lua_setfield(L, -2, "option_cards");
  lua_pushinteger(L, r->source_desc);
  lua_setfield(L, -2, "source_desc");
  lua_newtable(L);
  for (size_t i = 0; i < r->option_descs.size(); ++i) {
    lua_pushinteger(L, r->option_descs[i]);
    lua_rawseti(L, -2, static_cast<lua_Integer>(i + 1));
  }
  lua_setfield(L, -2, "option_descs");
  return 1;
}

// t:action(kind, card, zone_name) 또는 t:action(kind, card, n)(그 카드의 n번째 선택지, 0부터) → 선택지 번호 또는 nil
int t_action(lua_State* L) {
  CaseState& t = T(L);
  Duel& d = D(L);
  const auto kind = static_cast<ActionKind>(luaL_checkinteger(L, 2));
  const CardIdx c = lua_isnoneornil(L, 3) ? kNoCard : card_arg(L, 3);
  ZoneId z = kNoZone;
  uint32_t nth = 0;
  // 존 이름은 지금 고르는 플레이어 기준(상대 턴 디펜스 스텝 등)
  const PlayerId who = d.request() ? d.request()->player : d.turn_player;
  if (lua_type(L, 4) == LUA_TNUMBER)
    nth = static_cast<uint32_t>(lua_tointeger(L, 4));
  else if (lua_isstring(L, 4))
    z = t.f.zone(who, lua_tostring(L, 4));
  const uint32_t i = t.f.action(kind, c, z, nth);
  if (i == 0xFFFFFFFF)
    lua_pushnil(L);
  else
    lua_pushinteger(L, i);
  return 1;
}

int t_saw(lua_State* L) {
  lua_pushboolean(L, T(L).f.saw(u32_arg(L, 2)));
  return 1;
}

// ── 상태 조회 ──

int t_count(lua_State* L) {
  D(L);
  lua_pushinteger(L, static_cast<lua_Integer>(T(L).f.count(player_arg(L, 2), luaL_checkstring(L, 3))));
  return 1;
}

// t:at(card) → 존 이름, 존 주인
int t_at(lua_State* L) {
  Duel& d = D(L);
  const Card& c = d.state.cards.get(card_arg(L, 2));
  if (c.zone == kNoZone) return 0;
  const Zone& z = d.state.zones.get(c.zone);
  lua_pushstring(L, z.name.c_str());
  lua_pushinteger(L, z.owner);
  return 2;
}

// t:is_in(card, player, zone_name)
int t_is_in(lua_State* L) {
  Duel& d = D(L);
  const Card& c = d.state.cards.get(card_arg(L, 2));
  lua_pushboolean(L, c.host == kNoCard && c.zone == T(L).f.zone(player_arg(L, 3), luaL_checkstring(L, 4)));
  return 1;
}

int t_coins(lua_State* L) { lua_pushinteger(L, D(L).players[player_arg(L, 2)].coins); return 1; }
int t_add_coin(lua_State* L) {
  const PlayerId p = player_arg(L, 2);
  const int32_t n = static_cast<int32_t>(luaL_checkinteger(L, 3));
  D(L);
  T(L).f.session->command([=](Duel& d) { d.gain_coin(p, n); });
  return 0;
}
// t:gate(p, zone) → 【ゲート】가 있는가 / t:place_gate(p, zone)
int t_gate(lua_State* L) {
  D(L);
  lua_pushboolean(L, D(L).state.zones.get(T(L).f.zone(player_arg(L, 2), luaL_checkstring(L, 3))).gate);
  return 1;
}
int t_place_gate(lua_State* L) {
  D(L);
  const ZoneId z = T(L).f.zone(player_arg(L, 2), luaL_checkstring(L, 3));
  T(L).f.session->command([=](Duel& d) { d.place_gate(z); });
  return 0;
}
// t:virus(p, zone) / t:place_virus(p, zone): 【ウィルス】
int t_virus(lua_State* L) {
  lua_pushboolean(L, D(L).state.zones.get(T(L).f.zone(player_arg(L, 2), luaL_checkstring(L, 3))).virus);
  return 1;
}
int t_place_virus(lua_State* L) {
  D(L);
  const ZoneId z = T(L).f.zone(player_arg(L, 2), luaL_checkstring(L, 3));
  T(L).f.session->command([=](Duel& d) { d.place_virus(z); });
  return 0;
}
int t_remove_virus(lua_State* L) {
  D(L);
  const ZoneId z = T(L).f.zone(player_arg(L, 2), luaL_checkstring(L, 3));
  T(L).f.session->command([=](Duel& d) { d.remove_virus(z, kNoPlayer); });
  return 0;
}
int t_infected(lua_State* L) { lua_pushboolean(L, D(L).infected(card_arg(L, 2))); return 1; }
int t_hand_limit(lua_State* L) { lua_pushinteger(L, D(L).hand_limit(player_arg(L, 2))); return 1; }
int t_keyword(lua_State* L) { lua_pushboolean(L, D(L).has_keyword(card_arg(L, 2), u32_arg(L, 3))); return 1; }
int t_power(lua_State* L) { lua_pushinteger(L, D(L).power_of(card_arg(L, 2))); return 1; }
int t_power_raw(lua_State* L) { lua_pushinteger(L, D(L).power_raw(card_arg(L, 2))); return 1; }
int t_level(lua_State* L) { lua_pushinteger(L, D(L).level_of(card_arg(L, 2))); return 1; }
int t_color(lua_State* L) { lua_pushinteger(L, D(L).color_of(card_arg(L, 2))); return 1; }
int t_text(lua_State* L) { lua_pushinteger(L, D(L).text_of(card_arg(L, 2))); return 1; }
int t_cid(lua_State* L) { lua_pushinteger(L, D(L).state.cards.get(card_arg(L, 2)).cid); return 1; }
int t_oid(lua_State* L) { lua_pushinteger(L, D(L).state.cards.get(card_arg(L, 2)).oid); return 1; }
int t_flags(lua_State* L) { lua_pushinteger(L, D(L).state.cards.get(card_arg(L, 2)).flags); return 1; }
int t_face_up(lua_State* L) { lua_pushboolean(L, D(L).state.cards.get(card_arg(L, 2)).face_up); return 1; }
int t_turn_player(lua_State* L) { lua_pushinteger(L, D(L).turn_player); return 1; }
int t_ended(lua_State* L) { lua_pushboolean(L, D(L).ended()); return 1; }
int t_winner(lua_State* L) { lua_pushinteger(L, D(L).winner()); return 1; }
int t_refreshes(lua_State* L) { lua_pushinteger(L, D(L).players[player_arg(L, 2)].refreshes_this_turn); return 1; }

// t:cards(player, zone_name) → 그 존의 카드(아래→위)
int t_cards(lua_State* L) {
  Duel& d = D(L);
  const auto& cards = d.state.zones.get(T(L).f.zone(player_arg(L, 2), luaL_checkstring(L, 3))).cards;
  lua_newtable(L);
  for (size_t i = 0; i < cards.size(); ++i) {
    lua_pushinteger(L, cards[i]);
    lua_rawseti(L, -2, static_cast<lua_Integer>(i + 1));
  }
  return 1;
}

int t_center(lua_State* L) {
  const CardIdx c = D(L).center_lrig(player_arg(L, 2));
  if (c == kNoCard)
    lua_pushnil(L);
  else
    lua_pushinteger(L, c);
  return 1;
}

int t_under(lua_State* L) {
  const auto& u = D(L).state.cards.get(card_arg(L, 2)).under;
  lua_newtable(L);
  for (size_t i = 0; i < u.size(); ++i) {
    lua_pushinteger(L, u[i]);
    lua_rawseti(L, -2, static_cast<lua_Integer>(i + 1));
  }
  return 1;
}

int t_can_see(lua_State* L) {
  lua_pushboolean(L, D(L).state.can_see(player_arg(L, 2), card_arg(L, 3)));
  return 1;
}

// t:global(name) → 대전 Lua 상태의 전역 값(스크립트가 남긴 기록 확인용). 정수·문자열·불만
int t_global(lua_State* L) {
  lua_State* G = D(L).lua();
  lua_getglobal(G, luaL_checkstring(L, 2));
  switch (lua_type(G, -1)) {
    case LUA_TNUMBER: lua_pushinteger(L, lua_tointeger(G, -1)); break;
    case LUA_TSTRING: lua_pushstring(L, lua_tostring(G, -1)); break;
    case LUA_TBOOLEAN: lua_pushboolean(L, lua_toboolean(G, -1)); break;
    case LUA_TTABLE: {
      std::string joined;
      for (lua_Integer i = 1; lua_rawgeti(G, -1, i) == LUA_TSTRING; ++i) {
        if (!joined.empty()) joined += ' ';
        joined += lua_tostring(G, -1);
        lua_pop(G, 1);
      }
      lua_pop(G, 1);
      lua_pushstring(L, joined.c_str());
      break;
    }
    default: lua_pushnil(L);
  }
  lua_pop(G, 1);
  return 1;
}

// t:abilities(c) → 인쇄 능력 목록 {{type=ABILITY_*, desc=}, …}
int t_abilities(lua_State* L) {
  Duel& d = D(L);
  const CardIdx c = card_arg(L, 2);
  lua_newtable(L);
  lua_Integer n = 0;
  d.effects.for_each([&](Effect& e) {
    if (e.handler != c || !e.printed) return;
    lua_newtable(L);
    lua_pushinteger(L, ability_type_of(e));
    lua_setfield(L, -2, "type");
    lua_pushinteger(L, e.desc);
    lua_setfield(L, -2, "desc");
    lua_rawseti(L, -2, ++n);
  });
  return 1;
}
// t:desc_text(desc) → DB의 효과 설명 문장
int t_desc_text(lua_State* L) {
  lua_pushstring(L, Fixture::db().desc_text(u32_arg(L, 2)).c_str());
  return 1;
}
// t:has_script(cid) → 스크립트 파일이 있는가
int t_has_script(lua_State* L) {
  std::string code;
  lua_pushboolean(L, Fixture::db().read_script("c" + std::to_string(u32_arg(L, 2)) + ".lua", code));
  return 1;
}
int t_logs(lua_State* L) {
  lua_pushinteger(L, static_cast<lua_Integer>(T(L).f.logs.size()));
  return 1;
}

// ── 상태 조작(테스트 모드) ──

// 상태를 바꾸는 조작은 전부 session->command로(되돌리기 때 다시 실행된다)
template <class F>
auto cmd(lua_State* L, F f) {
  D(L);
  return T(L).f.session->command(f);
}
ZoneId zone_arg(lua_State* L, int i) {
  D(L);
  return T(L).f.zone(player_arg(L, i), luaL_checkstring(L, i + 1));
}

int t_move(lua_State* L) {
  const CardIdx c = card_arg(L, 2);
  const ZoneId z = zone_arg(L, 3);
  const Pos pos = lua_toboolean(L, 5) ? Pos::Bottom : Pos::Top;
  cmd(L, [=](Duel& d) { d.state.move(c, z, pos); });
  return 0;
}
int t_attach(lua_State* L) {
  const CardIdx c = card_arg(L, 2), host = card_arg(L, 3);
  cmd(L, [=](Duel& d) { d.state.attach(c, host); });
  return 0;
}
int t_put_under(lua_State* L) {
  const CardIdx c = card_arg(L, 2), host = card_arg(L, 3);
  cmd(L, [=](Duel& d) { d.state.put_under(c, host); });
  return 0;
}
int t_set_flags(lua_State* L) {
  const CardIdx c = card_arg(L, 2);
  const uint32_t f = u32_arg(L, 3);
  cmd(L, [=](Duel& d) { d.state.cards.get(c).flags = f; });
  return 0;
}
int t_remove_zone(lua_State* L) {
  const ZoneId z = zone_arg(L, 2);
  const PlayerId by = static_cast<PlayerId>(u32_arg(L, 4));
  cmd(L, [=](Duel& d) { d.remove_zone(z, by); });
  return 0;
}
int t_reset_phase(lua_State* L) {
  const uint32_t phase = u32_arg(L, 2);
  cmd(L, [=](Duel& d) { d.reset_phase(phase); });
  return 0;
}

// 효과 처리 결과로 생긴 지속 효과를 흉내 낸다
// t:single(target, code, value, by, reset)  — 「～まで」 고정 대상
int t_single(lua_State* L) {
  D(L);
  lua_pushinteger(L, T(L).f.single(card_arg(L, 2), u32_arg(L, 3), static_cast<int32_t>(luaL_checkinteger(L, 4)),
                                   player_arg(L, 5), u32_arg(L, 6)));
  return 1;
}
// t:grant(target, code, value, by)  — 능력 부여
int t_grant(lua_State* L) {
  D(L);
  lua_pushinteger(L, T(L).f.grant(card_arg(L, 2), u32_arg(L, 3), static_cast<int32_t>(luaL_checkinteger(L, 4)),
                                  player_arg(L, 5)));
  return 1;
}
// t:field(code, value, by, self_loc, opp_loc, reset)  — 「～の間」「このターン」 동적
int t_field(lua_State* L) {
  D(L);
  lua_pushinteger(L, T(L).f.field(u32_arg(L, 2), static_cast<int32_t>(luaL_checkinteger(L, 3)), player_arg(L, 4),
                                  u32_arg(L, 5), u32_arg(L, 6), u32_arg(L, 7)));
  return 1;
}
// t:suppress(by, reset)  — 이노센스
int t_suppress(lua_State* L) {
  const PlayerId by = player_arg(L, 2);
  const uint32_t reset = u32_arg(L, 3);
  lua_pushinteger(L, cmd(L, [=](Duel& d) { return d.suppress_opponent_effects(by, reset); }));
  return 1;
}
// t:copy(card, cid, by, reset)  — 조커
int t_copy(lua_State* L) {
  const CardIdx c = card_arg(L, 2);
  const Cid cid = static_cast<Cid>(luaL_checkinteger(L, 3));
  const PlayerId by = player_arg(L, 4);
  const uint32_t reset = u32_arg(L, 5);
  lua_pushinteger(L, cmd(L, [=](Duel& d) { return d.become_copy(c, cid, by, reset); }));
  return 1;
}

// t:undo() — 마지막 응답을 되돌린다(기록 재실행). 되돌릴 게 없으면 false
int t_undo(lua_State* L) {
  D(L);
  lua_pushboolean(L, T(L).f.session->undo());
  return 1;
}

// ── 판정 ──

// t:expect(조건, 설명)
int t_expect(lua_State* L) {
  if (lua_toboolean(L, 2)) return 0;
  luaL_where(L, 1);
  std::string msg = lua_tostring(L, -1);
  lua_pop(L, 1);
  msg += luaL_optstring(L, 3, "expect 실패");
  T(L).failures.push_back(msg);
  return 0;
}

// t:allow_logs() — 코어 로그(스크립트 오류 등)가 나와도 실패로 보지 않는다
int t_allow_logs(lua_State* L) {
  T(L).allow_logs = true;
  return 0;
}

const luaL_Reg kMethods[] = {
    {"card", t_card}, {"signi", t_signi}, {"lrig", t_lrig}, {"script", t_script}, {"start", t_start},
    {"put", t_put}, {"fill", t_fill}, {"deck", t_deck}, {"begin", t_begin}, {"start_game", t_start_game},
    {"wait", t_wait}, {"answer", t_answer}, {"cancel", t_cancel}, {"request", t_request}, {"action", t_action},
    {"saw", t_saw}, {"count", t_count}, {"at", t_at}, {"is_in", t_is_in}, {"power", t_power},
    {"power_raw", t_power_raw}, {"level", t_level}, {"color", t_color}, {"text", t_text}, {"cid", t_cid},
    {"oid", t_oid}, {"flags", t_flags}, {"face_up", t_face_up}, {"turn_player", t_turn_player},
    {"ended", t_ended}, {"winner", t_winner}, {"refreshes", t_refreshes}, {"center", t_center}, {"cards", t_cards},
    {"under", t_under}, {"can_see", t_can_see}, {"global", t_global}, {"logs", t_logs}, {"move", t_move},
    {"attach", t_attach}, {"put_under", t_put_under}, {"set_flags", t_set_flags},
    {"remove_zone", t_remove_zone}, {"reset_phase", t_reset_phase}, {"single", t_single}, {"grant", t_grant},
    {"field", t_field}, {"suppress", t_suppress}, {"copy", t_copy}, {"expect", t_expect},
    {"allow_logs", t_allow_logs}, {"undo", t_undo}, {"keyword", t_keyword}, {"abilities", t_abilities}, {"desc_text", t_desc_text}, {"has_script", t_has_script},
    {"coins", t_coins}, {"hand_limit", t_hand_limit}, {"add_coin", t_add_coin}, {"gate", t_gate}, {"place_gate", t_place_gate}, {"virus", t_virus}, {"place_virus", t_place_virus}, {"infected", t_infected}, {"remove_virus", t_remove_virus}, {"no", t_no}, {"deck_file", t_deck_file},
    {nullptr, nullptr}};

struct Const {
  const char* name;
  lua_Integer value;
};
#define WX_C(x) {#x, static_cast<lua_Integer>(x)}
const Const kConstants[] = {
    WX_C(PHASE_UP), WX_C(PHASE_DRAW), WX_C(PHASE_ENA), WX_C(PHASE_GROW), WX_C(PHASE_MAIN), WX_C(PHASE_ATTACK),
    WX_C(PHASE_END), WX_C(RESET_PHASE),
    WX_C(EFFECT_COPY), WX_C(EFFECT_CHANGE_COLOR), WX_C(EFFECT_ADD_COLOR), WX_C(EFFECT_ADD_CLASS),
    WX_C(EFFECT_CHANGE_LEVEL), WX_C(EFFECT_UPDATE_LEVEL), WX_C(EFFECT_UPDATE_LIMIT), WX_C(EFFECT_LOSE_ABILITY),
    WX_C(EFFECT_SET_POWER), WX_C(EFFECT_UPDATE_POWER), WX_C(EFFECT_MULTI_ENA), WX_C(EFFECT_LANCER), WX_C(EFFECT_S_LANCER), WX_C(EFFECT_CANNOT_BANISH),
    WX_C(EFFECT_DOUBLE_CRUSH), WX_C(EFFECT_ASSASSIN), WX_C(EFFECT_GRANT), WX_C(EFFECT_CANNOT_ATTACK),
    WX_C(EFFECT_UPDATE_HAND_LIMIT),
    WX_C(LOCATION_MDECK), WX_C(LOCATION_LIFE), WX_C(LOCATION_LDECK), WX_C(LOCATION_HAND), WX_C(LOCATION_TRASH),
    WX_C(LOCATION_LTRASH), WX_C(LOCATION_ENA), WX_C(LOCATION_CHECK), WX_C(LOCATION_EXCLUDE), WX_C(LOCATION_LRIG),
    WX_C(LOCATION_ASSIST), WX_C(LOCATION_KEY), WX_C(LOCATION_SIGNI), WX_C(LOCATION_CHEER), WX_C(LOCATION_SZONE),
    WX_C(LOCATION_FIELD),
    WX_C(TYPE_LRIG), WX_C(TYPE_SIGNI), WX_C(TYPE_ARTS), WX_C(TYPE_SPELL), WX_C(TYPE_ASSIST_LRIG),
    WX_C(TYPE_TOKEN), WX_C(TYPE_PIECE), WX_C(TYPE_KEY), WX_C(TYPE_RESONA), WX_C(TYPE_CRAFT),
    WX_C(COLOR_WHITE), WX_C(COLOR_RED), WX_C(COLOR_BLUE), WX_C(COLOR_GREEN), WX_C(COLOR_BLACK),
    WX_C(TIMING_MAIN), WX_C(TIMING_ATTACK), WX_C(TIMING_CUTIN),
    WX_C(CF_DOWN), WX_C(CF_FROZEN), WX_C(CF_BLOOD),
    WX_C(HINT_MULLIGAN), WX_C(HINT_START_LRIG), WX_C(HINT_CENTER_LRIG), WX_C(HINT_ENA_CHARGE), WX_C(HINT_GROW),
    WX_C(HINT_PAY_ENA), WX_C(HINT_MAIN), WX_C(HINT_REMOVE), WX_C(HINT_ATTACK_SIGNI), WX_C(HINT_ATTACK_LRIG),
    WX_C(HINT_GUARD), WX_C(HINT_DISCARD), WX_C(HINT_TRIGGER_ORDER), WX_C(HINT_USE_TRIGGER),
    WX_C(HINT_LIFEBURST), WX_C(HINT_RULE_TRASH), WX_C(HINT_SCRIPT), WX_C(HINT_PRE_ATTACK), WX_C(HINT_DEFENSE),
    WX_C(HINT_CUTIN), WX_C(HINT_TARGET), WX_C(HINT_MODE), WX_C(HINT_SELECT), WX_C(HINT_ZONE), WX_C(HINT_EXCEED), WX_C(HINT_ENCORE), WX_C(HINT_DECLARE), WX_C(HINT_ORDER), WX_C(HINT_BET), WX_C(HINT_RESONA),
    {"ACT_END", static_cast<lua_Integer>(ActionKind::EndPhase)},
    {"ACT_PLAY", static_cast<lua_Integer>(ActionKind::PlaySigni)},
    {"ACT_REMOVE", static_cast<lua_Integer>(ActionKind::Remove)},
    {"ACT_USE", static_cast<lua_Integer>(ActionKind::UseCard)},
    {"ACT_ABILITY", static_cast<lua_Integer>(ActionKind::UseAbility)},
    {"ACT_GROW", static_cast<lua_Integer>(ActionKind::Grow)},
    {"ACT_KEY", static_cast<lua_Integer>(ActionKind::PlayKey)},
    WX_C(ABILITY_AUTO), WX_C(ABILITY_ON_PLAY), WX_C(ABILITY_IGNITION), WX_C(ABILITY_CONTINUOUS), WX_C(ABILITY_USE),
    {"ACT_RESONA", static_cast<lua_Integer>(ActionKind::PlayResona)},
};
#undef WX_C

struct LuaCase {
  std::string file, name, ref;
  int fn_ref;
};

std::vector<LuaCase>* g_cases = nullptr;
std::string g_file;

// case(name, ref, fn)
int l_case(lua_State* L) {
  LuaCase c;
  c.file = g_file;
  c.name = luaL_checkstring(L, 1);
  c.ref = luaL_checkstring(L, 2);
  luaL_checktype(L, 3, LUA_TFUNCTION);
  lua_pushvalue(L, 3);
  c.fn_ref = luaL_ref(L, LUA_REGISTRYINDEX);
  g_cases->push_back(std::move(c));
  return 0;
}

}  // namespace

int run_lua_cases(const std::string& dir, const char* filter, int& run, int& failed) {
  namespace fs = std::filesystem;
  lua_State* L = luaL_newstate();
  luaL_openlibs(L);
  luaL_newmetatable(L, kMeta);
  lua_newtable(L);
  luaL_setfuncs(L, kMethods, 0);
  lua_setfield(L, -2, "__index");
  lua_pop(L, 1);
  for (const Const& k : kConstants) {
    lua_pushinteger(L, k.value);
    lua_setglobal(L, k.name);
  }
  lua_register(L, "case", l_case);

  std::vector<LuaCase> cases;
  g_cases = &cases;
  std::vector<fs::path> files;
  if (fs::exists(dir))
    for (const auto& e : fs::directory_iterator(dir))
      if (e.path().extension() == ".lua") files.push_back(e.path());
  std::sort(files.begin(), files.end());
  int load_errors = 0;
  for (const auto& p : files) {
    g_file = p.filename().string();
    std::ifstream in(p, std::ios::binary);
    std::stringstream ss;
    ss << in.rdbuf();
    const std::string code = ss.str();
    if (luaL_loadbuffer(L, code.data(), code.size(), ("@" + g_file).c_str()) != LUA_OK ||
        lua_pcall(L, 0, 0, 0) != LUA_OK) {
      std::printf("LOAD FAIL %s: %s\n", g_file.c_str(), lua_tostring(L, -1));
      lua_pop(L, 1);
      ++load_errors;
    }
  }

  for (const LuaCase& c : cases) {
    if (filter && !std::strstr(c.name.c_str(), filter) && !std::strstr(c.file.c_str(), filter)) continue;
    ++run;
    CaseState state;
    CaseState* ptr = &state;
    lua_rawgeti(L, LUA_REGISTRYINDEX, c.fn_ref);
    *static_cast<CaseState**>(lua_newuserdatauv(L, sizeof(CaseState*), 0)) = ptr;
    luaL_setmetatable(L, kMeta);
    if (lua_pcall(L, 1, 0, 0) != LUA_OK) {
      state.failures.push_back(std::string("오류: ") + lua_tostring(L, -1));
      lua_pop(L, 1);
    }
    if (!state.allow_logs)
      for (const auto& m : state.f.logs) state.failures.push_back("코어 로그: " + m);
    if (!state.failures.empty()) {
      ++failed;
      std::printf("FAIL %s  [%s] (%s)\n", c.name.c_str(), c.ref.c_str(), c.file.c_str());
      for (const auto& m : state.failures) std::printf("    %s\n", m.c_str());
    }
    luaL_unref(L, LUA_REGISTRYINDEX, c.fn_ref);
  }
  lua_close(L);
  g_cases = nullptr;
  return load_errors;
}
