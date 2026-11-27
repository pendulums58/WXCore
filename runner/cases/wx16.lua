-- WX16 부스터 카드 스크립트 케이스(【レイヤー】 중첩, 【ウィルス】·＜微菌＞로 코스트 감소). 근거는 카드별 FAQ(cards.json)

local N = {}
local WS, OPP, BK = 200000, 101000, 200004
local LV4 = 300140

local function wd(t)
  t:start{db = true, seed = 1}
  for i = 1, 80 do N[i] = t:no(("WX16-%03d"):format(i)) end
  t:signi(WS, 1000, COLOR_WHITE, 1)
  t:signi(BK, 1000, COLOR_BLACK, 1)
  t:signi(OPP, 3000, COLOR_GREEN, 1)
  t:lrig(LV4, 4, 11, {"ドーナ"}, COLOR_WHITE)
  t:fill(WS, 0, "main_deck", 15)
  t:fill(OPP, 1, "main_deck", 15)
  t:fill(WS, 0, "life_cloth", 5)
  t:fill(OPP, 1, "life_cloth", 5)
  t:put(LV4, 1, "lrig_center")
  return t:put(LV4, 0, "lrig_center")
end

case("幻怪 コナキ: 3체면 각자 【レイヤー】 능력을 3개 가져 ＋6000", "WX16-049 FAQ 1", function(t)
  wd(t)
  local a = t:put(N[49], 0, "signi_left")
  local b = t:put(N[49], 0, "signi_center")
  local c = t:put(N[49], 0, "signi_right")
  t:begin(0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:power(a) == 13000 and t:power(b) == 13000 and t:power(c) == 13000, "파워 " .. t:power(a))
end)

case("ラスト・フェアエル: ＜微菌＞ 1체·【ウィルス】 1개당 《黒×1》 줄어든다", "WX16-033 FAQ 1", function(t)
  for _, ena in ipairs{2, 3} do
    wd(t)
    local sp = t:put(N[33], 0, "hand")
    for _, z in ipairs{"signi_left", "signi_center", "signi_right"} do
      t:put(N[80], 0, z)  -- ＜微菌＞
      t:place_virus(1, z)
    end
    for _ = 1, ena do t:put(BK, 0, "ena") end
    t:begin(0, PHASE_MAIN)
    t:expect(t:wait(HINT_MAIN))
    t:expect((t:action(ACT_USE, sp) ~= nil) == (ena == 3), "《黒》×3이면 쓸 수 있다: 에나 " .. ena)
  end
end)
