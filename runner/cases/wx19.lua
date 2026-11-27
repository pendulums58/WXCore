-- WX19 부스터 카드 스크립트 케이스(「盾」 이름 조건, 정해진 레벨 【ガード】 금지). 근거는 카드별 FAQ(cards.json)

local N = {}
local WS, OPP, RS = 200000, 101000, 200002
local TAMA4 = 300170

local function wd(t)
  t:start{db = true, seed = 1}
  for i = 1, 80 do N[i] = t:no(("WX19-%03d"):format(i)) end
  t:signi(WS, 1000, COLOR_WHITE, 1)
  t:signi(RS, 1000, COLOR_RED, 1)
  t:signi(OPP, 3000, COLOR_GREEN, 1)
  t:lrig(TAMA4, 4, 11, {"タマ"}, COLOR_WHITE)
  t:fill(WS, 0, "main_deck", 15)
  t:fill(OPP, 1, "main_deck", 15)
  t:fill(WS, 0, "life_cloth", 5)
  t:fill(OPP, 1, "life_cloth", 5)
  t:put(TAMA4, 1, "lrig_center")
  return t:put(TAMA4, 0, "lrig_center")
end

case("小盾 ハヤト: 덱 위 2장 중 카드명에 《盾》를 포함한 시그니를 패에", "WX19-049", function(t)
  wd(t)
  local h = t:put(N[49], 0, "hand")
  local shield = t:put(N[48], 0, "main_deck")  -- 中盾 ティンベー
  main = function() t:begin(0, PHASE_MAIN) t:expect(t:wait(HINT_MAIN)) end
  main()
  t:expect(t:answer(t:action(ACT_PLAY, h, "signi_left")))
  t:step()
  while t:request().hint ~= HINT_MAIN do
    local r = t:request()
    if r.hint == HINT_SELECT then t:expect(t:answer(shield)) else t:expect(t:answer(table.unpack(r.options, 1, r.min))) end
    t:step()
  end
  t:expect(t:is_in(shield, 0, "hand"), "《盾》 시그니를 패에")
end)
