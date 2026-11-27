-- WX15 부스터 카드 스크립트 케이스(ベット, 한 번 바니시되지 않음, 정면 이외 존 어택, 【シャドウ】 등). 근거는 카드별 FAQ(cards.json)

local N = {}
local WS, OPP, RS, BS = 200000, 101000, 200002, 200001
local RIL4, SP, TG = 300130, 300131, 300132

local function wd(t, lrig, p1)
  t:start{db = true, seed = 1}
  local function pick_card(x) return type(x) == "string" and t:no(x) or N[x] or x end
  for i = 1, 118 do N[i] = t:no(("WX15-%03d"):format(i)) end
  t:signi(WS, 1000, COLOR_WHITE, 1)
  t:signi(RS, 1000, COLOR_RED, 1)
  t:signi(BS, 1000, COLOR_BLUE, 1)
  t:signi(OPP, 3000, COLOR_GREEN, 1)
  t:lrig(RIL4, 4, 11, {"リル"}, COLOR_RED)
  -- 양쪽 모든 시그니를 바니시하는 아츠(어택 페이즈)
  t:card{cid = SP, type = TYPE_ARTS, color = COLOR_RED, timing = TIMING_MAIN | TIMING_ATTACK}
  t:script(SP, [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
    if g:GetCount()>0 then Duel.Banish(g) end
  end)
  c:RegisterEffect(e1)
end]])
  -- 상대 시그니를 대상으로 하는 스펠(대상 후보를 본다)
  t:card{cid = TG, type = TYPE_SPELL, color = COLOR_RED}
  t:script(TG, [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,0,3,nil)
  end)
  e1:SetOperation(function() end)
  c:RegisterEffect(e1)
end]])
  lrig, p1 = pick_card(lrig or RIL4), pick_card(p1 or RIL4)
  t:fill(WS, 0, "main_deck", 15)
  t:fill(OPP, 1, "main_deck", 15)
  t:fill(WS, 0, "life_cloth", 5)
  t:fill(OPP, 1, "life_cloth", 5)
  t:put(p1, 1, "lrig_center")
  return t:put(lrig, 0, "lrig_center")
end

local function main(t, p)
  t:begin(p or 0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
end

case("タスク・ドロー: ベット하면 4장, 안 하면 2장", "WX15-015", function(t)
  for bet = 0, 1 do
    wd(t)
    t:add_coin(0, 2)
    local arts = t:put(N[15], 0, "lrig_deck")
    for _ = 1, 2 do t:put(BS, 0, "ena") end
    main(t)
    local h = t:count(0, "hand")
    t:expect(t:answer(t:action(ACT_USE, arts)))
    t:expect(t:wait(HINT_BET) and t:answer(bet))
    t:step()
    while t:request().hint == HINT_PAY_ENA do t:expect(t:answer(table.unpack(t:request().options, 1, t:request().min))) t:step() end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:count(0, "hand") == h + (bet == 1 and 4 or 2), "뽑은 수 " .. (t:count(0, "hand") - h))
    t:expect(t:coins(0) == (bet == 1 and 0 or 2), "코인")
  end
end)

case("君熾殉名: 다음 바니시 1번만 막고, 두 번째는 바니시된다", "WX15-010 FAQ 1", function(t)
  wd(t)
  local arts = t:put(N[10], 0, "lrig_deck")
  t:put(RS, 0, "ena")
  local b = t:put(N[75], 0, "signi_left")  -- ＜武勇＞
  local sp1, sp2 = t:put(SP, 0, "lrig_deck"), t:put(SP, 0, "lrig_deck")
  t:begin(0, PHASE_ATTACK)
  t:expect(t:wait(HINT_PRE_ATTACK))
  t:expect(t:answer(t:action(ACT_USE, arts)))
  t:step()
  while t:request().hint ~= HINT_PRE_ATTACK do
    t:expect(t:answer(table.unpack(t:request().options, 1, t:request().min)) or t:answer(t:action(ACT_END)))
    t:step()
  end
  t:expect(t:answer(t:action(ACT_USE, sp1)))
  t:expect(t:wait(HINT_PRE_ATTACK))
  t:expect(t:is_in(b, 0, "signi_left"), "첫 바니시는 막는다")
  t:expect(t:answer(t:action(ACT_USE, sp2)))
  t:step()
  t:expect(not t:is_in(b, 0, "signi_left"), "두 번째는 바니시")
end)

case("彩英の秘宝 #ノーベル#: 정면 이외의 존에 어택하면 그 시그니와 배틀하고 대미지는 없다", "WX15-037 FAQ 1", function(t)
  wd(t)
  local nb = t:put(N[37], 0, "signi_center")
  local a, b = t:put(OPP, 1, "signi_left"), t:put(OPP, 1, "signi_right")
  t:begin(0, PHASE_ATTACK)
  t:expect(t:wait(HINT_ATTACK_SIGNI) and t:answer(nb))
  t:expect(t:wait(HINT_SCRIPT) and t:answer(1))
  t:expect(t:wait(HINT_ZONE))
  t:expect(#t:request().options == 2, "정면을 뺀 2곳")
  t:expect(t:answer(t:request().options[1]))
  t:step()
  local gone = (t:is_in(a, 1, "signi_left") and 0 or 1) + (t:is_in(b, 1, "signi_right") and 0 or 1)
  t:expect(gone == 1 and t:count(1, "life_cloth") == 5, "1체 배틀, 대미지 없음")
end)

case("【シャドウ】: 상대 효과의 대상 후보에서 빠진다", "WX15-004 / 용어집: シャドウ", function(t)
  wd(t)
  local x = t:put(WS, 0, "signi_left")
  local y = t:put(WS, 0, "signi_center")
  t:single(x, EFFECT_SHADOW, 0, 0)
  local sp = t:put(TG, 1, "hand")
  main(t, 1)
  t:expect(t:answer(t:action(ACT_USE, sp)))
  t:expect(t:wait(HINT_TARGET))
  local o = t:request().options
  t:expect(#o == 1 and o[1] == y, "【シャドウ】 시그니는 대상이 될 수 없다")
end)

case("スプレッド・デス: 감염 상태면 －12000", "WX15-027", function(t)
  wd(t, t:no("WX15-004"))
  local arts = t:put(N[27], 0, "lrig_deck")
  for _ = 1, 2 do t:put(t:no("WX01-100"), 0, "ena") end
  local x = t:card{cid = 300133, power = 15000, level = 1, color = COLOR_GREEN}
  local s = t:put(300133, 1, "signi_left")
  t:place_virus(1, "signi_left")
  main(t)
  t:expect(t:answer(t:action(ACT_USE, arts)))
  t:step()
  while t:request().hint ~= HINT_MAIN do
    local r = t:request()
    if r.hint == HINT_TARGET then t:expect(t:answer(s)) else t:expect(t:answer(table.unpack(r.options, 1, r.min))) end
    t:step()
  end
  -- 其ノ四ノ別의 감염 －1000까지
  t:expect(t:power(s) == 15000 - 12000 - 1000, "파워 " .. t:power(s))
end)
