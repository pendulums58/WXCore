-- WX18 부스터 카드 스크립트 케이스(상대 센터 루리그 색으로 코스트가 바뀌는 아츠, 【チャーム】 붙은 시그니의 능력 상실). 근거는 카드별 FAQ(cards.json)

local N = {}
local WS, OPP, RS = 200000, 101000, 200002
local RED4, BLUE4, GRN4, MYU5 = 300160, 300161, 300162, 300163

local function wd(t, lrig, p1)
  t:start{db = true, seed = 1}
  for i = 1, 90 do N[i] = t:no(("WX18-%03d"):format(i)) end
  t:signi(WS, 1000, COLOR_WHITE, 1)
  t:signi(RS, 1000, COLOR_RED, 1)
  t:signi(OPP, 3000, COLOR_GREEN, 1)
  t:lrig(RED4, 4, 11, {"花代"}, COLOR_RED)
  t:lrig(BLUE4, 4, 11, {"ピルルク"}, COLOR_BLUE)
  t:lrig(GRN4, 4, 11, {"緑子"}, COLOR_GREEN)
  t:lrig(MYU5, 5, 12, {"ミュウ"}, COLOR_BLACK)
  t:fill(WS, 0, "main_deck", 15)
  t:fill(OPP, 1, "main_deck", 15)
  t:fill(WS, 0, "life_cloth", 5)
  t:fill(OPP, 1, "life_cloth", 5)
  t:put(p1 or GRN4, 1, "lrig_center")
  return t:put(lrig or RED4, 0, "lrig_center")
end

case("燐気応変: 상대 센터가 청·녹이면 《赤×2》로 쓸 수 있다", "WX18-012", function(t)
  for _, opp in ipairs{BLUE4, RED4} do
    wd(t, RED4, opp)
    local arts = t:put(N[12], 0, "lrig_deck")
    for _ = 1, 2 do t:put(RS, 0, "ena") end
    t:begin(0, PHASE_MAIN)
    t:expect(t:wait(HINT_MAIN))
    t:expect((t:action(ACT_USE, arts) ~= nil) == (opp == BLUE4), "에나 2장: 상대가 청색일 때만")
  end
end)

case("特大幻蟲 ヨロズハタヒメ: 【チャーム】이 붙은 상대 시그니는 능력을 잃는다", "WX18-038", function(t)
  wd(t, MYU5)
  t:put(N[38], 0, "signi_center")
  t:put(WS, 0, "signi_left")
  t:put(WS, 0, "signi_right")
  local x = t:put(t:no("WX15-077"), 1, "signi_left")  -- 상대(나) 시그니가 3체면 기본 파워 12000
  t:put(OPP, 1, "signi_center")
  t:put(OPP, 1, "signi_right")
  t:begin(0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:power(x) == 12000, "처음엔 12000 " .. t:power(x))
  t:attach(t:put(WS, 1, "main_deck"), x, "charm")
  t:step()
  t:expect(t:power(x) == 8000, "【チャーム】이 붙으면 능력 상실 " .. t:power(x))
end)
