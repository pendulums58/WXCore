-- WX20 부스터 카드 스크립트 케이스(에나 장수로 레벨·파워가 오르는 시그니, 레벨 조건으로 코스트가 바뀌는 아츠). 근거는 카드별 FAQ(cards.json)

local WS, OPP = 200000, 101000
local LV4, LV5, SV = 300180, 300181, 100

local function wd(t, lrig, p1)
  t:start{db = true, seed = 1}
  t:signi(WS, 1000, COLOR_WHITE, 1)
  t:signi(OPP, 3000, COLOR_GREEN, 1)
  t:lrig(LV4, 4, 11, {"緑子"}, COLOR_GREEN)
  t:lrig(LV5, 5, 12, {"緑子"}, COLOR_GREEN)
  t:fill(WS, 0, "main_deck", 15)
  t:fill(OPP, 1, "main_deck", 15)
  t:fill(WS, 0, "life_cloth", 5)
  t:fill(OPP, 1, "life_cloth", 5)
  t:put(p1 or LV4, 1, "lrig_center")
  return t:put(lrig or LV4, 0, "lrig_center")
end

case("幻獣 アカズキン: 에나 5장당 레벨 ＋1, 레벨 1당 파워 ＋3000", "WX20-Re18", function(t)
  wd(t)
  local a = t:put(t:no("WX20-Re18"), 0, "signi_left")
  for _ = 1, 10 do t:put(WS, 0, "ena") end
  t:begin(0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:level(a) == 4 and t:power(a) == 1000 + 4 * 3000, "레벨 " .. t:level(a) .. " 파워 " .. t:power(a))
end)

case("サティスファクション: 내 센터 레벨 4 이하·상대 5 이상이면 《無×1》", "WX20-020", function(t)
  for _, opp in ipairs{LV5, LV4} do
    wd(t, LV4, opp)
    local arts = t:put(t:no("WX20-020"), 0, "lrig_deck")
    t:put(WS, 0, "ena")
    t:begin(0, PHASE_MAIN)
    t:expect(t:wait(HINT_MAIN))
    t:expect((t:action(ACT_USE, arts) ~= nil) == (opp == LV5), "에나 1장: 상대 레벨 5일 때만")
  end
end)
