-- WX09 부스터 카드 스크립트 케이스(상대 턴 코스트, 어택 스텝 스킵, 코스트 증가, ＋를 －로 등). 근거는 카드별 FAQ(cards.json)

local N = {}
local WS, US, OPP, MID, BIG = 200000, 200002, 101000, 101500, 102000
local DOKU, LV4, BLU4 = 200050, 300060, 300061
local SP = 200051

local function wd(t, lrig, p1)
  t:start{db = true, seed = 1}
  local function pick_card(x) return type(x) == "string" and t:no(x) or N[x] or x end
  for i = 1, 57 do N[i] = t:no(("WX09-%03d"):format(i)) end
  t:signi(WS, 1000, COLOR_WHITE, 1)
  t:signi(US, 1000, COLOR_BLUE, 1)
  t:signi(OPP, 3000, COLOR_GREEN, 1)
  t:signi(MID, 9000, COLOR_GREEN, 3)
  t:signi(BIG, 15000, COLOR_GREEN, 4)
  t:card{cid = DOKU, power = 2000, level = 1, classes = {"精武：毒牙"}, color = COLOR_BLACK}
  t:card{cid = SP, type = TYPE_SPELL, color = COLOR_BLUE, cost = "{U}"}
  t:script(SP, [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e1)
end]])
  t:lrig(LV4, 4, 11, {"タウィル"}, COLOR_WHITE)
  t:lrig(BLU4, 4, 11, {"ピルルク"}, COLOR_BLUE)
  lrig, p1 = pick_card(lrig or LV4), pick_card(p1 or LV4)
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

local function run(t)
  t:step()
  while t:request().hint ~= HINT_MAIN do
    local r = t:request()
    if r.hint == HINT_SCRIPT or r.hint == HINT_USE_TRIGGER then t:expect(t:answer(1)) else t:expect(t:answer(table.unpack(r.options, 1, math.max(r.min, 1)))) end
    t:step()
  end
end

case("ロック・ユー: 이 턴 상대 스펠 코스트 《無》×3 증가(컷인된 스펠은 그대로)", "WX09-Re05", function(t)
  wd(t, BLU4)
  local a = t:put(t:no("WX09-Re05"), 0, "lrig_deck")
  t:put(US, 0, "ena")
  local sp, sp2 = t:put(SP, 1, "hand"), t:put(SP, 1, "hand")
  for _ = 1, 4 do t:put(US, 1, "ena") end
  main(t, 1)
  t:expect(t:answer(t:action(ACT_USE, sp)))
  t:expect(t:wait(HINT_CUTIN))
  t:expect(t:answer(t:action(ACT_USE, a)))
  run(t)
  t:expect(t:is_in(sp, 1, "trash") and t:count(1, "ena") == 3)
  t:expect(t:action(ACT_USE, sp2) == nil, "《青》+《無》×3 = 4 > 3")
end)

case("フィア＝ヴィックス: 상대가 상대 시그니에 주는 ＋는 －가 된다", "WX09-021 FAQ 1·4", function(t)
  wd(t, LV4)
  t:put(N[21], 0, "signi_center")
  local x = t:put(MID, 1, "signi_center")
  t:field(EFFECT_UPDATE_POWER, 3000, 1, LOCATION_SZONE, 0, 0)
  t:expect(t:power(x) == 6000, "9000 − 3000 " .. t:power(x))
  t:field(EFFECT_UPDATE_POWER, 2000, 0, 0, LOCATION_SZONE, 0)
  t:expect(t:power(x) == 8000, "내가 준 ＋2000은 그대로 " .. t:power(x))
end)

case("原槍 ラナジェ: 트래시에 《エナジェ》가 있으면 이 시그니가 바니시한 시그니는 트래시로", "WX09-022 FAQ 2", function(t)
  wd(t, LV4)
  local r = t:put(N[22], 0, "signi_center")
  t:put(1235, 0, "trash")  -- 《原槍　エナジェ》
  local x = t:put(OPP, 1, "signi_center")
  for _, c in ipairs{COLOR_WHITE, COLOR_RED, COLOR_BLUE, COLOR_GREEN, COLOR_BLACK} do
    t:signi(210000 + c, 1000, c, 1)
    t:put(210000 + c, 0, "ena")
  end
  main(t)
  t:expect(t:answer(t:action(ACT_ABILITY, r)))
  run(t)
  t:expect(t:is_in(x, 1, "trash"))
end)

case("アール・バウンダリー: 상대 턴에는 코스트가 《白》×3", "WX09-002", function(t)
  wd(t, LV4)
  local a = t:put(N[2], 0, "lrig_deck")
  for _ = 1, 3 do t:put(WS, 0, "ena") end
  t:put(OPP, 1, "signi_center")
  t:begin(1, PHASE_ATTACK)
  t:step()
  while t:request().hint ~= HINT_DEFENSE do
    t:expect(t:answer(table.unpack(t:request().options, 1, math.max(t:request().min, 0))) or t:answer())
    t:step()
  end
  t:expect(t:answer(t:action(ACT_USE, a)))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:request().min == 3, "코스트 3 " .. t:request().min)
end)

case("ＴＨＲＥＥ ＳＷＩＴＣＨ: 청 시그니 3체가 공통 클래스면 4장", "WX09-049, WX09-041 FAQ 2", function(t)
  for _, share in ipairs{true, false} do
    wd(t, BLU4)
    t:card{cid = 200060, power = 1000, level = 1, classes = {"精羅：原子"}, color = COLOR_BLUE}
    t:card{cid = 200061, power = 1000, level = 1, classes = {"精生：水獣"}, color = COLOR_BLUE}
    local sp = t:put(N[49], 0, "hand")
    t:put(200060, 0, "signi_left")
    t:put(200060, 0, "signi_center")
    t:put(share and 200060 or 200061, 0, "signi_right")
    for _ = 1, 4 do t:put(US, 0, "ena") end
    main(t)
    t:expect(t:answer(t:action(ACT_USE, sp)))
    run(t)
    t:expect(t:count(0, "hand") == (share and 4 or 3), "패 " .. t:count(0, "hand"))
  end
end)
