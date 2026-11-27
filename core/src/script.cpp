// Lua 바인딩. 유프로 스크립트 구조(GetID, initial_effect, Effect.CreateEffect…)를 따른다.
// Lua는 C++로 빌드한 것을 쓰므로 lua.hpp(extern "C")가 아니라 lua.h를 직접 포함한다.
#include <lauxlib.h>
#include <lua.h>
#include <lualib.h>

#include <algorithm>
#include <memory>

#include "cost.h"
#include "duel.h"
#include "lua_sandbox.h"

namespace wx {

struct CardUD {
  CardIdx idx;
};
struct EffectUD {
  EffectId id;
};

struct ScriptAccess {
  static Duel& duel(lua_State* L) { return **static_cast<Duel**>(lua_getextraspace(L)); }
};

namespace {

constexpr const char* kCardMeta = "Card";
constexpr const char* kEffectMeta = "Effect";

// UTF-8 BOM을 뗀다. Windows 메모장 등으로 저장한 스크립트(오리카)도 읽히게
void strip_bom(std::string& code) {
  if (code.size() >= 3 && code.compare(0, 3, "\xEF\xBB\xBF") == 0) code.erase(0, 3);
}

Duel& D(lua_State* L) { return ScriptAccess::duel(L); }

// 같은 카드·효과는 항상 같은 userdata로 넘겨서 Lua의 == 비교가 되게 한다
void push_cached(lua_State* L, const char* cache, const char* meta, lua_Integer key, uint32_t value) {
  lua_getfield(L, LUA_REGISTRYINDEX, cache);
  if (lua_rawgeti(L, -1, key) == LUA_TNIL) {
    lua_pop(L, 1);
    auto* ud = static_cast<uint32_t*>(lua_newuserdatauv(L, sizeof(uint32_t), 0));
    *ud = value;
    luaL_setmetatable(L, meta);
    lua_pushvalue(L, -1);
    lua_rawseti(L, -3, key);
  }
  lua_remove(L, -2);
}

void push_card(lua_State* L, CardIdx c) {
  if (c == kNoCard) {
    lua_pushnil(L);
    return;
  }
  push_cached(L, "wx_cards", kCardMeta, static_cast<lua_Integer>(c) + 1, c);
}

void push_effect(lua_State* L, EffectId e) {
  if (e == kNoEffect) {
    lua_pushnil(L);
    return;
  }
  push_cached(L, "wx_effects", kEffectMeta, e, e);
}

CardIdx check_card(lua_State* L, int i) { return static_cast<CardUD*>(luaL_checkudata(L, i, kCardMeta))->idx; }

Effect& check_effect(lua_State* L, int i) {
  EffectId id = static_cast<EffectUD*>(luaL_checkudata(L, i, kEffectMeta))->id;
  return *D(L).effects.get(id);
}

PlayerId check_player(lua_State* L, int i) {
  const lua_Integer p = luaL_checkinteger(L, i);
  luaL_argcheck(L, p == 0 || p == 1, i, "플레이어는 0 또는 1");
  return static_cast<PlayerId>(p);
}
ZoneId check_zone(lua_State* L, int i) {
  const lua_Integer z = luaL_checkinteger(L, i);
  luaL_argcheck(L, z >= 0 && z < static_cast<lua_Integer>(D(L).state.zones.size()), i, "없는 존 번호");
  return static_cast<ZoneId>(z);
}
size_t check_count(lua_State* L, int i) { return static_cast<size_t>(std::max<lua_Integer>(0, luaL_checkinteger(L, i))); }
uint32_t check_u32(lua_State* L, int i) { return static_cast<uint32_t>(luaL_checkinteger(L, i)); }

int ref_function(lua_State* L, int i, int old) {
  luaL_checktype(L, i, LUA_TFUNCTION);
  if (old) luaL_unref(L, LUA_REGISTRYINDEX, old);
  lua_pushvalue(L, i);
  return luaL_ref(L, LUA_REGISTRYINDEX);
}

// ── 전역 ──

int l_GetID(lua_State* L) {
  lua_getfield(L, LUA_REGISTRYINDEX, "wx_cur_table");
  lua_getfield(L, LUA_REGISTRYINDEX, "wx_cur_id");
  return 2;
}

// math.random은 코어 PRNG로 바꾼다(결정론)
int l_random(lua_State* L) {
  Rng& r = D(L).state.rng;
  lua_Integer lo = 1, hi;
  switch (lua_gettop(L)) {
    case 0:
      lua_pushnumber(L, static_cast<lua_Number>(r.next_u64() >> 11) * (1.0 / 9007199254740992.0));
      return 1;
    case 1: hi = luaL_checkinteger(L, 1); break;
    default:
      lo = luaL_checkinteger(L, 1);
      hi = luaL_checkinteger(L, 2);
  }
  luaL_argcheck(L, lo <= hi, 1, "interval is empty");
  lua_pushinteger(L, lo + r.below(static_cast<uint32_t>(hi - lo + 1)));
  return 1;
}

int l_randomseed(lua_State*) { return 0; }

// ── Effect ──

int e_CreateEffect(lua_State* L) {
  Duel& d = D(L);
  CardIdx c = check_card(L, 1);
  EffectId id = d.effects.create();
  Effect& e = *d.effects.get(id);
  e.owner_card = c;
  e.owner_player = d.state.cards.get(c).controller;
  push_effect(L, id);
  return 1;
}

int e_SetType(lua_State* L) { check_effect(L, 1).type = check_u32(L, 2); return 0; }
int e_SetCode(lua_State* L) {
  check_effect(L, 1).code = check_u32(L, 2);
  D(L).effects.mark(check_u32(L, 2));
  return 0;
}
int e_SetProperty(lua_State* L) { check_effect(L, 1).property = check_u32(L, 2); return 0; }
// 능력의 분류(ABILITY_*)
int e_SetAbilityType(lua_State* L) { check_effect(L, 1).ability_type = check_u32(L, 2); return 0; }
int e_GetAbilityType(lua_State* L) { lua_pushinteger(L, ability_type_of(check_effect(L, 1))); return 1; }
int e_IsAbilityType(lua_State* L) { lua_pushboolean(L, (ability_type_of(check_effect(L, 1)) & check_u32(L, 2)) != 0); return 1; }
int e_SetRange(lua_State* L) { check_effect(L, 1).range = check_u32(L, 2); return 0; }

int e_SetTargetRange(lua_State* L) {
  Effect& e = check_effect(L, 1);
  e.target_self = check_u32(L, 2);
  e.target_opp = check_u32(L, 3);
  return 0;
}

// 정수, 함수(e,c), 문자열(클래스 등은 intern id로 저장)
int e_SetValue(lua_State* L) {
  Effect& e = check_effect(L, 1);
  if (!lua_isfunction(L, 2) && e.value_ref) {  // 함수였던 값을 정수로 바꾼다
    luaL_unref(L, LUA_REGISTRYINDEX, e.value_ref);
    e.value_ref = 0;
  }
  if (lua_isfunction(L, 2)) {
    e.value_ref = ref_function(L, 2, e.value_ref);
  } else if (lua_type(L, 2) == LUA_TSTRING) {
    e.value = static_cast<int32_t>(D(L).intern(lua_tostring(L, 2)));
  } else {
    e.value = static_cast<int32_t>(luaL_checkinteger(L, 2));
  }
  return 0;
}

int e_SetTarget(lua_State* L) {
  Effect& e = check_effect(L, 1);
  e.target_ref = ref_function(L, 2, e.target_ref);
  return 0;
}

int e_SetDeclare(lua_State* L) {
  Effect& e = check_effect(L, 1);
  e.declare_ref = ref_function(L, 2, e.declare_ref);
  return 0;
}

// e:SetCheck(f) — EFFECT_RESONA: 고른 출현 조건 조합을 검증한다. f(g) → bool
int e_SetCheck(lua_State* L) {
  Effect& e = check_effect(L, 1);
  e.check_ref = ref_function(L, 2, e.check_ref);
  return 0;
}

// e:SetMinCost(f) — 「使用コストは…減る」 아츠·스펠: f(e,tp) → 가장 많이 줄였을 때의 에나 코스트. 실제 코스트는 SetDeclare에서 Duel.SetUseCost로
int e_SetMinCost(lua_State* L) {
  Effect& e = check_effect(L, 1);
  e.min_cost_ref = ref_function(L, 2, e.min_cost_ref);
  return 0;
}

int e_SetOperation(lua_State* L) {
  Effect& e = check_effect(L, 1);
  e.operation_ref = ref_function(L, 2, e.operation_ref);
  return 0;
}

int e_SetCondition(lua_State* L) {
  Effect& e = check_effect(L, 1);
  e.condition_ref = ref_function(L, 2, e.condition_ref);
  return 0;
}

int e_SetReset(lua_State* L) {
  Effect& e = check_effect(L, 1);
  e.reset = check_u32(L, 2);
  e.reset_count = static_cast<uint32_t>(luaL_optinteger(L, 3, 1));
  return 0;
}

int e_SetLabel(lua_State* L) { check_effect(L, 1).label = luaL_checkinteger(L, 2); return 0; }
int e_SetDescription(lua_State* L) { check_effect(L, 1).desc = static_cast<uint32_t>(luaL_checkinteger(L, 2)); return 0; }
int e_GetValue(lua_State* L) { lua_pushinteger(L, check_effect(L, 1).value); return 1; }
int e_GetDescription(lua_State* L) { lua_pushinteger(L, check_effect(L, 1).desc); return 1; }
int e_GetLabel(lua_State* L) { lua_pushinteger(L, check_effect(L, 1).label); return 1; }
int e_GetHandler(lua_State* L) { push_card(L, check_effect(L, 1).handler); return 1; }
int e_GetOwner(lua_State* L) { push_card(L, check_effect(L, 1).owner_card); return 1; }
int e_GetOwnerPlayer(lua_State* L) { lua_pushinteger(L, check_effect(L, 1).owner_player); return 1; }

int e_GetHandlerPlayer(lua_State* L) {
  Effect& e = check_effect(L, 1);
  PlayerId p = e.handler != kNoCard ? D(L).state.cards.get(e.handler).controller : e.owner_player;
  lua_pushinteger(L, p);
  return 1;
}

// ── Card ──

int c_RegisterEffect(lua_State* L) {
  CardIdx c = check_card(L, 1);
  Effect& e = check_effect(L, 2);
  Duel& d = D(L);
  d.register_effect(e.id, c);
  if (e.owner_card != c && !d.chain.empty()) d.note_arts_hit(c, d.chain.back().effect);
  return 0;
}

int c_GrantEffect(lua_State* L) {
  CardIdx c = check_card(L, 1);
  Effect& e = check_effect(L, 2);
  D(L).grant_effect(e.id, c);
  return 0;
}

int c_GetCode(lua_State* L) { lua_pushinteger(L, D(L).text_of(check_card(L, 1))); return 1; }
int c_GetOriginalCode(lua_State* L) { lua_pushinteger(L, D(L).state.cards.get(check_card(L, 1)).cid); return 1; }
int c_GetPower(lua_State* L) { lua_pushinteger(L, D(L).power_of(check_card(L, 1))); return 1; }
int c_GetLevel(lua_State* L) { lua_pushinteger(L, D(L).level_of(check_card(L, 1))); return 1; }
int c_GetColor(lua_State* L) { lua_pushinteger(L, D(L).color_of(check_card(L, 1))); return 1; }
int c_IsColor(lua_State* L) { lua_pushboolean(L, (D(L).color_of(check_card(L, 1)) & check_u32(L, 2)) != 0); return 1; }
int c_IsType(lua_State* L) { lua_pushboolean(L, (D(L).type_of(check_card(L, 1)) & check_u32(L, 2)) != 0); return 1; }
int c_IsSigni(lua_State* L) { lua_pushboolean(L, (D(L).type_of(check_card(L, 1)) & TYPE_SIGNI) != 0); return 1; }
// c:IsClass(sys, race): 0은 「아무거나」. 예: c:IsClass(0, RACE_YUGU), c:IsClass(SYS_SEIZOU, 0)
int c_IsClass(lua_State* L) {
  const uint32_t sys = check_u32(L, 2), race = check_u32(L, 3);
  if (!sys && !race) return luaL_error(L, "IsClass: 系統과 種族이 둘 다 0");
  lua_pushboolean(L, D(L).has_class(check_card(L, 1), sys, race));
  return 1;
}
int c_IsInfected(lua_State* L) { lua_pushboolean(L, D(L).infected(check_card(L, 1))); return 1; }
int c_IsBloodArmed(lua_State* L) { lua_pushboolean(L, (D(L).state.cards.get(check_card(L, 1)).flags & CF_BLOOD) != 0); return 1; }
int c_IsCross(lua_State* L) { lua_pushboolean(L, D(L).is_cross(check_card(L, 1))); return 1; }
// 《クロスアイコン》を持つ: 크로스 조건을 가진 카드(어느 위치든)
int c_HasCrossIcon(lua_State* L) { lua_pushboolean(L, D(L).has_keyword(check_card(L, 1), EFFECT_CROSS)); return 1; }
// c:HasGuardIcon() — 인쇄된 《ガードアイコン》(카드 데이터)
int c_HasGuardIcon(lua_State* L) {
  Duel& d = D(L);
  lua_pushboolean(L, d.data(d.text_of(check_card(L, 1))).guard);
  return 1;
}
int c_IsSameName(lua_State* L) { lua_pushboolean(L, D(L).same_name(check_card(L, 1), check_card(L, 2))); return 1; }
int c_IsLrigType(lua_State* L) {
  const auto& t = D(L).lrig_types_of(check_card(L, 1));
  lua_pushboolean(L, std::find(t.begin(), t.end(), check_u32(L, 2)) != t.end());
  return 1;
}
int c_GetLocation(lua_State* L) { lua_pushinteger(L, D(L).location_of(check_card(L, 1))); return 1; }
int c_IsLocation(lua_State* L) { lua_pushboolean(L, (D(L).location_of(check_card(L, 1)) & check_u32(L, 2)) != 0); return 1; }
// 직전에 있던 곳(「デッキから場に出た場合」「場から手札に戻ったとき」)
int c_GetPreviousLocation(lua_State* L) { lua_pushinteger(L, D(L).state.cards.get(check_card(L, 1)).prev_loc); return 1; }
int c_IsPreviousLocation(lua_State* L) {
  lua_pushboolean(L, (D(L).state.cards.get(check_card(L, 1)).prev_loc & check_u32(L, 2)) != 0);
  return 1;
}
int c_GetControler(lua_State* L) { lua_pushinteger(L, D(L).state.cards.get(check_card(L, 1)).controller); return 1; }
int c_GetOwner(lua_State* L) { lua_pushinteger(L, D(L).state.cards.get(check_card(L, 1)).owner); return 1; }
int c_IsFaceup(lua_State* L) { lua_pushboolean(L, D(L).state.cards.get(check_card(L, 1)).face_up); return 1; }
int c_IsDown(lua_State* L) { lua_pushboolean(L, (D(L).state.cards.get(check_card(L, 1)).flags & CF_DOWN) != 0); return 1; }
int c_IsUp(lua_State* L) { lua_pushboolean(L, (D(L).state.cards.get(check_card(L, 1)).flags & CF_DOWN) == 0); return 1; }
int c_IsFrozen(lua_State* L) { lua_pushboolean(L, (D(L).state.cards.get(check_card(L, 1)).flags & CF_FROZEN) != 0); return 1; }
int c_HasKeyword(lua_State* L) { lua_pushboolean(L, D(L).has_keyword(check_card(L, 1), check_u32(L, 2))); return 1; }
// 정수 목록을 Lua 표로
void push_ids(lua_State* L, const std::vector<uint32_t>& list) {
  lua_createtable(L, static_cast<int>(list.size()), 0);
  for (size_t i = 0; i < list.size(); ++i) {
    lua_pushinteger(L, list[i]);
    lua_rawseti(L, -2, static_cast<lua_Integer>(i + 1));
  }
}
// c:GetClasses() → 클래스 코드 목록(系統 << 16 | 種族. 좌우가 다 같아야 같은 클래스, WXDi-D01-012 FAQ 2)
int c_GetClasses(lua_State* L) {
  push_ids(L, D(L).classes_of(check_card(L, 1)));
  return 1;
}
int c_GetLrigTypes(lua_State* L) {
  push_ids(L, D(L).lrig_types_of(check_card(L, 1)));
  return 1;
}

// ── Duel ──

int d_Draw(lua_State* L) {
  Duel& d = D(L);
  const PlayerId p = check_player(L, 1);
  const uint32_t n = static_cast<uint32_t>(luaL_checkinteger(L, 2));
  const uint32_t reason = static_cast<uint32_t>(luaL_optinteger(L, 3, REASON_EFFECT));
  lua_pushinteger(L, d.draw(p, n, reason));
  return 1;
}

void push_group(lua_State* L, const std::vector<CardIdx>& cards);

// Duel.EnaCharge(p, n) → 에나에 놓인 카드
int d_EnaCharge(lua_State* L) {
  Duel& d = D(L);
  const PlayerId p = check_player(L, 1);
  const uint32_t n = static_cast<uint32_t>(luaL_checkinteger(L, 2));
  const ActCtx* ctx = d.chain.empty() ? nullptr : &d.chain.back();
  push_group(L, d.ena_charge(p, n, REASON_EFFECT, ctx ? ctx->player : p, ctx ? ctx->effect : kNoEffect));
  return 1;
}

// Duel.IsTeam(p, team) — 루리그 3체가 모두 그 팀인가
int d_IsTeam(lua_State* L) {
  lua_pushboolean(L, D(L).team_ok(check_player(L, 1), luaL_checkstring(L, 2)));
  return 1;
}

bool pass_filter(lua_State* L, int fidx, CardIdx c, int extra_from, int extra_to);

std::vector<CardIdx> cards_arg(lua_State* L, int i);
PlayerId reason_player(Duel& d);
EffectId reason_effect(Duel& d);

// Duel.SendToDeckTop(c) / Duel.SendToDeckPosition(c, n) — 「デッキの一番上」「デッキの上からＮ番目」
int d_SendToDeckPosition(lua_State* L) {
  Duel& d = D(L);
  const uint32_t n = static_cast<uint32_t>(luaL_optinteger(L, 2, 1));
  for (CardIdx c : cards_arg(L, 1))
    if (d.state.cards.get(c).zone != kNoZone)
      d.move_to_deck_position(c, n, REASON_EFFECT, reason_player(d), reason_effect(d));
  return 0;
}

// Duel.SendToDeckShuffle(g) — 「デッキに加えてシャッフルする」. 옮긴 카드가 없어도 섞는다(WDK09-001 FAQ 6)
int d_SendToDeckShuffle(lua_State* L) {
  Duel& d = D(L);
  std::vector<PlayerId> owners;
  for (CardIdx c : cards_arg(L, 1)) {
    const Card& card = d.state.cards.get(c);
    if (card.zone == kNoZone) continue;
    d.move_card(c, d.state.zones.find(card.owner, ZoneKind::MainDeck), REASON_EFFECT, reason_player(d), Pos::Top,
                reason_effect(d));
    owners.push_back(card.owner);
  }
  if (lua_isinteger(L, 2)) owners.push_back(static_cast<PlayerId>(lua_tointeger(L, 2)));
  std::sort(owners.begin(), owners.end());
  owners.erase(std::unique(owners.begin(), owners.end()), owners.end());
  for (PlayerId p : owners) d.state.shuffle(d.state.zones.find(p, ZoneKind::MainDeck));
  return 0;
}

// Duel.RevealCards(g) — 공개. 양쪽이 본다(덱 위 공개 뒤에는 그 자리에 뒷면으로 남는다. WDK09-001 FAQ 2).
// 패의 카드를 공개하면 패 주인마다 EVENT_REVEALED_FROM_HAND 한 번
int d_RevealCards(lua_State* L) {
  Duel& d = D(L);
  const auto cards = cards_arg(L, 1);
  d.reveal(cards);
  for (PlayerId p : {PlayerId{0}, PlayerId{1}}) {
    Event ev;
    ev.code = EVENT_REVEALED_FROM_HAND;
    ev.player = p;
    ev.reason = REASON_EFFECT;
    ev.reason_player = reason_player(d);
    ev.reason_effect = reason_effect(d);
    for (CardIdx c : cards)
      if ((d.location_of(c) & LOCATION_HAND) && d.state.cards.get(c).owner == p) ev.cards.push_back(c);
    if (!ev.cards.empty()) d.raise(ev);
  }
  return 0;
}

// Duel.MoveSigni(c, zone) — 같은 주인의 빈 시그니 존으로 옮긴다(같은 객체). WDK09-015 FAQ 3
int d_MoveSigni(lua_State* L) {
  Duel& d = D(L);
  const CardIdx c = check_card(L, 1);
  const ZoneId z = check_zone(L, 2);
  const Card& card = d.state.cards.get(c);
  const Zone& zone = d.state.zones.get(z);
  const bool ok = (d.location_of(c) & LOCATION_SIGNI) && zone.kind == ZoneKind::Signi && !zone.absent &&
                  zone.cards.empty() && zone.owner == d.state.zones.get(card.zone).owner;
  lua_pushboolean(L, ok && d.move_card(c, z, REASON_EFFECT, reason_player(d), Pos::Top, reason_effect(d)));
  return 1;
}

// Duel.AnnounceNumber(p, lo, hi) → 선언한 숫자
int d_AnnounceNumber(lua_State* L) {
  Duel& d = D(L);
  Request r;
  r.type = ReqType::SelectOption;
  r.player = check_player(L, 1);
  r.hint = HINT_DECLARE;
  const lua_Integer lo = luaL_checkinteger(L, 2), hi = luaL_checkinteger(L, 3);
  luaL_argcheck(L, lo >= 0 && lo <= hi && hi - lo <= 1000, 3, "선언할 수 있는 숫자가 없음");
  for (lua_Integer v = lo; v <= hi; ++v) r.options.push_back(static_cast<uint32_t>(v));
  d.lua_request = std::move(r);
  d.lua_reply = [](lua_State* T, const Response& res) {
    lua_pushinteger(T, res.picks[0]);
    return 1;
  };
  return lua_yield(L, 0);
}

// Duel.SelectOrder(p, g) → p가 정한 순서의 묶음(「置く順番は対戦相手が選ぶ」)
int d_SelectOrder(lua_State* L) {
  Duel& d = D(L);
  const auto cards = cards_arg(L, 2);
  if (cards.size() <= 1) {
    push_group(L, cards);
    return 1;
  }
  Request r;
  r.type = ReqType::SelectCards;
  r.player = check_player(L, 1);
  r.hint = HINT_ORDER;
  r.options.assign(cards.begin(), cards.end());
  r.min = r.max = static_cast<uint32_t>(cards.size());
  d.lua_request = std::move(r);
  d.lua_reply = [](lua_State* T, const Response& res) {
    push_group(T, std::vector<CardIdx>(res.picks.begin(), res.picks.end()));
    return 1;
  };
  return lua_yield(L, 0);
}

int d_GetDeckMovedCount(lua_State* L) {
  lua_pushinteger(L, D(L).players[check_player(L, 1)].opp_to_deck_this_turn);
  return 1;
}

int d_GetCoin(lua_State* L) { lua_pushinteger(L, D(L).players[check_player(L, 1)].coins); return 1; }
int d_AddCoin(lua_State* L) {
  D(L).gain_coin(check_player(L, 1), static_cast<int32_t>(luaL_checkinteger(L, 2)));
  return 0;
}
int d_HasGate(lua_State* L) { lua_pushboolean(L, D(L).state.zones.get(check_zone(L, 1)).gate); return 1; }
int d_PlaceGate(lua_State* L) { lua_pushboolean(L, D(L).place_gate(check_zone(L, 1))); return 1; }
// 【ウィルス】: Duel.HasVirus(z), Duel.PlaceVirus(z) → 놓았나, Duel.RemoveVirus(z) → 치웠나(EVENT_VIRUS_REMOVED)
// Duel.BloodArm(host, card) → card를 장의 시그니 host 밑에 놓아 血晶武装状態로. 같은 이름 시그니만(용어집: 血晶武装)
int d_BloodArm(lua_State* L) {
  Duel& d = D(L);
  const CardIdx host = check_card(L, 1), from = check_card(L, 2);
  const bool ok = (d.location_of(host) & LOCATION_SIGNI) && host != from && (d.type_of(from) & TYPE_SIGNI) &&
                  d.same_name(host, from);
  if (ok) d.blood_arm(host, from, d.chain.empty() ? d.turn_player : d.chain.back().player);
  lua_pushboolean(L, ok);
  return 1;
}
int d_HasVirus(lua_State* L) { lua_pushboolean(L, D(L).state.zones.get(check_zone(L, 1)).virus); return 1; }
int d_PlaceVirus(lua_State* L) { lua_pushboolean(L, D(L).place_virus(check_zone(L, 1))); return 1; }
int d_RemoveVirus(lua_State* L) {
  Duel& d = D(L);
  const PlayerId rp = d.chain.empty() ? d.turn_player : d.chain.back().player;
  lua_pushboolean(L, d.remove_virus(check_zone(L, 1), rp));
  return 1;
}
// Duel.GetSigniZones(p) → 시그니 존 번호 목록(지워진 존 제외)
int d_GetSigniZones(lua_State* L) {
  Duel& d = D(L);
  const auto zones = d.state.zones.zones_of(check_player(L, 1), ZoneKind::Signi);
  lua_createtable(L, static_cast<int>(zones.size()), 0);
  for (size_t i = 0; i < zones.size(); ++i) {
    lua_pushinteger(L, zones[i]);
    lua_rawseti(L, -2, static_cast<lua_Integer>(i + 1));
  }
  return 1;
}
// Duel.SelectZone(sel, {zone, ...}) → 고른 존 번호. 후보가 없으면 nil
int d_SelectZone(lua_State* L) {
  Duel& d = D(L);
  luaL_checktype(L, 2, LUA_TTABLE);
  Request r;
  r.type = ReqType::SelectOption;
  r.player = check_player(L, 1);
  r.hint = HINT_ZONE;
  for (lua_Integer i = 1; lua_rawgeti(L, 2, i) == LUA_TNUMBER; ++i) {
    r.options.push_back(static_cast<uint32_t>(lua_tointeger(L, -1)));
    lua_pop(L, 1);
  }
  lua_pop(L, 1);
  if (r.options.empty()) {
    lua_pushnil(L);
    return 1;
  }
  r.cancelable = !d.chain.empty() && d.chain.back().cancelable;
  d.lua_request = std::move(r);
  d.lua_reply = [](lua_State* T, const Response& res) {
    lua_pushinteger(T, res.picks[0]);
    return 1;
  };
  return lua_yield(L, 0);
}

// Duel.SetSelectCheck(f) — 다음 선택 요청의 추가 검증 f(g) → bool(propose → validate).
// 예: 「それぞれ異なるクラスを持つ３体」
int d_SetSelectCheck(lua_State* L) {
  Duel& d = D(L);
  luaL_checktype(L, 1, LUA_TFUNCTION);
  if (d.select_check_ref) luaL_unref(L, LUA_REGISTRYINDEX, d.select_check_ref);
  lua_pushvalue(L, 1);
  d.select_check_ref = luaL_ref(L, LUA_REGISTRYINDEX);
  return 0;
}

// 후보가 없어 요청을 내지 않을 때도 걸어 둔 검증은 이 선택에서 쓴 것으로 버린다(다음 선택으로 새지 않게)
void drop_select_check(Duel& d) {
  if (d.select_check_ref) luaL_unref(d.lua(), LUA_REGISTRYINDEX, std::exchange(d.select_check_ref, 0));
}

// 걸어 둔 검증 함수를 요청에 붙인다. 요청이 없어질 때 참조를 푼다
void attach_select_check(Duel& d, Request& r) {
  if (!d.select_check_ref) return;
  lua_State* main = d.lua();
  auto ref = std::shared_ptr<int>(new int(std::exchange(d.select_check_ref, 0)), [main](int* p) {
    luaL_unref(main, LUA_REGISTRYINDEX, *p);
    delete p;
  });
  r.check = [&d, ref](const std::vector<uint32_t>& picks, std::string& why) {
    lua_State* L = d.lua();
    lua_rawgeti(L, LUA_REGISTRYINDEX, *ref);
    push_group(L, std::vector<CardIdx>(picks.begin(), picks.end()));
    if (lua_pcall(L, 1, 1, 0) != LUA_OK) {
      d.log(std::string("선택 검증 오류: ") + lua_tostring(L, -1));
      lua_pop(L, 1);
      why = "선택 검증 오류";
      return false;
    }
    const bool ok = lua_toboolean(L, -1);
    lua_pop(L, 1);
    if (!ok) why = "카드 조건에 맞지 않는 조합";
    return ok;
  };
}

// 카드 하나 또는 Group(카드 표)
std::vector<CardIdx> cards_arg(lua_State* L, int i) {
  std::vector<CardIdx> out;
  if (lua_isuserdata(L, i)) {
    out.push_back(check_card(L, i));
  } else if (lua_istable(L, i)) {
    for (lua_Integer k = 1; lua_rawgeti(L, i, k) != LUA_TNIL; ++k) {
      out.push_back(check_card(L, -1));
      lua_pop(L, 1);
    }
    lua_pop(L, 1);
  }
  return out;
}

// 지금 처리 중인 사용·발동의 플레이어와 효과(이동 이유)
PlayerId reason_player(Duel& d) { return d.chain.empty() ? d.turn_player : d.chain.back().player; }
EffectId reason_effect(Duel& d) { return d.chain.empty() ? kNoEffect : d.chain.back().effect; }

int move_to(lua_State* L, ZoneKind kind, Pos pos = Pos::Top) {
  Duel& d = D(L);
  const uint32_t reason = static_cast<uint32_t>(luaL_optinteger(L, 2, REASON_EFFECT));
  int n = 0;
  for (CardIdx c : cards_arg(L, 1)) {
    const Card& card = d.state.cards.get(c);
    if (card.zone == kNoZone) continue;
    if (d.move_card(c, d.state.zones.find(card.owner, kind), reason, reason_player(d), pos, reason_effect(d))) ++n;
  }
  lua_pushinteger(L, n);
  return 1;
}

// Duel.SendToTrash / SendToHand / SendToEna(c 또는 g, reason) → 옮긴 장수. 카드는 주인의 존으로
int d_SendToTrash(lua_State* L) { return move_to(L, ZoneKind::Trash); }
int d_SendToHand(lua_State* L) { return move_to(L, ZoneKind::Hand); }
int d_SendToEna(lua_State* L) { return move_to(L, ZoneKind::Ena); }
// Duel.SendToLrigTrash(c 또는 g, reason) — 루리그 트래시로(키를 코스트로 놓기 등. WDK-F03-09)
int d_SendToLrigTrash(lua_State* L) { return move_to(L, ZoneKind::LrigTrash); }

// Duel.SendToLrigDeck(c 또는 g) — 루리그 덱으로(「アーツ…をルリグデッキに加える」)
int d_SendToLrigDeck(lua_State* L) { return move_to(L, ZoneKind::LrigDeck); }

// Duel.PutUnder(host, c 또는 g) — 장의 카드 아래에 놓는다(순서대로, 마지막이 맨 위)
int d_PutUnder(lua_State* L) {
  Duel& d = D(L);
  const CardIdx host = check_card(L, 1);
  if (!(d.location_of(host) & LOCATION_FIELD)) return 0;
  for (CardIdx c : cards_arg(L, 2))
    if (c != host) d.state.put_under(c, host);
  return 0;
}

// Duel.SendToDeckBottom(g, shuffle) — 「（シャッフルして）デッキの一番下に置く」
int d_SendToDeckBottom(lua_State* L) {
  Duel& d = D(L);
  const auto cards = cards_arg(L, 1);
  const bool shuffle = lua_toboolean(L, 2);
  size_t moved[2] = {0, 0};
  for (CardIdx c : cards) {
    const Card& card = d.state.cards.get(c);
    if (card.zone == kNoZone) continue;
    if (d.move_card(c, d.state.zones.find(card.owner, ZoneKind::MainDeck), REASON_EFFECT, reason_player(d), Pos::Bottom,
                    reason_effect(d)))
      ++moved[card.owner & 1];
  }
  // 고른 순서대로 옮긴 뒤 그 묶음만 섞는다. 옮기는 메시지에서 섞은 순서를 알 수 없게 번호도 새로 준다
  if (shuffle)
    for (PlayerId p : {PlayerId{0}, PlayerId{1}})
      d.state.shuffle_bottom(d.state.zones.find(p, ZoneKind::MainDeck), moved[p]);
  lua_pushinteger(L, static_cast<lua_Integer>(cards.size()));
  return 1;
}

// Duel.Down(c) / Duel.Freeze(c) — 장의 시그니·루리그(용어집: ダウン, 凍結). 凍結은 다운하지 않는다
bool unaffected(Duel& d, CardIdx c) {  // 지금 처리 중인 효과를 받지 않는가
  const Effect* src = d.effects.get(reason_effect(d));
  return src && d.immune(c, *src);
}
int set_flag(lua_State* L, uint32_t flag) {
  Duel& d = D(L);
  for (CardIdx c : cards_arg(L, 1))
    if ((d.location_of(c) & LOCATION_FIELD) && !unaffected(d, c)) {
      const bool was = d.state.cards.get(c).flags & flag;
      d.set_flags(c, d.state.cards.get(c).flags | flag);
      if (!d.chain.empty()) d.note_arts_hit(c, d.chain.back().effect);
      if (flag == CF_FROZEN && !was) {
        Event ev;
        ev.code = EVENT_FROZEN;
        ev.cards = {c};
        ev.player = d.state.cards.get(c).controller;
        ev.reason_player = reason_player(d);
        d.raise(ev);
      }
    }
  return 0;
}
// Duel.Up(c 또는 g) — 업한다. 동결 상태여도(WD13-012 FAQ)
int d_Up(lua_State* L) {
  Duel& d = D(L);
  for (CardIdx c : cards_arg(L, 1))
    if ((d.location_of(c) & LOCATION_FIELD) && !unaffected(d, c)) {
      d.set_flags(c, d.state.cards.get(c).flags & ~CF_DOWN);
      if (!d.chain.empty()) d.note_arts_hit(c, d.chain.back().effect);
    }
  return 0;
}
// Duel.Down(c 또는 g, reason) — 다운한다. 코스트가 아니면(reason에 REASON_COST가 없으면) 다운된 카드마다 EVENT_DOWN
int d_Down(lua_State* L) {
  Duel& d = D(L);
  const uint32_t reason = static_cast<uint32_t>(luaL_optinteger(L, 2, REASON_EFFECT));
  for (CardIdx c : cards_arg(L, 1)) {
    if (!(d.location_of(c) & LOCATION_FIELD) || unaffected(d, c) || (d.state.cards.get(c).flags & CF_DOWN)) continue;
    d.set_flags(c, d.state.cards.get(c).flags | CF_DOWN);
    if (d.phase == PHASE_MAIN) d.down_log_[d.state.cards.get(c).controller].push_back(c);
    if (!(reason & REASON_COST) && !d.chain.empty()) d.note_arts_hit(c, d.chain.back().effect);
    // 코스트로 다운해도 EVENT_DOWN은 난다. 효과에 의한 것인지는 r(REASON_COST가 없는가)로 본다(WX05-040 FAQ 3)
    Event ev;
    ev.code = EVENT_DOWN;
    ev.cards = {c};
    ev.player = d.state.cards.get(c).controller;
    ev.reason = reason;
    ev.reason_player = reason_player(d);
    ev.reason_effect = reason_effect(d);
    d.raise(ev);
  }
  return 0;
}
int d_Freeze(lua_State* L) { return set_flag(L, CF_FROZEN); }

// Duel.GetDecktopGroup(p, n) → 덱 위 n장(맨 위가 첫째)
int d_GetDecktopGroup(lua_State* L) {
  Duel& d = D(L);
  const PlayerId p = check_player(L, 1);
  const auto& deck = d.state.zones.get(d.state.zones.find(p, ZoneKind::MainDeck)).cards;
  const size_t n = std::min<size_t>(deck.size(), check_count(L, 2));
  push_group(L, std::vector<CardIdx>(deck.rbegin(), deck.rbegin() + static_cast<std::ptrdiff_t>(n)));
  return 1;
}

// Duel.ConfirmCards(p, c 또는 g) — 그 플레이어가 본다(「見る」)
int d_ConfirmCards(lua_State* L) {
  D(L).confirm(check_player(L, 1), cards_arg(L, 2));
  return 0;
}

// Duel.GetLifetopGroup(p, n) — 라이프 클로스 위 n장(맨 위가 첫째)
int d_GetLifetopGroup(lua_State* L) {
  Duel& d = D(L);
  const PlayerId p = check_player(L, 1);
  const auto& life = d.state.zones.get(d.state.zones.find(p, ZoneKind::LifeCloth)).cards;
  const size_t n = std::min<size_t>(life.size(), check_count(L, 2));
  push_group(L, std::vector<CardIdx>(life.rbegin(), life.rbegin() + static_cast<std::ptrdiff_t>(n)));
  return 1;
}

// Duel.SendToLife(c 또는 g, reason) — 주인의 라이프 클로스 맨 위에. 밖에서 왔으면 카드마다 EVENT_LIFE_ADDED
int d_SendToLife(lua_State* L) { return move_to(L, ZoneKind::LifeCloth); }

// Duel.Crush(p, n, refill) — 효과로 라이프 클로스 n장 크러시. 크러시한 묶음.
// refill이면 그 카드가 에나로 갈 때 대신 트래시 + 덱 위 1장을 라이프 클로스에(WD06-009)
int d_Crush(lua_State* L) {
  Duel& d = D(L);
  const PlayerId p = check_player(L, 1);
  const uint32_t n = static_cast<uint32_t>(luaL_checkinteger(L, 2));
  const bool refill = lua_toboolean(L, 3);
  const size_t before = d.crushed_list().size();
  const Effect* re = d.effects.get(reason_effect(d));
  const bool on_field = re && re->handler != kNoCard && (d.location_of(re->handler) & LOCATION_FIELD);
  d.crush(p, n, reason_player(d), false, on_field ? re->handler : kNoCard);
  std::vector<CardIdx> out(d.crushed_list().begin() + static_cast<std::ptrdiff_t>(before), d.crushed_list().end());
  // 4번째 인자: 「この効果でクラッシュされたカードのライフバーストは発動しない」(WX05-032)
  if (lua_toboolean(L, 4)) d.no_burst_.insert(d.no_burst_.end(), out.begin(), out.end());
  if (refill)
    for (CardIdx c : out) d.state.cards.get(c).flags |= CF_CRUSH_REFILL;
  push_group(L, out);
  return 1;
}

// 선택 요청. 응답은 lua_reply가 Lua 값으로 바꿔 돌려준다(코루틴 yield)
int request_cards(lua_State* L, PlayerId sel, uint32_t hint, const std::vector<CardIdx>& cands, uint32_t mn,
                  uint32_t mx) {
  Duel& d = D(L);
  if (cands.empty()) {
    drop_select_check(d);
    push_group(L, {});
    return 1;
  }
  Request r;
  r.type = ReqType::SelectCards;
  r.player = sel;
  r.hint = hint;
  r.options.assign(cands.begin(), cands.end());
  r.min = std::min<uint32_t>(mn, static_cast<uint32_t>(cands.size()));
  r.max = std::max(r.min, std::min<uint32_t>(mx, static_cast<uint32_t>(cands.size())));
  r.cancelable = !d.chain.empty() && d.chain.back().cancelable;
  attach_select_check(d, r);
  d.lua_request = std::move(r);
  d.lua_reply = [](lua_State* T, const Response& res) {
    push_group(T, std::vector<CardIdx>(res.picks.begin(), res.picks.end()));
    return 1;
  };
  return lua_yield(L, 0);
}

// Duel.SelectCards(sel, g, min, max) → 고른 카드(대상 아님). 모르는 카드는 그 플레이어에게 뒷면으로 보인다
int d_SelectCards(lua_State* L) {
  return request_cards(L, check_player(L, 1), HINT_SELECT, cards_arg(L, 2),
                       check_u32(L, 3), check_u32(L, 4));
}

// Duel.SelectDiscard(p, min, max, f, ...) → p가 자기 패에서 고른 카드. 버리기는 Duel.SendToTrash(g, REASON_DISCARD…)
int d_SelectDiscard(lua_State* L) {
  Duel& d = D(L);
  const PlayerId p = check_player(L, 1);
  std::vector<CardIdx> cands;
  for (CardIdx c : d.state.zones.get(d.state.zones.find(p, ZoneKind::Hand)).cards)
    if (pass_filter(L, 4, c, 5, lua_gettop(L))) cands.push_back(c);
  return request_cards(L, p, HINT_DISCARD, cands, check_u32(L, 2), check_u32(L, 3));
}

// Duel.SelectOption(p, desc1, desc2, …) → 고른 번호(0부터). 확정 전이면 취소할 수 있다
// desc는 aux.Stringid 번호. 문자열을 넘기면(테스트용) 설명 없음
int d_SelectOption(lua_State* L) {
  Duel& d = D(L);
  Request r;
  r.type = ReqType::SelectOption;
  r.player = check_player(L, 1);
  r.hint = HINT_MODE;
  for (int i = 2; i <= lua_gettop(L); ++i) {
    r.options.push_back(static_cast<uint32_t>(i - 2));
    r.option_descs.push_back(lua_type(L, i) == LUA_TNUMBER ? static_cast<uint32_t>(lua_tointeger(L, i)) : 0);
  }
  if (r.options.empty()) {
    lua_pushinteger(L, 0);
    return 1;
  }
  r.cancelable = !d.chain.empty() && d.chain.back().cancelable;
  d.lua_request = std::move(r);
  d.lua_reply = [](lua_State* T, const Response& res) {
    lua_pushinteger(T, res.picks[0]);
    return 1;
  };
  return lua_yield(L, 0);
}

// Duel.SelectModes(p, min, max, desc, ...) → 고른 번호의 표(0부터, 작은 번호부터). 「以下の４つから２つまで選ぶ」
int d_SelectModes(lua_State* L) {
  Duel& d = D(L);
  Request r;
  r.type = ReqType::SelectOption;
  r.player = check_player(L, 1);
  r.hint = HINT_MODE;
  for (int i = 4; i <= lua_gettop(L); ++i) {
    r.options.push_back(static_cast<uint32_t>(i - 4));
    r.option_descs.push_back(lua_type(L, i) == LUA_TNUMBER ? static_cast<uint32_t>(lua_tointeger(L, i)) : 0);
  }
  if (r.options.empty()) return luaL_error(L, "SelectModes: 선택지가 없음");
  const auto n = static_cast<uint32_t>(r.options.size());
  r.max = std::min(n, static_cast<uint32_t>(check_count(L, 3)));
  r.min = std::min(r.max, static_cast<uint32_t>(check_count(L, 2)));
  r.cancelable = !d.chain.empty() && d.chain.back().cancelable;
  d.lua_request = std::move(r);
  d.lua_reply = [](lua_State* T, const Response& res) {
    std::vector<uint32_t> picks = res.picks;
    std::sort(picks.begin(), picks.end());
    lua_newtable(T);
    for (size_t i = 0; i < picks.size(); ++i) {
      lua_pushinteger(T, picks[i]);
      lua_rawseti(T, -2, static_cast<lua_Integer>(i + 1));
    }
    return 1;
  };
  return lua_yield(L, 0);
}

// Duel.CharmGuard(c) — 처리 중인 효과로 바니시되려는 c를 대신 【チャーム】을 트래시에 놓아 지켰는가(컨트롤러에게 묻는다)
int d_CharmGuard(lua_State* L) {
  Duel& d = D(L);
  const CardIdx c = check_card(L, 1);
  if (!d.can_charm_guard(c, REASON_EFFECT, reason_effect(d))) {
    lua_pushboolean(L, false);
    return 1;
  }
  d.lua_request = d.charm_request(c);
  d.lua_reply = [&d, c](lua_State* T, const Response& res) {
    if (res.picks[0]) d.charm_trash(c);
    lua_pushboolean(T, res.picks[0] != 0);
    return 1;
  };
  return lua_yield(L, 0);
}
// Duel.Charm(c, host) — c를 host의 【チャーム】으로. 이미 붙어 있거나 장을 떠났으면 false
int d_Charm(lua_State* L) { lua_pushboolean(L, D(L).attach_charm(check_card(L, 1), check_card(L, 2))); return 1; }
// c:GetCharm() — 붙어 있는 【チャーム】(없으면 nil)
int c_GetCharm(lua_State* L) { push_card(L, D(L).state.charm_of(check_card(L, 1))); return 1; }
// Duel.SetLrigType(c, LRIG_X) — 이 루리그는 그 루리그 타입을 가진다(게임을 시작할 때 고르는 것)
int d_SetLrigType(lua_State* L) {
  D(L).state.cards.get(check_card(L, 1)).chosen_lrig_types = {check_u32(L, 2)};
  return 0;
}
// Duel.GetPhase() → 지금 페이즈(PHASE_*)
int d_GetPhase(lua_State* L) { lua_pushinteger(L, D(L).phase); return 1; }

// Duel.PutOnField(c, p) → 장에 냈는가. 놓을 시그니 존은 p가 고른다(레벨·리미트를 넘으면 못 낸다. 용어집: リミット)
int d_PutOnField(lua_State* L) {
  Duel& d = D(L);
  const CardIdx c = check_card(L, 1);
  const PlayerId p = lua_isnoneornil(L, 2) ? reason_player(d) : check_player(L, 2);
  const bool no_play = lua_toboolean(L, 3);  // 「それの【出】能力は発動しない」
  const bool down = lua_toboolean(L, 4);     // 「ダウン状態で場に出す」
  const auto zones = d.signi_zones_for(c, p);
  if (zones.empty()) {
    lua_pushboolean(L, false);
    return 1;
  }
  Request r;
  r.type = ReqType::SelectOption;
  r.player = p;
  r.hint = HINT_ZONE;
  r.options.assign(zones.begin(), zones.end());
  d.lua_request = std::move(r);
  d.lua_reply = [&d, c, p, no_play, down](lua_State* T, const Response& res) {
    d.no_play_trigger = no_play;
    d.enter_down_ = down;
    d.move_card(c, static_cast<ZoneId>(res.picks[0]), REASON_EFFECT, p, Pos::Top, reason_effect(d));
    d.enter_down_ = false;
    d.no_play_trigger = false;
    lua_pushboolean(T, true);
    return 1;
  };
  return lua_yield(L, 0);
}

// Duel.PutOnFieldAttacking(c, p) → 「アタックしているシグニとしてダウン状態で場に出す」. 빈 시그니 존 어디든(WDK-F03-15 FAQ 4).
// 【出】을 처리한 뒤 정면과 배틀하거나 데미지를 준다. 「アタックしたとき」는 트리거하지 않는다(WDK-F03-15 FAQ 2)
int d_PutOnFieldAttacking(lua_State* L) {
  Duel& d = D(L);
  const CardIdx c = check_card(L, 1);
  const PlayerId p = lua_isnoneornil(L, 2) ? reason_player(d) : check_player(L, 2);
  const auto zones = d.signi_zones_for(c, p);
  if (zones.empty()) {
    lua_pushboolean(L, false);
    return 1;
  }
  Request r;
  r.type = ReqType::SelectOption;
  r.player = p;
  r.hint = HINT_ZONE;
  r.options.assign(zones.begin(), zones.end());
  d.lua_request = std::move(r);
  d.lua_reply = [&d, c, p](lua_State* T, const Response& res) {
    d.move_card(c, static_cast<ZoneId>(res.picks[0]), REASON_EFFECT, p, Pos::Top, reason_effect(d));
    d.set_flags(c, d.state.cards.get(c).flags | CF_DOWN);
    d.add_extra_attacker(c);
    lua_pushboolean(T, true);
    return 1;
  };
  return lua_yield(L, 0);
}

// 필터 f(c, ...)를 부른다. f가 nil이면 통과
bool pass_filter(lua_State* L, int fidx, CardIdx c, int extra_from, int extra_to) {
  if (lua_isnoneornil(L, fidx)) return true;
  lua_pushvalue(L, fidx);
  push_card(L, c);
  for (int i = extra_from; i <= extra_to; ++i) lua_pushvalue(L, i);
  if (lua_pcall(L, 1 + std::max(0, extra_to - extra_from + 1), 1, 0) != LUA_OK) {
    D(L).log(std::string("필터 오류: ") + lua_tostring(L, -1));
    lua_pop(L, 1);
    return false;
  }
  const bool ok = lua_toboolean(L, -1);
  lua_pop(L, 1);
  return ok;
}

// (f, player, s, o, ex, ...) 형태 인자로 후보를 모은다. first = f의 스택 위치
std::vector<CardIdx> gather(lua_State* L, int first, int ex_idx, int extra_from) {
  Duel& d = D(L);
  const PlayerId p = check_player(L, first + 1);
  const uint32_t self_loc = static_cast<uint32_t>(luaL_checkinteger(L, first + 2));
  const uint32_t opp_loc = static_cast<uint32_t>(luaL_checkinteger(L, first + 3));
  const CardIdx ex = lua_isuserdata(L, ex_idx) ? check_card(L, ex_idx) : kNoCard;
  std::vector<CardIdx> out;
  for (CardIdx c : d.cards_in(p, self_loc, opp_loc)) {
    if (c == ex) continue;
    if (pass_filter(L, first, c, extra_from, lua_gettop(L))) out.push_back(c);
  }
  return out;
}

void push_group(lua_State* L, const std::vector<CardIdx>& cards);

// Duel.IsExistingTarget(f, player, s, o, count, ex, ...)
int d_IsExistingTarget(lua_State* L) {
  const auto n = static_cast<size_t>(luaL_checkinteger(L, 5));
  lua_pushboolean(L, gather(L, 1, 6, 7).size() >= n);
  return 1;
}

// Duel.GetMatchingGroup(f, player, s, o, ex, ...)
int d_GetMatchingGroup(lua_State* L) {
  push_group(L, gather(L, 1, 5, 6));
  return 1;
}

// Duel.SelectTarget(sel_player, f, player, s, o, min, max, ex, ...)
// 고른 카드는 지금 처리 중인 사용·발동의 대상으로 기록된다. 확정 전이면 취소할 수 있다
int d_SelectTarget(lua_State* L) {
  Duel& d = D(L);
  const PlayerId sel = check_player(L, 1);
  const auto cands = gather(L, 2, 8, 9);
  uint32_t mn = static_cast<uint32_t>(luaL_checkinteger(L, 6));
  const uint32_t mx = static_cast<uint32_t>(luaL_checkinteger(L, 7));
  // 「N枚まで」가 아니면 N장을 다 대상으로 할 수 없을 때 1장도 대상으로 할 수 없다(WD22-021 FAQ 1·5, WD20-006 FAQ 3)
  if (cands.empty() || cands.size() < mn || d.chain.empty()) {
    drop_select_check(d);
    push_group(L, {});
    return 1;
  }
  Request r;
  r.type = ReqType::SelectCards;
  r.player = sel;
  r.hint = HINT_TARGET;
  r.options.assign(cands.begin(), cands.end());
  r.min = mn;
  r.max = std::max(mn, mx);
  r.cancelable = d.chain.back().cancelable;
  attach_select_check(d, r);
  d.lua_request = std::move(r);
  d.lua_reply = [&d](lua_State* T, const Response& res) {
    std::vector<CardIdx> picked(res.picks.begin(), res.picks.end());
    for (CardIdx c : picked) d.chain.back().targets.push_back({c, d.state.cards.get(c).oid});
    push_group(T, picked);
    return 1;
  };
  return lua_yield(L, 0);
}

const ActCtx* ctx_of(Duel& d, EffectId e) {
  for (auto it = d.chain.rbegin(); it != d.chain.rend(); ++it)
    if (e == kNoEffect || it->effect == e) return &*it;
  return nullptr;
}

int d_GetFirstTarget(lua_State* L) {
  const ActCtx* ctx = ctx_of(D(L), kNoEffect);
  push_card(L, ctx && !ctx->targets.empty() ? ctx->targets.front().first : kNoCard);
  return 1;
}

int d_GetTargets(lua_State* L) {
  std::vector<CardIdx> out;
  if (const ActCtx* ctx = ctx_of(D(L), kNoEffect))
    for (auto [c, oid] : ctx->targets) out.push_back(c);
  push_group(L, out);
  return 1;
}

// 대상으로 고른 객체가 아직 같은 객체인가(장을 떠났다 오면 새 객체라 false)
int c_IsRelateToEffect(lua_State* L) {
  Duel& d = D(L);
  const CardIdx c = check_card(L, 1);
  const Effect& e = check_effect(L, 2);
  bool ok = false;
  if (const ActCtx* ctx = ctx_of(d, e.id))
    for (auto [t, oid] : ctx->targets) ok |= t == c && d.state.cards.get(c).oid == oid;
  lua_pushboolean(L, ok);
  return 1;
}

// Duel.Banish(c 또는 g) → 바니시한 장수. 시그니 존에 있는 것만(「すべてのシグニをバニッシュする」 WD02-007)
int d_Banish(lua_State* L) {
  Duel& d = D(L);
  const PlayerId rp = d.chain.empty() ? d.turn_player : d.chain.back().player;
  int n = 0;
  // 동시에 바니시하므로 「バニッシュされない」는 처음에 판정한다(WD20-011 FAQ 3)
  std::vector<CardIdx> list = cards_arg(L, 1);
  std::erase_if(list, [&](CardIdx c) { return d.has_keyword(c, EFFECT_CANNOT_BANISH); });
  for (CardIdx c : list)
    if ((d.location_of(c) & LOCATION_SZONE) && d.banish(c, REASON_EFFECT, rp, reason_effect(d))) ++n;
  lua_pushinteger(L, n);
  return 1;
}

// Duel.GetCrushedCount(p) — 이 턴에 크러시된 p의 라이프 클로스 수
int d_GetCrushedCount(lua_State* L) {
  lua_pushinteger(L, D(L).players[check_player(L, 1)].crushed_this_turn);
  return 1;
}
// c:IsLevelBetween(lo, hi) — 레벨이 lo~hi인가(덱·패·트래시의 카드를 볼 때).
// EFFECT_ANY_LEVEL이 걸렸고 지금 처리하는 효과가 그 카드 주인의 것이면 1~4 어느 것으로도 친다(WD21-012)
int c_IsLevelBetween(lua_State* L) {
  Duel& d = D(L);
  const CardIdx c = check_card(L, 1);
  const lua_Integer lo = luaL_checkinteger(L, 2), hi = luaL_checkinteger(L, 3);
  const int32_t lv = d.level_of(c);
  const PlayerId owner = d.state.cards.get(c).owner;
  const bool any = (d.chain.empty() || d.chain.back().player == owner) && d.has_keyword(c, EFFECT_ANY_LEVEL);
  lua_pushboolean(L, (lo <= lv && lv <= hi) || (any && lo <= 4 && hi >= 1));
  return 1;
}
// Duel.Exclude(c 또는 g) — ゲームから除外する
int d_Exclude(lua_State* L) { return move_to(L, ZoneKind::Exclude); }
// c:GetUnderGroup() — 이 카드의 밑에 있는 카드
int c_GetUnderGroup(lua_State* L) {
  const std::vector<CardIdx> under = D(L).state.cards.get(check_card(L, 1)).under;
  push_group(L, under);
  return 1;
}
// Duel.SetTrap(c, p) — c를 p의 시그니 존 하나에 【トラップ】으로 설치한다(존은 p가 고른다). 이미 있던 것은 트래시로
int d_SetTrap(lua_State* L) {
  Duel& d = D(L);
  const CardIdx c = check_card(L, 1);
  Request r;
  r.type = ReqType::SelectOption;
  r.player = lua_isnoneornil(L, 2) ? reason_player(d) : check_player(L, 2);
  r.hint = HINT_ZONE;
  for (ZoneId z : d.state.zones.zones_of(r.player, ZoneKind::Signi))
    if (!d.state.zones.get(z).absent && d.state.zones.get(z).set_card != c) r.options.push_back(z);
  if (r.options.empty() || d.state.cards.get(c).zone == kNoZone) {
    lua_pushboolean(L, false);
    return 1;
  }
  d.lua_request = std::move(r);
  d.lua_reply = [&d, c](lua_State* T, const Response& res) {
    d.set_trap(c, static_cast<ZoneId>(res.picks[0]));
    lua_pushboolean(T, true);
    return 1;
  };
  return lua_yield(L, 0);
}
// Duel.SetSeed(c, p) — c를 p의 시그니 존 하나에 【シード】로 낸다(존은 p가 고른다. 시그니가 있는 존도). 이미 있던 것은 트래시로
int d_SetSeed(lua_State* L) {
  Duel& d = D(L);
  const CardIdx c = check_card(L, 1);
  Request r;
  r.type = ReqType::SelectOption;
  r.player = lua_isnoneornil(L, 2) ? reason_player(d) : check_player(L, 2);
  r.hint = HINT_ZONE;
  for (ZoneId z : d.state.zones.zones_of(r.player, ZoneKind::Signi))
    if (!d.state.zones.get(z).absent && d.state.zones.get(z).seed_card != c) r.options.push_back(z);
  if (r.options.empty() || d.state.cards.get(c).zone == kNoZone) {
    lua_pushboolean(L, false);
    return 1;
  }
  d.lua_request = std::move(r);
  d.lua_reply = [&d, c](lua_State* T, const Response& res) {
    d.set_seed(c, static_cast<ZoneId>(res.picks[0]));
    lua_pushboolean(T, true);
    return 1;
  };
  return lua_yield(L, 0);
}
// Duel.Bloom(c) — 【シード】를 개화한다. 같은 존에 시그니가 있으면 그대로이고 false
int d_Bloom(lua_State* L) { lua_pushboolean(L, D(L).bloom(check_card(L, 1))); return 1; }
// Duel.GrowByEffect(c, p) — 효과로 센터 루리그를 c로 그로우한다(코스트 없이, 같은 레벨도). 못 하면 false
int d_GrowByEffect(lua_State* L) {
  Duel& d = D(L);
  const PlayerId p = lua_isnoneornil(L, 2) ? reason_player(d) : check_player(L, 2);
  lua_pushboolean(L, d.grow_by_effect(p, check_card(L, 1)));
  return 1;
}
// Duel.UseFree(c, p) — c를 p가 코스트를 내지 않고 사용한다(아츠·스펠. 상대 패·덱의 스펠도. 한정 조건은 보지 않는다). 쓰면 true
int d_UseFree(lua_State* L) {
  Duel& d = D(L);
  const CardIdx c = check_card(L, 1);
  const PlayerId p = lua_isnoneornil(L, 2) ? reason_player(d) : check_player(L, 2);
  const EffectId eid = d.activate_effect(c);
  if (eid == kNoEffect) {
    lua_pushboolean(L, false);
    return 1;
  }
  d.lua_task = [&d, c, p, eid]() -> Task<bool> {
    d.free_use_ = true;
    const bool ok = co_await d.use_card(Action{ActionKind::UseCard, c, kNoZone, eid, p});
    d.free_use_ = false;
    co_return ok;
  };
  return lua_yield(L, 0);
}
// Duel.SwapSigni(a, b) — 같은 주인의 두 시그니의 자리를 바꾼다(같은 객체). b 자리가 비었으면 그 존 번호를 준다
int d_SwapSigni(lua_State* L) {
  Duel& d = D(L);
  const CardIdx a = check_card(L, 1);
  const ZoneId za = d.state.cards.get(a).zone;
  ZoneId zb;
  CardIdx b = kNoCard;
  if (lua_isinteger(L, 2) && !lua_isuserdata(L, 2)) zb = check_zone(L, 2);
  else {
    b = check_card(L, 2);
    zb = d.state.cards.get(b).zone;
  }
  const bool ok = (d.location_of(a) & LOCATION_SIGNI) && za != zb && d.state.zones.get(zb).kind == ZoneKind::Signi &&
                  d.state.zones.get(zb).owner == d.state.zones.get(za).owner && !d.state.zones.get(zb).absent &&
                  (b == kNoCard ? d.occupant(zb) == kNoCard : d.occupant(zb) == b);
  if (!ok) {
    lua_pushboolean(L, false);
    return 1;
  }
  // 빈 자리를 거쳐 옮긴다: a → (b 자리), b → (a 자리). 장 안 이동이라 같은 객체
  if (b == kNoCard) {
    lua_pushboolean(L, d.move_card(a, zb, REASON_EFFECT, reason_player(d), Pos::Top, reason_effect(d)));
    return 1;
  }
  d.state.swap_field(a, b);
  lua_pushboolean(L, true);
  return 1;
}
// Duel.IsPlayerAffected(p, code) — 플레이어에 그 효과가 걸려 있는가
int d_IsPlayerAffected(lua_State* L) {
  lua_pushboolean(L, D(L).player_affected(check_player(L, 1), check_u32(L, 2)));
  return 1;
}
// Duel.GetPaidEna() — 지금 사용 중인 카드의 코스트로 낸 에나(WX04-063)
int d_GetPaidEna(lua_State* L) {
  Duel& d = D(L);
  push_group(L, d.chain.empty() ? std::vector<CardIdx>{} : d.chain.back().paid);
  return 1;
}
// Duel.Damage(p) — 「対戦相手にダメージを与える」(라이프 1장 크러시, 없으면 승리)
int d_Damage(lua_State* L) {
  Duel& d = D(L);
  const PlayerId p = check_player(L, 1), by = reason_player(d);
  d.lua_task = [&d, p, by]() { return d.damage_by_effect(p, by); };
  return lua_yield(L, 0);
}
// Duel.GetDownLog(p) — 이 턴 메인 페이즈에 다운 상태가 된 p의 카드(여러 번이면 여러 번, 표)
int d_GetDownLog(lua_State* L) {
  Duel& d = D(L);
  const auto& log = d.down_log_[check_player(L, 1)];
  lua_createtable(L, static_cast<int>(log.size()), 0);
  for (size_t i = 0; i < log.size(); ++i) {
    push_card(L, log[i]);
    lua_rawseti(L, -2, static_cast<lua_Integer>(i + 1));
  }
  return 1;
}
// c:GetResonaMaterials() — 이 레조나가 마지막으로 출현 조건으로 트래시에 둔 카드의 cid 표
int c_GetResonaMaterials(lua_State* L) {
  Duel& d = D(L);
  const auto it = d.resona_mats_.find(check_card(L, 1));
  lua_newtable(L);
  if (it != d.resona_mats_.end())
    for (size_t i = 0; i < it->second.size(); ++i) {
      lua_pushinteger(L, it->second[i]);
      lua_rawseti(L, -2, static_cast<lua_Integer>(i + 1));
    }
  return 1;
}
// Duel.IsExtraTurn() — 지금 턴이 효과로 추가된 턴인가
int d_IsExtraTurn(lua_State* L) { lua_pushboolean(L, D(L).extra_turn_now_); return 1; }
// Duel.ExtraTurn(p) — 「このターンの次に、追加の１ターンを得る」
int d_ExtraTurn(lua_State* L) { ++D(L).players[check_player(L, 1)].extra_turns; return 0; }
// Duel.EndTurn() — 「このターンを終了する」(지금 효과를 처리한 뒤 룰 처리로)
int d_EndTurn(lua_State* L) { D(L).request_end_turn(); return 0; }
// c:HasAbility() — 지금 능력을 하나라도 가졌는가(「能力を持たないシグニ」)
int c_HasAbility(lua_State* L) {
  lua_pushboolean(L, D(L).has_ability(check_card(L, 1)));
  return 1;
}
// Duel.OpenTrap(c) — 【トラップ】을 표면으로 하고 《トラップアイコン》을 발동시킨다(지금 효과를 처리한 뒤에)
int d_OpenTrap(lua_State* L) { D(L).open_trap(check_card(L, 1)); return 0; }
// Duel.GetTrap(zone) — 그 존의 【トラップ】(없으면 nil)
int d_GetTrap(lua_State* L) { push_card(L, D(L).state.zones.get(check_zone(L, 1)).set_card); return 1; }
int c_HasTrapIcon(lua_State* L) { lua_pushboolean(L, D(L).trap_ability(check_card(L, 1)) != kNoEffect); return 1; }
// Duel.CanPutAll(g, p) — 이 시그니들을 한꺼번에 장에 낼 수 있는가
int d_CanPutAll(lua_State* L) { lua_pushboolean(L, D(L).can_put_all(cards_arg(L, 1), check_player(L, 2))); return 1; }
// Duel.GetAttackDrawCount(p) — 이 턴의 어택 페이즈에 p가 뽑은 장수
int d_GetAttackDrawCount(lua_State* L) {
  lua_pushinteger(L, D(L).players[check_player(L, 1)].drawn_attack_this_turn);
  return 1;
}
// Duel.GetCutinSpell() — 스펠 컷인 중이면 그 스펠(없으면 nil) / Duel.NegateSpell() — 그 효과를 打ち消す
ActCtx* cutin_spell(Duel& d) {
  for (size_t i = d.chain.size(); i-- > 1;)
    if (d.chain[i - 1].card != kNoCard && (d.data(d.state.cards.get(d.chain[i - 1].card).cid).type & TYPE_SPELL)) return &d.chain[i - 1];
  return nullptr;
}
int d_GetCutinSpell(lua_State* L) {
  const ActCtx* s = cutin_spell(D(L));
  push_card(L, s ? s->card : kNoCard);
  return 1;
}
int d_NegateSpell(lua_State* L) {
  ActCtx* s = cutin_spell(D(L));
  // 「対戦相手の効果によって打ち消されない」(WX04-008)
  if (s && s->no_negate && reason_player(D(L)) != s->player) s = nullptr;
  if (s) s->negated = true;
  if (s && lua_toboolean(L, 1)) s->bounce = reason_effect(D(L));  // 「それをトラッシュから手札に戻す」
  if (s && lua_toboolean(L, 2)) s->recast = reason_player(D(L));  // 트래시에 놓인 뒤 그 플레이어가 공짜로 써도 된다
  lua_pushboolean(L, s != nullptr);
  return 1;
}
// c:GetCostTotal() — 카드에 적힌 에나 코스트의 합계
int c_GetCostTotal(lua_State* L) {
  Duel& d = D(L);
  const std::string& cost = d.data(d.state.cards.get(check_card(L, 1)).cid).cost_ena;
  lua_pushinteger(L, std::count(cost.begin(), cost.end(), '{'));
  return 1;
}
// Duel.AnnounceCard(p) — 카드명 선언 → cid. c:IsCardName(cid) — 그 이름인가(동명 취급 포함)
int d_AnnounceCard(lua_State* L) {
  Duel& d = D(L);
  Request r;
  r.type = ReqType::SelectOption;
  r.player = check_player(L, 1);
  r.hint = HINT_ANNOUNCE;
  for (CardIdx i = 0; i < static_cast<CardIdx>(d.state.cards.size()); ++i) {
    const Card& c = d.state.cards.get(i);
    if (c.owner == r.player && std::find(r.options.begin(), r.options.end(), c.cid) == r.options.end()) r.options.push_back(c.cid);
  }
  r.accept = [&d](uint32_t cid) { return d.has_data(cid); };
  d.lua_request = std::move(r);
  d.lua_reply = [](lua_State* T, const Response& res) {
    lua_pushinteger(T, res.picks[0]);
    return 1;
  };
  return lua_yield(L, 0);
}
int c_IsCardName(lua_State* L) {
  Duel& d = D(L);
  auto key = [&](Cid cid) { const Cid a = d.data(cid).alias; return a ? a : cid; };
  lua_pushboolean(L, key(d.text_of(check_card(L, 1))) == key(check_u32(L, 2)));
  return 1;
}
// Duel.GetLeaveGuards(c) → 상대의 효과로 장을 떠나려는 c를 대신할 수 있는 효과의 표(EFFECT_LEAVE_GUARD)
int d_GetLeaveGuards(lua_State* L) {
  Duel& d = D(L);
  const CardIdx c = check_card(L, 1);
  lua_newtable(L);
  if (!d.effects.seen(EFFECT_LEAVE_GUARD) || d.chain.empty() || !(d.location_of(c) & LOCATION_SZONE)) return 1;
  if (d.chain.back().player == d.state.cards.get(c).controller) return 1;
  lua_Integer n = 0;
  for (EffectId id : d.leave_guards(c)) {
    push_effect(L, id);
    lua_rawseti(L, -2, ++n);
  }
  return 1;
}
// Duel.Ride(c) — c의 컨트롤러의 센터 루리그가 턴 종료 시까지 c에 탄다(갈아탄다) / c:IsDrive() — ドライブ状態
int d_Ride(lua_State* L) {
  Duel& d = D(L);
  const CardIdx c = check_card(L, 1);
  d.ride_on(d.state.cards.get(c).controller, c);
  return 0;
}
// c:HasAttacked() — 이 턴에 어택했는가
int c_HasAttacked(lua_State* L) { lua_pushboolean(L, D(L).attacked_this_turn(check_card(L, 1))); return 1; }
int c_IsDrive(lua_State* L) { lua_pushboolean(L, D(L).is_drive(check_card(L, 1))); return 1; }
// Duel.PutKey(c, p) — 효과로 키를 장에(코스트 없이). 있던 키는 루리그 트래시로
int d_PutKey(lua_State* L) {
  Duel& d = D(L);
  const PlayerId p = lua_isnoneornil(L, 2) ? reason_player(d) : check_player(L, 2);
  lua_pushboolean(L, d.put_key(p, check_card(L, 1), REASON_EFFECT, reason_effect(d)));
  return 1;
}
// Duel.NegateAttack() — 지금 어택을 무효로 한다(배틀·데미지·가드가 없다)
int d_NegateAttack(lua_State* L) {
  Duel& d = D(L);
  if (!d.attack_negated) {
    d.attack_negated = true;
    Event ev;
    ev.code = EVENT_NEGATED;
    ev.player = d.turn_player;
    ev.reason_player = reason_player(d);
    d.raise(ev);
  }
  return 0;
}
// Duel.GetDeckbottomGroup(p, n) — 덱 아래 n장(맨 아래가 첫째)
int d_GetDeckbottomGroup(lua_State* L) {
  Duel& d = D(L);
  const auto& deck = d.state.zones.get(d.state.zones.find(check_player(L, 1), ZoneKind::MainDeck)).cards;
  const size_t n = std::min(deck.size(), check_count(L, 2));
  push_group(L, std::vector<CardIdx>(deck.begin(), deck.begin() + static_cast<std::ptrdiff_t>(n)));
  return 1;
}
// Duel.SkipTurn(p) — 다음 p의 턴을 건너뛴다
int d_SkipTurn(lua_State* L) {
  ++D(L).players[check_player(L, 1)].skip_turns;
  return 0;
}
int e_SetTiming(lua_State* L) { check_effect(L, 1).timing = check_u32(L, 2); return 0; }
int e_SetCoinCost(lua_State* L) { check_effect(L, 1).coin_cost = check_u32(L, 2); return 0; }
int e_SetExceedCost(lua_State* L) { check_effect(L, 1).exceed = check_u32(L, 2); return 0; }
int e_SetEncore(lua_State* L) { check_effect(L, 1).encore = check_u32(L, 2); return 0; }
int e_SetEncoreCost(lua_State* L) { check_effect(L, 1).encore_cost = luaL_checkstring(L, 2); return 0; }
int e_SetBet(lua_State* L) { check_effect(L, 1).bet = check_u32(L, 2); return 0; }
// e:SetBetCost("{G}") — ベット하면 사용 코스트가 이 에나 코스트로 바뀐다(WDK08-Y06)
int e_SetBetCost(lua_State* L) {
  Effect& e = check_effect(L, 1);
  e.has_bet_cost = true;
  e.bet_cost = luaL_checkstring(L, 2);
  return 0;
}

// Duel.IsBet() → 처리 중인 아츠를 ベット해서 썼는가(용어집: ベット)
int d_IsBet(lua_State* L) {
  Duel& d = D(L);
  lua_pushboolean(L, !d.chain.empty() && d.chain.back().bet);
  return 1;
}

// 조건 함수에서는 지금 모으는 사건, 대상·처리에서는 트리거한 사건의 것
CardIdx event_source(Duel& d, CardIdx now) {
  return now != kNoCard || d.collecting || d.chain.empty() ? now : d.chain.back().event_source;
}
// Duel.GetUseCost() — SetDeclare 안에서: 지금 쓰는 카드의 사용 코스트(다른 카드의 감소까지 뺀 것)
int d_GetUseCost(lua_State* L) {
  Duel& d = D(L);
  lua_pushstring(L, d.chain.empty() ? "" : d.chain.back().base_cost.c_str());
  return 1;
}
// Duel.ReduceCost(cost, "{R}{C}", n) → 기호를 n번 뺀 코스트. 없는 기호는 빼지 않는다
int d_ReduceCost(lua_State* L) {
  std::string cost = luaL_checkstring(L, 1);
  const std::string sym = luaL_checkstring(L, 2);
  for (lua_Integer n = luaL_optinteger(L, 3, 1); n > 0; --n) cost = reduce_ena_cost(cost, sym);
  lua_pushstring(L, cost.c_str());
  return 1;
}
// Duel.GetRiser() — EVENT_RISEN의 대상·처리에서: 위에 놓인 시그니
int d_GetRiser(lua_State* L) { push_card(L, event_source(D(L), kNoCard)); return 1; }
// Duel.GetBanisher() — EVENT_BANISHED의 조건 함수에서: 바니시한 시그니(배틀·시그니의 능력). 없으면 nil
int d_GetBanisher(lua_State* L) { push_card(L, event_source(D(L), D(L).banisher)); return 1; }

// Duel.GetCrusher() — EVENT_CRUSHED의 조건 함수에서: 크러시한 시그니·루리그. 없으면 nil
int d_GetCrusher(lua_State* L) { push_card(L, event_source(D(L), D(L).crusher)); return 1; }
// Duel.GetBattleOpponent() — EVENT_BATTLE의 조건·처리에서: 배틀한 상대 시그니
int d_GetBattleOpponent(lua_State* L) { push_card(L, event_source(D(L), D(L).battler)); return 1; }
// c:HasTiming(TIMING_MAIN) — 아츠의 사용 타이밍에 그것이 있는가
int c_HasTiming(lua_State* L) {
  Duel& d = D(L);
  lua_pushboolean(L, (d.data(d.text_of(check_card(L, 1))).timing & check_u32(L, 2)) != 0);
  return 1;
}

// Duel.GetDiscardedCount(p) — 이 턴에 p가 버린 패의 장수(룰·코스트·출현 조건 포함)
int d_GetDiscardedCount(lua_State* L) {
  lua_pushinteger(L, D(L).players[check_player(L, 1)].discarded_this_turn);
  return 1;
}
// Duel.GetArtsUsedCount(p) — 이 턴에 p가 쓴 아츠 수
int d_GetArtsUsedCount(lua_State* L) {
  lua_pushinteger(L, D(L).players[check_player(L, 1)].arts_used_this_turn);
  return 1;
}
int d_GetRefreshCount(lua_State* L) {
  lua_pushinteger(L, D(L).players[check_player(L, 1)].refreshes_this_turn);
  return 1;
}
int d_GetSpellsUsedCount(lua_State* L) {
  lua_pushinteger(L, D(L).players[check_player(L, 1)].spells_used_this_turn);
  return 1;
}
// Duel.SetUseCost("{R}{R}{C}") — SetDeclare 안에서: 지금 쓰는 카드의 사용 코스트를 이것으로
int d_SetUseCost(lua_State* L) {
  Duel& d = D(L);
  if (d.chain.empty()) return luaL_error(L, "SetUseCost: 사용 선언 중이 아님");
  d.chain.back().use_cost = luaL_checkstring(L, 1);
  return 0;
}

// Duel.CanPayEna(p, "{W}") → 지금 그 에나 코스트를 낼 수 있는가
int d_CanPayEna(lua_State* L) {
  Duel& d = D(L);
  const PlayerId p = check_player(L, 1);
  lua_pushboolean(L, ena_can_pay(parse_ena_cost(luaL_checkstring(L, 2)), d.ena_colors(p)));
  return 1;
}

// Duel.SelectEnaCost(p, "{W}") → p가 낼 에나 카드(색이 맞게). 「《白》を支払ってもよい」는 SelectYesNo 뒤에 쓰고,
// 고른 카드는 Duel.SendToTrash(g, REASON_COST)로 낸다
int d_SelectEnaCost(lua_State* L) {
  Duel& d = D(L);
  const PlayerId p = check_player(L, 1);
  const auto sym = parse_ena_cost(luaL_checkstring(L, 2));
  const auto& ena = d.state.zones.get(d.state.zones.find(p, ZoneKind::Ena)).cards;
  if (sym.empty() || ena.size() < sym.size()) {
    push_group(L, {});
    return 1;
  }
  Request r;
  r.type = ReqType::SelectCards;
  r.player = p;
  r.hint = HINT_PAY_ENA;
  r.options.assign(ena.begin(), ena.end());
  r.min = r.max = static_cast<uint32_t>(sym.size());
  r.check = [&d, sym](const std::vector<uint32_t>& picks, std::string& why) {
    std::vector<uint8_t> colors;
    for (uint32_t c : picks) colors.push_back(d.pay_color(c));
    if (ena_pays(sym, colors)) return true;
    why = "고른 에나가 비용 색과 맞지 않음";
    return false;
  };
  d.lua_request = std::move(r);
  d.lua_reply = [](lua_State* T, const Response& res) {
    push_group(T, std::vector<CardIdx>(res.picks.begin(), res.picks.end()));
    return 1;
  };
  return lua_yield(L, 0);
}
int e_SetLabelObject(lua_State* L) { check_effect(L, 1).label_effect = check_effect(L, 2).id; return 0; }
int e_GetLabelObject(lua_State* L) { push_effect(L, check_effect(L, 1).label_effect); return 1; }
int c_IsLifeBurst(lua_State* L) { lua_pushboolean(L, D(L).has_burst(check_card(L, 1))); return 1; }
int c_IsCanAttack(lua_State* L) { lua_pushboolean(L, D(L).can_attack(check_card(L, 1))); return 1; }
int c_GetZone(lua_State* L) {
  const Card& c = D(L).state.cards.get(check_card(L, 1));
  if (c.zone == kNoZone || c.host != kNoCard)
    lua_pushnil(L);
  else
    lua_pushinteger(L, c.zone);
  return 1;
}
// c:GetPreviousZone() — 직전에 있던 존 번호(없으면 nil)
int c_GetPreviousZone(lua_State* L) {
  const ZoneId z = D(L).state.cards.get(check_card(L, 1)).prev_zone;
  if (z == kNoZone) lua_pushnil(L); else lua_pushinteger(L, z);
  return 1;
}
// Duel.GetFrontZone(zone) — 정면 존 번호(없으면 nil)
int d_GetFrontZone(lua_State* L) {
  const ZoneId f = D(L).state.zones.front(check_zone(L, 1));
  if (f == kNoZone) lua_pushnil(L); else lua_pushinteger(L, f);
  return 1;
}
int c_HasAcceIcon(lua_State* L) { lua_pushboolean(L, D(L).has_keyword(check_card(L, 1), EFFECT_ACCE)); return 1; }
// c:IsAcce() — アクセされている / c:IsPreviousAcce() — 장을 떠날 때 アクセされていた / c:GetAcceHost() — 【アクセ】로 붙어 있는 시그니(없으면 nil)
int c_IsAcce(lua_State* L) { lua_pushboolean(L, D(L).state.has_acce(check_card(L, 1))); return 1; }
int c_IsPreviousAcce(lua_State* L) { lua_pushboolean(L, D(L).state.cards.get(check_card(L, 1)).prev_acce); return 1; }
int c_GetAcceHost(lua_State* L) {
  const Card& c = D(L).state.cards.get(check_card(L, 1));
  push_card(L, c.acce ? c.host : kNoCard);
  return 1;
}
// Duel.Acce(c, host) — c를 host의 【アクセ】로. 이미 붙어 있거나 장을 떠났으면 false
int d_Acce(lua_State* L) { lua_pushboolean(L, D(L).attach_acce(check_card(L, 1), check_card(L, 2))); return 1; }
int c_HasRiseIcon(lua_State* L) { lua_pushboolean(L, D(L).has_rise(check_card(L, 1))); return 1; }
// c:IsInZone("signi_center") — 그 이름의 존에 있는가(「中央のシグニゾーンにある」)
int c_IsInZone(lua_State* L) {
  const Card& c = D(L).state.cards.get(check_card(L, 1));
  lua_pushboolean(L, c.zone != kNoZone && c.host == kNoCard && D(L).state.zones.get(c.zone).name == luaL_checkstring(L, 2));
  return 1;
}
// c:GetFrontCard() — 정면 존의 시그니(없으면 nil). 존 레지스트리의 정면 링크를 쓴다
int c_GetFrontCard(lua_State* L) {
  Duel& d = D(L);
  const Card& c = d.state.cards.get(check_card(L, 1));
  const ZoneId f = c.zone == kNoZone || c.host != kNoCard ? kNoZone : d.state.zones.front(c.zone);
  push_card(L, f == kNoZone ? kNoCard : d.occupant(f));
  return 1;
}
// e:SetCountLimit(n, game) — 《ターン1回》(n=1), game이면 《ゲーム1回》
int e_SetCountLimit(lua_State* L) {
  Effect& e = check_effect(L, 1);
  e.count_limit = check_u32(L, 2);
  e.count_game = lua_toboolean(L, 3);
  return 0;
}
int e_SetEnaCost(lua_State* L) { check_effect(L, 1).ena_cost = luaL_checkstring(L, 2); return 0; }
int e_SetCost(lua_State* L) {
  Effect& e = check_effect(L, 1);
  e.cost_ref = ref_function(L, 2, e.cost_ref);
  return 0;
}

// Duel.GetTurnCount() — 지금이 게임의 몇 번째 턴인가(1부터)
int d_GetTurnCount(lua_State* L) { lua_pushinteger(L, D(L).turn_count); return 1; }
int d_GetTurnPlayer(lua_State* L) {
  lua_pushinteger(L, D(L).turn_player);
  return 1;
}

// 선택 요청: 요청을 걸어 두고 코루틴을 멈춘다. 응답은 lua_reply가 Lua 값으로 바꿔 돌려준다.
int d_SelectYesNo(lua_State* L) {
  Duel& d = D(L);
  Request r;
  r.type = ReqType::YesNo;
  r.player = check_player(L, 1);
  r.hint = HINT_SCRIPT;
  r.options = {0, 1};
  // SelectYesNo(p, card, desc): 처리 중인 효과가 아닌 카드의 것을 물을 때
  if (!lua_isnoneornil(L, 2)) r.source = check_card(L, 2);
  if (!lua_isnoneornil(L, 3)) r.source_desc = check_u32(L, 3);
  d.lua_request = std::move(r);
  d.lua_reply = [](lua_State* T, const Response& res) {
    lua_pushboolean(T, res.picks[0] == 1);
    return 1;
  };
  return lua_yield(L, 0);
}

int d_RegisterEffect(lua_State* L) {
  Effect& e = check_effect(L, 1);
  D(L).register_player_effect(e.id, check_player(L, 2));
  return 0;
}

void set_funcs(lua_State* L, const char* global, const luaL_Reg* funcs) {
  lua_newtable(L);
  luaL_setfuncs(L, funcs, 0);
  lua_setglobal(L, global);
}

void make_meta(lua_State* L, const char* meta, const char* methods) {
  luaL_newmetatable(L, meta);
  lua_getglobal(L, methods);
  lua_setfield(L, -2, "__index");
  lua_pop(L, 1);
}

// Group(유프로식 카드 묶음)과 트리거 처리용 래퍼. 단순한 것은 Lua로 둔다.
const char* kPrelude = R"(
Group = {}
Group.__index = Group
function Group.CreateGroup(...)
  local g = setmetatable({}, Group)
  for _, c in ipairs({...}) do g[#g + 1] = c end
  return g
end
function Group.GetCount(g) return #g end
function Group.GetFirst(g) return g[1] end
function Group.IsContains(g, c)
  for _, x in ipairs(g) do if x == c then return true end end
  return false
end
function Group.AddCard(g, c)
  if not g:IsContains(c) then g[#g + 1] = c end
  return g
end
function Group.Filter(g, f, ex, ...)
  local out = Group.CreateGroup()
  for _, x in ipairs(g) do
    if x ~= ex and f(x, ...) then out[#out + 1] = x end
  end
  return out
end
function Group.Iter(g)
  local i = 0
  return function() i = i + 1; return g[i] end
end

-- 트리거 처리: 선언(모드) → 대상(chk=1) → 처리. 코루틴 안에서 돌아 선택 요청 때 멈출 수 있다
function __wx_resolve(dc, tg, op, ...)
  local a = table.pack(...)
  if dc then dc(table.unpack(a, 1, a.n)) end
  if tg then
    a[a.n + 1] = 1
    tg(table.unpack(a, 1, a.n + 1))
  end
  if op then op(table.unpack(a, 1, a.n)) end
end
)";

struct Const {
  const char* name;
  lua_Integer value;
};

#define WX_C(x) {#x, static_cast<lua_Integer>(x)}
const Const kConstants[] = {
    WX_C(EFFECT_TYPE_SINGLE), WX_C(EFFECT_TYPE_FIELD), WX_C(EFFECT_TYPE_ACTIVATE),
    WX_C(EFFECT_TYPE_IGNITION), WX_C(EFFECT_TYPE_TRIGGER_O), WX_C(EFFECT_TYPE_TRIGGER_F),
    WX_C(EFFECT_TYPE_LIFEBURST), WX_C(EFFECT_TYPE_TRAP), WX_C(LOCATION_TRAP), WX_C(EVENT_TRAP), WX_C(ABILITY_TRAP), WX_C(EFFECT_DOUBLE_BURST), WX_C(EFFECT_LEAVE_GUARD),
    WX_C(EFFECT_COPY), WX_C(EFFECT_CHANGE_COLOR), WX_C(EFFECT_ADD_COLOR), WX_C(EFFECT_ADD_CLASS),
    WX_C(EFFECT_CHANGE_LEVEL), WX_C(EFFECT_UPDATE_LEVEL), WX_C(EFFECT_UPDATE_LIMIT),
    WX_C(EFFECT_LOSE_ABILITY), WX_C(EFFECT_SET_POWER), WX_C(EFFECT_UPDATE_POWER), WX_C(EFFECT_MULTI_ENA),
    WX_C(EFFECT_ACCE), WX_C(EVENT_ARTS_HIT), WX_C(EFFECT_LTRASH_IGNITION), WX_C(EFFECT_IGNORE_LIMIT), WX_C(EFFECT_NO_HAND_ADD), WX_C(EFFECT_NO_OPP_POWER), WX_C(EFFECT_NEGATE_NEXT_ATTACK), WX_C(EFFECT_REVEAL_PLUS), WX_C(EFFECT_CANNOT_GROW), WX_C(EFFECT_RESONA_TO_LTRASH), WX_C(EFFECT_INVERT_PLUS), WX_C(EFFECT_KILL_TO_TRASH), WX_C(EFFECT_SKIP_SIGNI_ATTACK), WX_C(EFFECT_SKIP_LRIG_ATTACK), WX_C(EVENT_FROZEN), WX_C(EFFECT_NO_DAMAGE), WX_C(EFFECT_ZONE_LOCK), WX_C(EFFECT_ADD_PAY_COLOR), WX_C(EFFECT_NO_SELF_TRASH), WX_C(REASON_LANCER), WX_C(EVENT_DOWN), WX_C(EVENT_GUARDED), WX_C(EVENT_NEGATED), WX_C(EFFECT_SIGNI_LIMIT), WX_C(EFFECT_DRAW_PHASE_COUNT), WX_C(EFFECT_ZERO_TO_TRASH), WX_C(EFFECT_DOUBLE_MINUS), WX_C(EFFECT_NO_REMOVE), WX_C(EFFECT_NO_NEGATE), WX_C(EVENT_BATTLE), WX_C(EFFECT_GROW_COST_ZERO), WX_C(EFFECT_POWER_WATCH), WX_C(EVENT_POWER_REACHED), WX_C(EFFECT_SKIP_GROW), WX_C(RESET_MY_TURN), WX_C(REASON_GUARD), WX_C(LOCATION_SEED), WX_C(EVENT_BLOOM), WX_C(EVENT_ACCE), WX_C(EFFECT_BANISH_IMMUNE), WX_C(EFFECT_CANNOT_USE), WX_C(EFFECT_GUARD_EXTRA), WX_C(EVENT_USE_CARD), WX_C(EVENT_DRIVE), WX_C(EFFECT_CHARM_GUARD), WX_C(EFFECT_LEAVE_EXCLUDE), WX_C(EVENT_DRAW_ONE), WX_C(EVENT_OPEN), WX_C(EFFECT_ANY_LEVEL), WX_C(EFFECT_TRIPLE_CRUSH), WX_C(REASON_RESONA), WX_C(REASON_BANISH), WX_C(EFFECT_ATTACK_NEIGHBOR), WX_C(LOCATION_ACCE), WX_C(EFFECT_LANCER), WX_C(EFFECT_S_LANCER), WX_C(EFFECT_DOUBLE_CRUSH), WX_C(EFFECT_ASSASSIN), WX_C(EFFECT_GRANT),
    WX_C(EFFECT_CANNOT_ATTACK), WX_C(EFFECT_UPDATE_HAND_LIMIT), WX_C(EFFECT_CANNOT_GUARD), WX_C(EVENT_MOVED_TO_DECK), WX_C(EVENT_VIRUS_REMOVED), WX_C(EVENT_BLOOD_ARMED), WX_C(EVENT_REVEALED_FROM_HAND), WX_C(EFFECT_CANNOT_BANISH), WX_C(EFFECT_PREVENT_DAMAGE), WX_C(EFFECT_CANNOT_CRUSH), WX_C(EFFECT_SET_BASE_POWER), WX_C(EVENT_LIFE_ADDED), WX_C(EVENT_LIFEBURST), WX_C(EFFECT_MUST_ATTACK), WX_C(EFFECT_MUST_FRONT), WX_C(EFFECT_FREE_IGNITION), WX_C(EFFECT_RESONA), WX_C(EFFECT_CROSS), WX_C(CROSS_LEFT), WX_C(CROSS_RIGHT), WX_C(EVENT_HEAVEN), WX_C(EFFECT_IMMUNE), WX_C(EFFECT_BANISH_TO_TRASH), WX_C(EFFECT_SKIP_ENA), WX_C(EFFECT_ATTACK_ONCE), WX_C(EFFECT_GUARD_ICON), WX_C(EFFECT_GROW_PROC), WX_C(CRUSH_NON_DAMAGE), WX_C(EFFECT_NO_GUARD), WX_C(EFFECT_GRANT_LIFEBURST), WX_C(EFFECT_DISABLE_ABILITY), WX_C(EFFECT_CANNOT_USE_ARTS), WX_C(EFFECT_REDUCE_COST), WX_C(EFFECT_RISE), WX_C(EVENT_RISEN), WX_C(EFFECT_CANNOT_PLAY), WX_C(EFFECT_FLAG_NEXT_USE),
    WX_C(ABILITY_AUTO), WX_C(ABILITY_ON_PLAY), WX_C(ABILITY_IGNITION), WX_C(ABILITY_CONTINUOUS), WX_C(ABILITY_LIFEBURST), WX_C(ABILITY_USE),
    WX_C(RESET_PHASE), WX_C(RESET_EVENT), WX_C(RESETS_STANDARD),
    WX_C(PHASE_UP), WX_C(PHASE_DRAW), WX_C(PHASE_ENA), WX_C(PHASE_GROW), WX_C(PHASE_MAIN),
    WX_C(PHASE_ATTACK), WX_C(PHASE_END),
    WX_C(LOCATION_MDECK), WX_C(LOCATION_LIFE), WX_C(LOCATION_LDECK), WX_C(LOCATION_HAND),
    WX_C(LOCATION_TRASH), WX_C(LOCATION_LTRASH), WX_C(LOCATION_ENA), WX_C(LOCATION_CHECK),
    WX_C(LOCATION_EXCLUDE), WX_C(LOCATION_LRIG), WX_C(LOCATION_ASSIST), WX_C(LOCATION_KEY),
    WX_C(LOCATION_SIGNI), WX_C(LOCATION_CHEER), WX_C(LOCATION_SZONE), WX_C(LOCATION_FIELD),
    WX_C(TYPE_LRIG), WX_C(TYPE_SIGNI), WX_C(TYPE_ARTS), WX_C(TYPE_SPELL), WX_C(TYPE_ASSIST_LRIG),
    WX_C(TYPE_TOKEN), WX_C(TYPE_PIECE), WX_C(TYPE_KEY), WX_C(TYPE_RESONA), WX_C(TYPE_CRAFT),
    WX_C(TYPE_COIN), WX_C(TYPE_RELAY),
    WX_C(COLOR_WHITE), WX_C(COLOR_RED), WX_C(COLOR_BLUE), WX_C(COLOR_GREEN), WX_C(COLOR_BLACK),
    WX_C(EVENT_ON_PLAY), WX_C(EVENT_LEAVE_FIELD), WX_C(EVENT_BANISHED), WX_C(EVENT_TO_TRASH),
    WX_C(EVENT_TO_ENA), WX_C(EVENT_TO_HAND), WX_C(EVENT_DRAW), WX_C(EVENT_ATTACK), WX_C(EVENT_CRUSHED),
    WX_C(EVENT_DAMAGE), WX_C(EVENT_GROW), WX_C(EVENT_REFRESH), WX_C(EVENT_TURN_END),
    WX_C(EVENT_PHASE_START), WX_C(EVENT_CUSTOM),
    WX_C(REASON_RULE), WX_C(REASON_EFFECT), WX_C(REASON_BATTLE), WX_C(REASON_COST),
    WX_C(REASON_DISCARD), WX_C(REASON_DAMAGE),
    WX_C(TIMING_MAIN), WX_C(TIMING_ATTACK), WX_C(TIMING_CUTIN),
};
#undef WX_C

}  // namespace

void Duel::init_lua() {
  L_ = luaL_newstate();
  *static_cast<Duel**>(lua_getextraspace(L_)) = this;
  open_safe_libs(L_);

  lua_getglobal(L_, "math");
  lua_pushcfunction(L_, l_random);
  lua_setfield(L_, -2, "random");
  lua_pushcfunction(L_, l_randomseed);
  lua_setfield(L_, -2, "randomseed");
  lua_pop(L_, 1);

  lua_newtable(L_);
  lua_setfield(L_, LUA_REGISTRYINDEX, "wx_cards");
  lua_newtable(L_);
  lua_setfield(L_, LUA_REGISTRYINDEX, "wx_effects");

  static const luaL_Reg effect_funcs[] = {
      {"CreateEffect", e_CreateEffect}, {"SetType", e_SetType}, {"SetCode", e_SetCode},
      {"SetProperty", e_SetProperty}, {"SetAbilityType", e_SetAbilityType}, {"GetAbilityType", e_GetAbilityType}, {"IsAbilityType", e_IsAbilityType}, {"SetRange", e_SetRange}, {"SetTargetRange", e_SetTargetRange},
      {"SetValue", e_SetValue}, {"SetTarget", e_SetTarget}, {"SetDeclare", e_SetDeclare}, {"SetMinCost", e_SetMinCost}, {"SetCheck", e_SetCheck}, {"SetCondition", e_SetCondition},
      {"SetReset", e_SetReset}, {"SetOperation", e_SetOperation}, {"SetTiming", e_SetTiming}, {"SetEnaCost", e_SetEnaCost}, {"SetCountLimit", e_SetCountLimit},
      {"SetCoinCost", e_SetCoinCost}, {"SetExceedCost", e_SetExceedCost}, {"SetEncore", e_SetEncore}, {"SetEncoreCost", e_SetEncoreCost}, {"SetBet", e_SetBet}, {"SetBetCost", e_SetBetCost},
      {"SetLabelObject", e_SetLabelObject}, {"GetLabelObject", e_GetLabelObject},
      {"SetCost", e_SetCost}, {"SetLabel", e_SetLabel}, {"GetLabel", e_GetLabel},
      {"SetDescription", e_SetDescription}, {"GetDescription", e_GetDescription}, {"GetValue", e_GetValue},
      {"GetHandler", e_GetHandler}, {"GetOwner", e_GetOwner}, {"GetOwnerPlayer", e_GetOwnerPlayer},
      {"GetHandlerPlayer", e_GetHandlerPlayer}, {nullptr, nullptr}};
  static const luaL_Reg card_funcs[] = {
      {"RegisterEffect", c_RegisterEffect}, {"GrantEffect", c_GrantEffect}, {"GetCode", c_GetCode},
      {"GetOriginalCode", c_GetOriginalCode}, {"GetPower", c_GetPower}, {"GetLevel", c_GetLevel},
      {"GetColor", c_GetColor}, {"IsColor", c_IsColor}, {"IsType", c_IsType}, {"IsSigni", c_IsSigni},
      {"IsClass", c_IsClass}, {"GetLocation", c_GetLocation}, {"IsLocation", c_IsLocation},
      {"GetPreviousLocation", c_GetPreviousLocation}, {"IsPreviousLocation", c_IsPreviousLocation},
      {"GetControler", c_GetControler}, {"GetOwner", c_GetOwner}, {"IsFaceup", c_IsFaceup},
      {"IsDown", c_IsDown}, {"IsUp", c_IsUp}, {"IsFrozen", c_IsFrozen}, {"HasKeyword", c_HasKeyword},
      {"GetClasses", c_GetClasses}, {"GetLrigTypes", c_GetLrigTypes}, {"IsLrigType", c_IsLrigType},
      {"GetZone", c_GetZone}, {"GetFrontCard", c_GetFrontCard}, {"IsInZone", c_IsInZone}, {"GetPreviousZone", c_GetPreviousZone}, {"HasRiseIcon", c_HasRiseIcon}, {"IsDrive", c_IsDrive}, {"HasAbility", c_HasAbility}, {"GetResonaMaterials", c_GetResonaMaterials}, {"HasTiming", c_HasTiming}, {"HasAttacked", c_HasAttacked}, {"HasTrapIcon", c_HasTrapIcon}, {"GetCostTotal", c_GetCostTotal}, {"IsCardName", c_IsCardName}, {"GetCharm", c_GetCharm}, {"IsLevelBetween", c_IsLevelBetween}, {"GetUnderGroup", c_GetUnderGroup}, {"HasAcceIcon", c_HasAcceIcon}, {"IsAcce", c_IsAcce}, {"IsPreviousAcce", c_IsPreviousAcce}, {"GetAcceHost", c_GetAcceHost}, {"IsLifeBurst", c_IsLifeBurst},
      {"IsCanAttack", c_IsCanAttack}, {"IsRelateToEffect", c_IsRelateToEffect}, {"IsInfected", c_IsInfected},
      {"IsBloodArmed", c_IsBloodArmed}, {"IsSameName", c_IsSameName}, {"IsCross", c_IsCross}, {"HasCrossIcon", c_HasCrossIcon}, {"HasGuardIcon", c_HasGuardIcon},
      {nullptr, nullptr}};
  static const luaL_Reg duel_funcs[] = {{"RegisterEffect", d_RegisterEffect}, {"Draw", d_Draw},
                                        {"EnaCharge", d_EnaCharge}, {"IsTeam", d_IsTeam},
                                        {"SendToTrash", d_SendToTrash}, {"SendToHand", d_SendToHand},
                                        {"SendToEna", d_SendToEna}, {"SendToDeckBottom", d_SendToDeckBottom},
                                        {"Down", d_Down}, {"Freeze", d_Freeze},
                                        {"GetDecktopGroup", d_GetDecktopGroup}, {"ConfirmCards", d_ConfirmCards},
                                        {"GetLifetopGroup", d_GetLifetopGroup}, {"SendToLife", d_SendToLife},
                                        {"Crush", d_Crush},
                                        {"SelectCards", d_SelectCards}, {"SelectDiscard", d_SelectDiscard},
                                        {"SelectOption", d_SelectOption}, {"PutOnField", d_PutOnField},
                                        {"SetSelectCheck", d_SetSelectCheck},
                                        {"GetCoin", d_GetCoin}, {"AddCoin", d_AddCoin},
                                        {"SendToDeckPosition", d_SendToDeckPosition},
                                        {"SendToDeckShuffle", d_SendToDeckShuffle}, {"RevealCards", d_RevealCards},
                                        {"MoveSigni", d_MoveSigni}, {"AnnounceNumber", d_AnnounceNumber},
                                        {"SelectOrder", d_SelectOrder}, {"GetDeckMovedCount", d_GetDeckMovedCount},
                                        {"HasGate", d_HasGate}, {"PlaceGate", d_PlaceGate},
                                        {"BloodArm", d_BloodArm}, {"GetSpellsUsedCount", d_GetSpellsUsedCount}, {"GetRefreshCount", d_GetRefreshCount}, {"Damage", d_Damage}, {"IsExtraTurn", d_IsExtraTurn}, {"GetDownLog", d_GetDownLog}, {"ExtraTurn", d_ExtraTurn}, {"EndTurn", d_EndTurn}, {"UseFree", d_UseFree}, {"SwapSigni", d_SwapSigni}, {"IsPlayerAffected", d_IsPlayerAffected}, {"GetPaidEna", d_GetPaidEna}, {"GrowByEffect", d_GrowByEffect}, {"SetSeed", d_SetSeed}, {"Bloom", d_Bloom}, {"GetDeckbottomGroup", d_GetDeckbottomGroup}, {"NegateAttack", d_NegateAttack}, {"PutKey", d_PutKey}, {"Ride", d_Ride}, {"SetTrap", d_SetTrap}, {"OpenTrap", d_OpenTrap}, {"GetTrap", d_GetTrap}, {"CanPutAll", d_CanPutAll},
                                        {"GetAttackDrawCount", d_GetAttackDrawCount}, {"GetCutinSpell", d_GetCutinSpell}, {"NegateSpell", d_NegateSpell},
                                        {"AnnounceCard", d_AnnounceCard}, {"GetLeaveGuards", d_GetLeaveGuards}, {"SelectModes", d_SelectModes}, {"CharmGuard", d_CharmGuard}, {"Charm", d_Charm}, {"SetLrigType", d_SetLrigType}, {"GetPhase", d_GetPhase}, {"GetCrushedCount", d_GetCrushedCount}, {"Exclude", d_Exclude}, {"SkipTurn", d_SkipTurn}, {"Acce", d_Acce}, {"HasVirus", d_HasVirus}, {"PlaceVirus", d_PlaceVirus}, {"RemoveVirus", d_RemoveVirus},
                                        {"GetSigniZones", d_GetSigniZones}, {"SelectZone", d_SelectZone},
                                        {"GetTurnPlayer", d_GetTurnPlayer}, {"GetTurnCount", d_GetTurnCount}, {"SelectYesNo", d_SelectYesNo},
                                        {"IsBet", d_IsBet}, {"SetUseCost", d_SetUseCost}, {"GetUseCost", d_GetUseCost}, {"ReduceCost", d_ReduceCost}, {"GetBanisher", d_GetBanisher}, {"GetRiser", d_GetRiser}, {"GetFrontZone", d_GetFrontZone}, {"GetCrusher", d_GetCrusher}, {"GetBattleOpponent", d_GetBattleOpponent}, {"GetArtsUsedCount", d_GetArtsUsedCount}, {"GetDiscardedCount", d_GetDiscardedCount}, {"Up", d_Up}, {"PutUnder", d_PutUnder}, {"SendToLrigDeck", d_SendToLrigDeck}, {"SendToLrigTrash", d_SendToLrigTrash}, {"CanPayEna", d_CanPayEna},
                                        {"SelectEnaCost", d_SelectEnaCost}, {"PutOnFieldAttacking", d_PutOnFieldAttacking},
                                        {"IsExistingTarget", d_IsExistingTarget},
                                        {"GetMatchingGroup", d_GetMatchingGroup},
                                        {"SelectTarget", d_SelectTarget}, {"GetFirstTarget", d_GetFirstTarget},
                                        {"GetTargets", d_GetTargets}, {"Banish", d_Banish},
                                        {nullptr, nullptr}};
  set_funcs(L_, "Effect", effect_funcs);
  set_funcs(L_, "Card", card_funcs);
  set_funcs(L_, "Duel", duel_funcs);
  make_meta(L_, kEffectMeta, "Effect");
  make_meta(L_, kCardMeta, "Card");

  lua_register(L_, "GetID", l_GetID);
  if (luaL_dostring(L_, kPrelude) != LUA_OK) {
    log(std::string("prelude 오류: ") + lua_tostring(L_, -1));
    lua_pop(L_, 1);
  }
  for (const Const& k : kConstants) {
    lua_pushinteger(L_, k.value);
    lua_setglobal(L_, k.name);
  }
  // 클래스·루리그 타입 상수(classes.lua: SYS_*·RACE_*·LRIG_*)는 프레임이 카드 DB의 classes 표로 만들어 넘긴다.
  // 그다음 공용 헬퍼(utility.lua, aux 표). 둘 다 카드 스크립트보다 먼저 읽고, 없으면 건너뛴다.
  // 파일 이름이 aux가 아닌 건 Windows 예약 장치 이름이라서다
  for (const char* name : {"classes.lua", "utility.lua"}) {
    std::string code;
    if (cfg_.script && cfg_.script(name, code) && (strip_bom(code), true) &&
        (load_text(L_, code, name) != LUA_OK || lua_pcall(L_, 0, 0, 0) != LUA_OK)) {
      log(std::string(name) + " 오류: " + lua_tostring(L_, -1));
      lua_pop(L_, 1);
    }
  }
}

bool Duel::load_script(Cid cid) {
  if (loaded_scripts_.count(cid)) return true;
  const std::string name = "c" + std::to_string(cid) + ".lua";
  std::string code;
  if (!cfg_.script || !cfg_.script(name, code)) return false;  // 스크립트 없음 = 능력 없는 카드
  strip_bom(code);

  lua_newtable(L_);
  lua_pushvalue(L_, -1);
  lua_setglobal(L_, ("c" + std::to_string(cid)).c_str());
  lua_setfield(L_, LUA_REGISTRYINDEX, "wx_cur_table");
  lua_pushinteger(L_, cid);
  lua_setfield(L_, LUA_REGISTRYINDEX, "wx_cur_id");

  if (load_text(L_, code, name.c_str()) != LUA_OK ||
      lua_pcall(L_, 0, 0, 0) != LUA_OK) {
    log(std::string("스크립트 오류: ") + lua_tostring(L_, -1));
    lua_pop(L_, 1);
    return false;
  }
  loaded_scripts_.insert(cid);
  return true;
}

void Duel::run_initial_effect(CardIdx c, Cid text, EffectId copy_of) {
  if (!load_script(text)) return;
  lua_getglobal(L_, ("c" + std::to_string(text)).c_str());
  lua_getfield(L_, -1, "initial_effect");
  lua_remove(L_, -2);
  if (!lua_isfunction(L_, -1)) {
    lua_pop(L_, 1);
    return;
  }
  const CardIdx saved_card = init_card_;
  const Cid saved_text = init_text_;
  const EffectId saved_copy = init_copy_;
  init_card_ = c;
  init_text_ = text;
  init_copy_ = copy_of;
  push_card(L_, c);
  if (lua_pcall(L_, 1, 0, 0) != LUA_OK) {
    log(std::string("initial_effect 오류: ") + lua_tostring(L_, -1));
    lua_pop(L_, 1);
  }
  init_card_ = saved_card;
  init_text_ = saved_text;
  init_copy_ = saved_copy;
}

bool Duel::call_filter(int ref, EffectId e, CardIdx c) {
  lua_rawgeti(L_, LUA_REGISTRYINDEX, ref);
  push_effect(L_, e);
  push_card(L_, c);
  if (lua_pcall(L_, 2, 1, 0) != LUA_OK) {
    log(std::string("대상 필터 오류: ") + lua_tostring(L_, -1));
    lua_pop(L_, 1);
    return false;
  }
  bool r = lua_toboolean(L_, -1);
  lua_pop(L_, 1);
  return r;
}

bool Duel::call_condition(int ref, EffectId e) {
  lua_rawgeti(L_, LUA_REGISTRYINDEX, ref);
  push_effect(L_, e);
  if (lua_pcall(L_, 1, 1, 0) != LUA_OK) {
    log(std::string("조건 오류: ") + lua_tostring(L_, -1));
    lua_pop(L_, 1);
    return false;
  }
  bool r = lua_toboolean(L_, -1);
  lua_pop(L_, 1);
  return r;
}

std::string Duel::call_cost(int ref, EffectId e, PlayerId p, const std::string& base) {
  lua_rawgeti(L_, LUA_REGISTRYINDEX, ref);
  push_effect(L_, e);
  lua_pushinteger(L_, p);
  lua_pushstring(L_, base.c_str());
  if (lua_pcall(L_, 3, 1, 0) != LUA_OK || lua_type(L_, -1) != LUA_TSTRING) {
    log(std::string("코스트 함수 오류: ") + (lua_isstring(L_, -1) ? lua_tostring(L_, -1) : "문자열이 아님"));
    lua_pop(L_, 1);
    return "";
  }
  std::string r = lua_tostring(L_, -1);
  lua_pop(L_, 1);
  return r;
}

int32_t Duel::call_value(int ref, EffectId e, CardIdx c) {
  lua_rawgeti(L_, LUA_REGISTRYINDEX, ref);
  push_effect(L_, e);
  push_card(L_, c);
  if (lua_pcall(L_, 2, 1, 0) != LUA_OK) {
    log(std::string("값 함수 오류: ") + lua_tostring(L_, -1));
    lua_pop(L_, 1);
    return 0;
  }
  int32_t r = static_cast<int32_t>(lua_tointeger(L_, -1));
  lua_pop(L_, 1);
  return r;
}

namespace {
void push_group(lua_State* L, const std::vector<CardIdx>& cards) {
  lua_createtable(L, static_cast<int>(cards.size()), 0);
  for (size_t i = 0; i < cards.size(); ++i) {
    push_card(L, cards[i]);
    lua_rawseti(L, -2, static_cast<lua_Integer>(i + 1));
  }
  lua_getglobal(L, "Group");
  lua_setmetatable(L, -2);
}

// e, tp, eg, ep, ev, re, r, rp
int push_trigger_args(lua_State* L, const Pending& t) {
  push_effect(L, t.effect);
  lua_pushinteger(L, t.player);
  push_group(L, t.event.cards);
  lua_pushinteger(L, t.event.player);
  lua_pushinteger(L, t.event.value);
  push_effect(L, t.event.reason_effect);
  lua_pushinteger(L, t.event.reason);
  lua_pushinteger(L, t.event.reason_player);
  return 8;
}
}  // namespace

bool Duel::call_immune(int ref, EffectId e, CardIdx src, PlayerId p) {
  lua_rawgeti(L_, LUA_REGISTRYINDEX, ref);
  push_effect(L_, e);
  push_card(L_, src);
  lua_pushinteger(L_, p);
  if (lua_pcall(L_, 3, 1, 0) != LUA_OK) {
    log(std::string("면역 함수 오류: ") + lua_tostring(L_, -1));
    lua_pop(L_, 1);
    return false;
  }
  const bool r = lua_toboolean(L_, -1);
  lua_pop(L_, 1);
  return r;
}

bool Duel::call_group_check(int ref, const std::vector<CardIdx>& g) {
  lua_rawgeti(L_, LUA_REGISTRYINDEX, ref);
  push_group(L_, g);
  if (lua_pcall(L_, 1, 1, 0) != LUA_OK) {
    log(std::string("조합 검증 오류: ") + lua_tostring(L_, -1));
    lua_pop(L_, 1);
    return false;
  }
  const bool r = lua_toboolean(L_, -1);
  lua_pop(L_, 1);
  return r;
}

// 트리거 조건, 또는 대상 함수의 chk==0 확인. 선택 요청(yield)은 할 수 없다.
bool Duel::call_trigger_check(int ref, const Pending& t, bool is_target) {
  lua_rawgeti(L_, LUA_REGISTRYINDEX, ref);
  int n = push_trigger_args(L_, t);
  if (is_target) {
    lua_pushinteger(L_, 0);
    ++n;
  }
  if (lua_pcall(L_, n, 1, 0) != LUA_OK) {
    log(std::string(is_target ? "대상 확인 오류: " : "트리거 조건 오류: ") + lua_tostring(L_, -1));
    lua_pop(L_, 1);
    return false;
  }
  bool r = lua_toboolean(L_, -1);
  lua_pop(L_, 1);
  return r;
}

// Lua 함수를 코루틴으로 돌린다. 스크립트가 선택을 요청하면(yield) 엔진 코루틴도 같이 멈췄다가
// 응답을 받아 이어 간다. 확정 전 선택이 취소되면 Canceled가 이 함수 밖으로 나가고 코루틴은 버린다.
Task<> Duel::run_lua(int fn_ref, const Pending& t, bool chk) {
  struct ThreadRef {
    lua_State* L;
    int ref;
    ~ThreadRef() { luaL_unref(L, LUA_REGISTRYINDEX, ref); }
  };
  const Effect& e = *effects.get(t.effect);
  lua_State* T = lua_newthread(L_);
  ThreadRef keep{L_, luaL_ref(L_, LUA_REGISTRYINDEX)};
  int nargs = 0;
  if (fn_ref == 0) {
    lua_getglobal(T, "__wx_resolve");
    if (e.declare_ref) lua_rawgeti(T, LUA_REGISTRYINDEX, e.declare_ref); else lua_pushnil(T);
    if (e.target_ref) lua_rawgeti(T, LUA_REGISTRYINDEX, e.target_ref); else lua_pushnil(T);
    if (e.operation_ref) lua_rawgeti(T, LUA_REGISTRYINDEX, e.operation_ref); else lua_pushnil(T);
    nargs = 3;
  } else {
    lua_rawgeti(T, LUA_REGISTRYINDEX, fn_ref);
  }
  nargs += push_trigger_args(T, t);
  if (chk) {
    lua_pushinteger(T, 1);
    ++nargs;
  }
  for (;;) {
    int nres = 0;
    const int st = lua_resume(T, L_, nargs, &nres);
    if (st == LUA_YIELD && lua_task) {
      lua_pop(T, nres);
      auto task = std::move(lua_task);
      lua_task = nullptr;
      const bool ok = co_await task();
      lua_pushboolean(T, ok);
      nargs = 1;
      continue;
    }
    if (st == LUA_YIELD) {
      lua_pop(T, nres);
      if (!lua_request) {
        log("선택 요청 없이 yield함");
        break;
      }
      Request req = std::move(*lua_request);
      lua_request.reset();
      auto reply = std::move(lua_reply);
      lua_reply = nullptr;
      Response res = co_await ask(std::move(req));
      nargs = reply ? reply(T, res) : 0;
      continue;
    }
    if (st != LUA_OK) {
      log(std::string("효과 처리 오류: ") + (lua_tostring(T, -1) ? lua_tostring(T, -1) : "?"));
      unref(select_check_ref);  // 걸어 둔 선택 검증이 다음 선택으로 새지 않게
    }
    break;
  }
}

void Duel::unref(int& ref) {
  if (ref && L_) luaL_unref(L_, LUA_REGISTRYINDEX, ref);
  ref = 0;
}

}  // namespace wx
