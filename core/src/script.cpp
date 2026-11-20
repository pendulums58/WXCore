// Lua 바인딩. 유프로 스크립트 구조(GetID, initial_effect, Effect.CreateEffect…)를 따른다.
// Lua는 C++로 빌드한 것을 쓰므로 lua.hpp(extern "C")가 아니라 lua.h를 직접 포함한다.
#include <lauxlib.h>
#include <lua.h>
#include <lualib.h>

#include <algorithm>

#include "duel.h"

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
int e_SetCode(lua_State* L) { check_effect(L, 1).code = check_u32(L, 2); return 0; }
int e_SetProperty(lua_State* L) { check_effect(L, 1).property = check_u32(L, 2); return 0; }
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
  D(L).register_effect(e.id, c);
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
int c_IsClass(lua_State* L) { lua_pushboolean(L, D(L).has_class(check_card(L, 1), luaL_checkstring(L, 2))); return 1; }
int c_GetLocation(lua_State* L) { lua_pushinteger(L, D(L).location_of(check_card(L, 1))); return 1; }
int c_IsLocation(lua_State* L) { lua_pushboolean(L, (D(L).location_of(check_card(L, 1)) & check_u32(L, 2)) != 0); return 1; }
int c_GetControler(lua_State* L) { lua_pushinteger(L, D(L).state.cards.get(check_card(L, 1)).controller); return 1; }
int c_GetOwner(lua_State* L) { lua_pushinteger(L, D(L).state.cards.get(check_card(L, 1)).owner); return 1; }
int c_IsFaceup(lua_State* L) { lua_pushboolean(L, D(L).state.cards.get(check_card(L, 1)).face_up); return 1; }

// ── Duel ──

int d_Draw(lua_State* L) {
  Duel& d = D(L);
  const PlayerId p = static_cast<PlayerId>(luaL_checkinteger(L, 1));
  const uint32_t n = static_cast<uint32_t>(luaL_checkinteger(L, 2));
  const uint32_t reason = static_cast<uint32_t>(luaL_optinteger(L, 3, REASON_EFFECT));
  lua_pushinteger(L, d.draw(p, n, reason));
  return 1;
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
  const PlayerId p = static_cast<PlayerId>(luaL_checkinteger(L, first + 1));
  const uint32_t self_loc = static_cast<uint32_t>(luaL_checkinteger(L, first + 2));
  const uint32_t opp_loc = static_cast<uint32_t>(luaL_checkinteger(L, first + 3));
  const CardIdx ex = lua_isuserdata(L, ex_idx) ? check_card(L, ex_idx) : kNoCard;
  std::vector<CardIdx> out;
  for (CardIdx c : d.cards_in(p, self_loc, opp_loc))
    if (c != ex && pass_filter(L, first, c, extra_from, lua_gettop(L))) out.push_back(c);
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
  const PlayerId sel = static_cast<PlayerId>(luaL_checkinteger(L, 1));
  const auto cands = gather(L, 2, 8, 9);
  uint32_t mn = static_cast<uint32_t>(luaL_checkinteger(L, 6));
  const uint32_t mx = static_cast<uint32_t>(luaL_checkinteger(L, 7));
  if (cands.empty() || d.chain.empty()) {
    push_group(L, {});
    return 1;
  }
  mn = std::min<uint32_t>(mn, static_cast<uint32_t>(cands.size()));
  Request r;
  r.type = ReqType::SelectCards;
  r.player = sel;
  r.hint = HINT_TARGET;
  r.options.assign(cands.begin(), cands.end());
  r.min = mn;
  r.max = std::max(mn, mx);
  r.cancelable = d.chain.back().cancelable;
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

int d_Banish(lua_State* L) {
  Duel& d = D(L);
  const CardIdx c = check_card(L, 1);
  const PlayerId rp = d.chain.empty() ? d.turn_player : d.chain.back().player;
  if (d.location_of(c) & LOCATION_SZONE) d.banish(c, REASON_EFFECT, rp);
  return 0;
}

int e_SetTiming(lua_State* L) { check_effect(L, 1).timing = check_u32(L, 2); return 0; }
int e_SetEnaCost(lua_State* L) { check_effect(L, 1).ena_cost = luaL_checkstring(L, 2); return 0; }
int e_SetCost(lua_State* L) {
  Effect& e = check_effect(L, 1);
  e.cost_ref = ref_function(L, 2, e.cost_ref);
  return 0;
}

int d_GetTurnPlayer(lua_State* L) {
  lua_pushinteger(L, D(L).turn_player);
  return 1;
}

// 선택 요청: 요청을 걸어 두고 코루틴을 멈춘다. 응답은 lua_reply가 Lua 값으로 바꿔 돌려준다.
int d_SelectYesNo(lua_State* L) {
  Duel& d = D(L);
  Request r;
  r.type = ReqType::YesNo;
  r.player = static_cast<PlayerId>(luaL_checkinteger(L, 1));
  r.hint = HINT_SCRIPT;
  r.options = {0, 1};
  d.lua_request = std::move(r);
  d.lua_reply = [](lua_State* T, const Response& res) {
    lua_pushboolean(T, res.picks[0] == 1);
    return 1;
  };
  return lua_yield(L, 0);
}

int d_RegisterEffect(lua_State* L) {
  Effect& e = check_effect(L, 1);
  D(L).register_player_effect(e.id, static_cast<PlayerId>(luaL_checkinteger(L, 2)));
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

-- 트리거 처리: 대상(chk=1) → 처리. 코루틴 안에서 돌아 선택 요청 때 멈출 수 있다
function __wx_resolve(tg, op, ...)
  local a = table.pack(...)
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
    WX_C(EFFECT_TYPE_LIFEBURST),
    WX_C(EFFECT_COPY), WX_C(EFFECT_CHANGE_COLOR), WX_C(EFFECT_ADD_COLOR), WX_C(EFFECT_ADD_CLASS),
    WX_C(EFFECT_CHANGE_LEVEL), WX_C(EFFECT_UPDATE_LEVEL), WX_C(EFFECT_UPDATE_LIMIT),
    WX_C(EFFECT_LOSE_ABILITY), WX_C(EFFECT_SET_POWER), WX_C(EFFECT_UPDATE_POWER),
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
  luaL_openlibs(L_);

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
      {"SetProperty", e_SetProperty}, {"SetRange", e_SetRange}, {"SetTargetRange", e_SetTargetRange},
      {"SetValue", e_SetValue}, {"SetTarget", e_SetTarget}, {"SetCondition", e_SetCondition},
      {"SetReset", e_SetReset}, {"SetOperation", e_SetOperation}, {"SetTiming", e_SetTiming}, {"SetEnaCost", e_SetEnaCost},
      {"SetCost", e_SetCost}, {"SetLabel", e_SetLabel}, {"GetLabel", e_GetLabel},
      {"GetHandler", e_GetHandler}, {"GetOwner", e_GetOwner}, {"GetOwnerPlayer", e_GetOwnerPlayer},
      {"GetHandlerPlayer", e_GetHandlerPlayer}, {nullptr, nullptr}};
  static const luaL_Reg card_funcs[] = {
      {"RegisterEffect", c_RegisterEffect}, {"GrantEffect", c_GrantEffect}, {"GetCode", c_GetCode},
      {"GetOriginalCode", c_GetOriginalCode}, {"GetPower", c_GetPower}, {"GetLevel", c_GetLevel},
      {"GetColor", c_GetColor}, {"IsColor", c_IsColor}, {"IsType", c_IsType}, {"IsSigni", c_IsSigni},
      {"IsClass", c_IsClass}, {"GetLocation", c_GetLocation}, {"IsLocation", c_IsLocation},
      {"GetControler", c_GetControler}, {"GetOwner", c_GetOwner}, {"IsFaceup", c_IsFaceup}, {"IsRelateToEffect", c_IsRelateToEffect},
      {nullptr, nullptr}};
  static const luaL_Reg duel_funcs[] = {{"RegisterEffect", d_RegisterEffect}, {"Draw", d_Draw},
                                        {"GetTurnPlayer", d_GetTurnPlayer}, {"SelectYesNo", d_SelectYesNo},
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
}

bool Duel::load_script(Cid cid) {
  if (loaded_scripts_.count(cid)) return true;
  const std::string name = "c" + std::to_string(cid) + ".lua";
  std::string code;
  if (!cfg_.script || !cfg_.script(name, code)) return false;  // 스크립트 없음 = 능력 없는 카드

  lua_newtable(L_);
  lua_pushvalue(L_, -1);
  lua_setglobal(L_, ("c" + std::to_string(cid)).c_str());
  lua_setfield(L_, LUA_REGISTRYINDEX, "wx_cur_table");
  lua_pushinteger(L_, cid);
  lua_setfield(L_, LUA_REGISTRYINDEX, "wx_cur_id");

  if (luaL_loadbuffer(L_, code.data(), code.size(), name.c_str()) != LUA_OK ||
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
    if (e.target_ref) lua_rawgeti(T, LUA_REGISTRYINDEX, e.target_ref); else lua_pushnil(T);
    if (e.operation_ref) lua_rawgeti(T, LUA_REGISTRYINDEX, e.operation_ref); else lua_pushnil(T);
    nargs = 2;
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
    if (st != LUA_OK) log(std::string("효과 처리 오류: ") + lua_tostring(T, -1));
    break;
  }
}

void Duel::unref(int& ref) {
  if (ref && L_) luaL_unref(L_, LUA_REGISTRYINDEX, ref);
  ref = 0;
}

}  // namespace wx
