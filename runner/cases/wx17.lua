-- WX17 부스터 카드 스크립트 케이스(【ウィルス】가 놓이면 【貯菌】, 《サーバント　ＺＥＲＯ》로 만들기). 근거는 카드별 FAQ(cards.json)

local N = {}
local WS, OPP, BIG, RS = 200000, 101000, 101500, 200002
local NANA4, CARN4, VSP = 300150, 300151, 300152

local function wd(t, lrig)
  t:start{db = true, seed = 1}
  for i = 1, 80 do N[i] = t:no(("WX17-%03d"):format(i)) end
  t:signi(WS, 1000, COLOR_WHITE, 1)
  t:signi(RS, 1000, COLOR_RED, 1)
  t:signi(OPP, 3000, COLOR_GREEN, 1)
  t:signi(BIG, 9000, COLOR_GREEN, 3)
  t:lrig(NANA4, 4, 11, {"ナナシ"}, COLOR_BLACK)
  t:lrig(CARN4, 4, 11, {"カーニバル"}, COLOR_RED)
  -- 상대 시그니 존 전부에 【ウィルス】를 두는 스펠
  t:card{cid = VSP, type = TYPE_SPELL, color = COLOR_BLACK}
  t:script(VSP, [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetOperation(function(e,tp) for _,z in ipairs(Duel.GetSigniZones(1-tp)) do Duel.PlaceVirus(z) end end)
  c:RegisterEffect(e1)
end]])
  t:fill(WS, 0, "main_deck", 15)
  t:fill(OPP, 1, "main_deck", 15)
  t:fill(WS, 0, "life_cloth", 5)
  t:fill(OPP, 1, "life_cloth", 5)
  t:put(NANA4, 1, "lrig_center")
  return t:put(lrig or NANA4, 0, "lrig_center")
end

case("羅菌姫 ボツリネス: 상대 장에 【ウィルス】가 놓일 때마다 【貯菌】, 2개로 트래시에", "WX17-034", function(t)
  wd(t)
  local b = t:put(N[34], 0, "signi_center")
  local x = t:put(BIG, 1, "signi_left")
  local sp = t:put(VSP, 0, "hand")
  t:begin(0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:action(ACT_ABILITY, b, 0) == nil, "【貯菌】이 없으면 못 쓴다")
  t:expect(t:answer(t:action(ACT_USE, sp)))
  t:expect(t:wait(HINT_MAIN))
  -- －5000은 《アタックフェイズアイコン》이라 메인 페이즈에는 【貯菌】 2개 능력만
  t:expect(t:answer(t:action(ACT_ABILITY, b, 0)))
  t:expect(t:wait(HINT_TARGET) and t:answer(x))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(x, 1, "trash"), "트래시")
  t:expect(t:action(ACT_ABILITY, b, 0) == nil, "【貯菌】 1개: 2개 능력은 못 쓴다")
end)

case("鎧終一触: 대상 시그니를 《サーバント　ＺＥＲＯ》로(파워 1000, 레벨 1)", "WX17-005", function(t)
  wd(t, CARN4)
  local arts = t:put(N[5], 0, "lrig_deck")
  t:put(RS, 0, "ena")
  local x = t:put(BIG, 1, "signi_left")
  t:begin(0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:answer(t:action(ACT_USE, arts)))
  t:step()
  while t:request().hint ~= HINT_MAIN do
    local r = t:request()
    if r.hint == HINT_TARGET then t:expect(t:answer(x)) elseif r.hint == HINT_BET then t:expect(t:answer(0)) else t:expect(t:answer(table.unpack(r.options, 1, r.min))) end
    t:step()
  end
  t:expect(t:power(x) == 1000 and t:level(x) == 1, "파워 " .. t:power(x) .. " 레벨 " .. t:level(x))
end)
