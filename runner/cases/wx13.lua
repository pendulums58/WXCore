-- WX13 부스터 카드 스크립트 케이스(시그니 어택 합계 1번, 패로 돌아가지 않음, 바니시 수로 코스트 감소 등). 근거는 카드별 FAQ(cards.json)

local N = {}
local WS, OPP, MID, BS = 200000, 101000, 101500, 200004
local SASHE4, HANARE4, SP, SASHE5, YUZ4, UCHU = 300110, 300111, 300112, 300115, 300114, 200110

local function wd(t, lrig, p1)
  t:start{db = true, seed = 1}
  local function pick_card(x) return type(x) == "string" and t:no(x) or N[x] or x end
  for i = 1, 100 do N[i] = t:no(("WX13-%03d"):format(i)) end
  t:signi(WS, 1000, COLOR_WHITE, 1)
  t:signi(BS, 1000, COLOR_BLACK, 1)
  t:signi(OPP, 3000, COLOR_GREEN, 1)
  t:signi(MID, 9000, COLOR_GREEN, 3)
  t:lrig(SASHE4, 4, 11, {"サシェ"}, COLOR_WHITE)
  t:lrig(HANARE4, 4, 11, {"ハナレ"}, COLOR_BLACK)
  t:lrig(SASHE5, 5, 11, {"サシェ"}, COLOR_WHITE)
  t:lrig(YUZ4, 4, 11, {"タマ"}, COLOR_RED)
  t:card{cid = UCHU, power = 2000, level = 1, classes = {"精羅：宇宙"}, color = COLOR_WHITE}
  t:card{cid = SP, type = TYPE_SPELL, color = COLOR_GREEN}
  t:script(SP, [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetOperation(function(e,tp)
    for x in Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil):Iter() do Duel.SendToHand(x) Duel.Down(x) end
  end)
  c:RegisterEffect(e1)
end]])
  lrig, p1 = pick_card(lrig or SASHE4), pick_card(p1 or SASHE4)
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

case("白羅星 フルムーン: 상대는 시그니 어택 스텝에 합계 1번만 어택할 수 있다", "WX13-005A", function(t)
  wd(t, SASHE4)
  local r = t:put(t:no("WX13-005A"), 0, "lrig_deck")
  for _, z in ipairs{"signi_left", "signi_center", "signi_right"} do t:put(UCHU, 0, z) end
  local x, y = t:put(OPP, 1, "signi_left"), t:put(OPP, 1, "signi_center")
  main(t)
  t:expect(t:answer(t:action(ACT_RESONA, r)))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:answer(t:action(ACT_END)))
  -- 내 어택 페이즈는 넘기고 상대 시그니 어택까지
  t:step()
  while not (t:request().hint == HINT_ATTACK_SIGNI and t:request().player == 1) do
    local r = t:request()
    t:expect(t:answer(table.unpack(r.options, 1, r.min)) or t:answer(t:action(ACT_END)))
    t:step()
  end
  t:expect(t:answer(t:request().options[1]))
  t:step()
  while t:request().hint ~= HINT_ATTACK_SIGNI and t:request().hint ~= HINT_ATTACK_LRIG do
    t:expect(t:answer(table.unpack(t:request().options, 1, t:request().min)) or t:answer())
    t:step()
  end
  t:expect(t:request().hint == HINT_ATTACK_LRIG, "두 번째 시그니 어택은 없다")
end)

case("羅星宙姫 ノーザンセブン ②: 이 턴 내 시그니는 장에서 패로 돌아가지 않는다", "WX13-029", function(t)
  wd(t, SASHE5)
  t:put(N[29], 0, "signi_center")
  local w = t:put(WS, 0, "signi_left")
  local sp = t:put(SP, 1, "hand")
  t:begin(0, PHASE_ATTACK)
  t:expect(t:wait(HINT_MODE))
  t:expect(t:answer(t:request().options[2]))  -- ②
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:keyword(w, EFFECT_NO_BOUNCE), "얻었다")
end)

case("ネクスト・パニッシュ: 이 턴에 상대 시그니가 바니시됐으면 《黒》×3 준다", "WX13-026", function(t)
  for _, banished in ipairs{false, true} do
    wd(t, HANARE4)
    local a = t:put(N[26], 0, "lrig_deck")
    t:put(MID, 1, "signi_center")
    for _ = 1, 3 do t:put(BS, 0, "ena") end
    t:card{cid = 300113, type = TYPE_SPELL, color = COLOR_BLACK}
    t:script(300113, [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetOperation(function(e,tp) Duel.Banish(Duel.GetMatchingGroup(function(x) return x:GetPower()<=3000 end,tp,0,LOCATION_SZONE,nil)) end)
  c:RegisterEffect(e1)
end]])
    if banished then t:put(OPP, 1, "signi_left") end
    local sp = t:put(300113, 0, "hand")
    main(t)
    t:expect(t:answer(t:action(ACT_USE, sp)))
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:answer(t:action(ACT_END)))
    t:expect(t:wait(HINT_PRE_ATTACK))
    t:expect(t:answer(t:action(ACT_USE, a)))
    t:step()
    local paid = t:request().hint == HINT_PAY_ENA
    t:expect(paid == not banished, banished and "코스트 없음" or "《黒》×3")
  end
end)

case("立炎交差 ①: 대상의 크로스 짝을 덱에서 찾아 장에 낸다", "WX13-012", function(t)
  wd(t, YUZ4)
  local a = t:put(N[12], 0, "lrig_deck")
  local d = t:put(1412, 0, "signi_left")  -- 轟左砲 ドーラ(짝: ドスラフ)
  local p = t:put(1413, 0, "main_deck")
  for _ = 1, 3 do t:put(t:no("WX01-100"), 0, "ena") end
  main(t)
  t:expect(t:answer(t:action(ACT_USE, a)))
  t:step()
  while t:request().hint ~= HINT_MAIN do
    local r = t:request()
    if r.hint == HINT_SCRIPT then t:expect(t:answer(1))
    elseif r.hint == HINT_MODE then t:expect(t:answer(r.options[1]))
    elseif r.hint == HINT_TARGET then t:expect(t:answer(d))
    else t:expect(t:answer(table.unpack(r.options, 1, math.max(r.min, 1)))) end
    t:step()
  end
  t:expect(t:is_in(p, 0, "signi_center") or t:is_in(p, 0, "signi_right"), "ドスラフ가 나왔다")
end)
