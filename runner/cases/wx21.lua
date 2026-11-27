-- WX21 부스터 카드 스크립트 케이스(감염 상태 시그니가 바니시되면 트래시, ＜天使＞ 색 종류 조건). 근거는 카드별 FAQ(cards.json)

local WS, OPP, SP = 200000, 101000, 300191
local NANA5, TAW4 = 300190, 300192

local function wd(t, lrig)
  t:start{db = true, seed = 1}
  t:signi(WS, 1000, COLOR_WHITE, 1)
  t:signi(OPP, 3000, COLOR_GREEN, 1)
  t:lrig(NANA5, 5, 12, {"ナナシ"}, COLOR_BLACK)
  t:lrig(TAW4, 4, 11, {"タウィル"}, COLOR_RED)
  t:card{cid = SP, type = TYPE_SPELL, color = COLOR_BLACK}
  t:script(SP, [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil)
    if g:GetCount()>0 then Duel.Banish(g) end
  end)
  c:RegisterEffect(e1)
end]])
  t:fill(WS, 0, "main_deck", 15)
  t:fill(OPP, 1, "main_deck", 15)
  t:fill(WS, 0, "life_cloth", 5)
  t:fill(OPP, 1, "life_cloth", 5)
  t:put(NANA5, 1, "lrig_center")
  return t:put(lrig or t:no("WX21-005"), 0, "lrig_center")
end

case("ナナシ 其ノ後: 상대의 감염 상태인 시그니가 바니시되면 트래시에", "WX21-005", function(t)
  wd(t)
  local a, b = t:put(OPP, 1, "signi_left"), t:put(OPP, 1, "signi_center")
  t:place_virus(1, "signi_left")
  local sp = t:put(SP, 0, "hand")
  t:begin(0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:answer(t:action(ACT_USE, sp)))
  t:step()
  while t:request().hint ~= HINT_MAIN do
    local r = t:request()
    t:expect(t:answer(table.unpack(r.options, 1, r.min)) or t:answer(t:action(ACT_END)))
    t:step()
  end
  t:expect(t:is_in(a, 1, "trash") and t:is_in(b, 1, "ena"), ("감염만 트래시 a=%s b=%s inf=%s"):format(tostring(t:is_in(a,1,"ena")), tostring(t:is_in(b,1,"ena")), tostring(t:virus(1,"signi_left"))))
end)

case("神技の鞭刑 ≡アナフィエル≡: ＜天使＞의 색이 2종류 이상이면 바니시", "WX21-051", function(t)
  for _, two in ipairs{true, false} do
    wd(t, TAW4)
    t:put(t:no("WX21-055"), 0, "signi_left")  -- 青 ＜天使＞
    if not two then t:move(t:cards(0, "signi_left")[1], 0, "trash") end
    local x = t:put(OPP, 1, "signi_center")
    local h = t:put(t:no("WX21-051"), 0, "hand")
    t:begin(0, PHASE_MAIN)
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:answer(t:action(ACT_PLAY, h, "signi_center")))
    t:step()
    while t:request().hint ~= HINT_MAIN do
      local r = t:request()
      t:expect(r.hint == HINT_TARGET and t:answer(x) or t:answer(table.unpack(r.options, 1, r.min)))
      t:step()
    end
    t:expect(t:is_in(x, 1, "signi_center") == not two, two and "바니시" or "남는다")
  end
end)
