-- WXK02 카드 스크립트 케이스. 근거는 카드별 FAQ(cards.json)

local WS, OPP, MID, LV4, LV0 = 200000, 101000, 101500, 300100, 300101
local GREEN, BLACK, BLUE = 202000, 202003, 202002

local function base(t, opts)
  opts = opts or {}
  t:start{db = true, seed = 1}
  t:signi(WS, 1000, COLOR_WHITE, 1)
  t:signi(OPP, 3000, COLOR_RED, 1)
  t:signi(MID, 9000, COLOR_RED, 3)
  t:signi(GREEN, 1000, COLOR_GREEN, 1)
  t:signi(BLACK, 1000, COLOR_BLACK, 1)
  t:signi(BLUE, 1000, COLOR_BLUE, 1)
  t:lrig(LV4, 4, 11, opts.types or {"タマ"}, opts.color or COLOR_WHITE)
  t:lrig(LV0, 0, 0, {"タマ"}, COLOR_WHITE)
  t:fill(WS, 0, "main_deck", 15)
  t:fill(OPP, 1, "main_deck", 15)
  t:fill(WS, 0, "life_cloth", 5)
  t:fill(OPP, 1, "life_cloth", 5)
  if opts.setup then opts.setup() end
  t:put(opts.opp or LV4, 1, "lrig_center")
  return t:put(opts.center or LV4, 0, "lrig_center")
end

local function main(t, p)
  t:begin(p or 0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
end

local function use(t, c) t:expect(t:answer(t:action(ACT_USE, c))) end

-- 그 힌트가 올 때까지 다른 요청은 첫 선택지로(메인·어택 창은 넘긴다)
local function until_hint(t, ...)
  local want = {...}
  t:step()
  for _ = 1, 80 do
    local r = t:request()
    if not r then return false end
    for _, h in ipairs(want) do if r.hint == h then return true end end
    local pass = (r.hint == HINT_MAIN or r.hint == HINT_PRE_ATTACK or r.hint == HINT_DEFENSE) and t:action(ACT_END)
    if pass then t:expect(t:answer(pass)) else t:expect(t:answer(table.unpack(r.options, 1, math.max(r.min, 1)))) end
    t:step()
  end
  return false
end

case("白滅の巫女　タマヨリヒメ: イノセンス로 지금 걸린 상대 효과가 아무것도 하지 않는다", "WXK02-001 FAQ 18", function(t)
  local lc = base(t, {center = t:no("WXK02-001")})
  local x = t:put(MID, 1, "signi_left")
  t:single(x, EFFECT_UPDATE_POWER, 5000, 1)
  t:add_coin(0, 1)
  main(t)
  t:expect(t:power(x) == 14000)
  t:expect(t:answer(t:action(ACT_END)))
  t:expect(t:wait(HINT_PRE_ATTACK))
  t:expect(t:answer(t:action(ACT_ABILITY, lc)))
  t:expect(until_hint(t, HINT_PRE_ATTACK, HINT_ATTACK_SIGNI, HINT_ATTACK_LRIG))
  t:expect(t:power(x) == 9000, "원래대로 " .. t:power(x))
end)

case("讃の遊　タケトンボ: 이 턴에 시그니가 장에서 패로 돌아갔으면 ＋7000", "WXK02-067 FAQ 1", function(t)
  local lc = base(t, {setup = function() t:script(LV4, [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetRange(LOCATION_LRIG)
  e1:SetOperation(function(e,tp)
    local x=Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil):GetFirst()
    if x then Duel.SendToHand(x) end
  end)
  c:RegisterEffect(e1)
end]]) end})
  local s = t:put(t:no("WXK02-067"), 0, "signi_left")
  t:put(OPP, 1, "signi_left")
  main(t)
  t:expect(t:power(s) == 8000)
  t:expect(t:answer(t:action(ACT_ABILITY, lc)))
  t:expect(until_hint(t, HINT_MAIN))
  t:expect(t:power(s) == 15000, "＋7000 " .. t:power(s))
end)

case("富英の配分　スミスハンズ: 드로 페이즈 이외에 3장 뽑았으면 바니시할 수 있다", "WXK02-036 FAQ 1", function(t)
  local lc = base(t, {setup = function() t:script(LV4, [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetRange(LOCATION_LRIG)
  e1:SetOperation(function(e,tp) Duel.Draw(tp,3) end)
  c:RegisterEffect(e1)
end]]) end})
  t:put(t:no("WXK02-036"), 0, "signi_left")
  local x = t:put(MID, 1, "signi_left")
  t:put(BLUE, 0, "ena")
  main(t)
  t:expect(t:answer(t:action(ACT_ABILITY, lc)))
  t:expect(until_hint(t, HINT_MAIN))
  t:expect(t:answer(t:action(ACT_END)))
  t:expect(until_hint(t, HINT_TARGET))
  t:expect(t:answer(x))
  t:expect(until_hint(t, HINT_SCRIPT))
  t:expect(t:answer(1))
  t:expect(until_hint(t, HINT_PRE_ATTACK, HINT_ATTACK_SIGNI))
  t:expect(t:is_in(x, 1, "ena"), "바니시 " .. tostring(t:at(x)))
end)
