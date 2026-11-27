-- WX22 부스터 카드 스크립트 케이스(표기된 파워와 다른 시그니, 루리그 트래시의 아츠 수로 코스트 감소). 근거는 카드별 FAQ(cards.json)

local WS, OPP, RS = 200000, 101000, 200002
local LV4, BK = 300200, 200004

local function wd(t)
  t:start{db = true, seed = 1}
  t:signi(WS, 1000, COLOR_WHITE, 1)
  t:signi(RS, 1000, COLOR_RED, 1)
  t:signi(BK, 1000, COLOR_BLACK, 1)
  t:signi(OPP, 3000, COLOR_GREEN, 1)
  t:lrig(LV4, 4, 11, {"ハナレ"}, COLOR_BLACK)
  t:fill(WS, 0, "main_deck", 15)
  t:fill(OPP, 1, "main_deck", 15)
  t:fill(WS, 0, "life_cloth", 5)
  t:fill(OPP, 1, "life_cloth", 5)
  t:put(LV4, 1, "lrig_center")
  return t:put(LV4, 0, "lrig_center")
end

case("ツヴァイ＝ラボナ: 표기된 파워와 다른 파워의 시그니만 대상", "WX22-047", function(t)
  wd(t)
  local a, b = t:put(OPP, 1, "signi_left"), t:put(OPP, 1, "signi_center")
  t:single(a, EFFECT_UPDATE_POWER, 1000, 1)
  local h = t:put(t:no("WX22-047"), 0, "hand")
  t:begin(0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:answer(t:action(ACT_PLAY, h, "signi_left")))
  t:expect(t:wait(HINT_TARGET))
  local o = t:request().options
  t:expect(#o == 1 and o[1] == a, "파워가 바뀐 시그니만")
end)

case("全戦全焼: 루리그 트래시의 아츠 1장당 《赤×1》《無×1》 줄어든다", "WX22-004", function(t)
  for _, n in ipairs{7, 6} do
    wd(t)
    local arts = t:put(t:no("WX22-004"), 0, "lrig_deck")
    for _ = 1, n do t:put(t:no("WX15-011"), 0, "lrig_trash") end  -- 炎芒一閃(아츠)
    t:begin(0, PHASE_MAIN)
    t:expect(t:wait(HINT_MAIN))
    t:expect((t:action(ACT_USE, arts) ~= nil) == (n == 7), "에나 0장: 아츠 7장이면 쓸 수 있다")
  end
end)
