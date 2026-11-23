-- WD08 ウムル 구축덱 카드 스크립트 케이스. 근거는 카드별 FAQ(cards.json)

local N = {}

-- 100: 흑 ＜古代兵器＞ 레벨 1, 101: 상대 시그니(파워 3000), 103: 흑 ＜古代兵器＞ 레벨 2
local function wd(t, center_no)
  t:start{db = true, seed = 1}
  for i = 1, 18 do
    local no = ("%03d"):format(i)
    N[no] = t:no("WD08-" .. no)
  end
  t:card{cid = 100, power = 1000, level = 1, classes = {"精械：古代兵器"}, color = COLOR_BLACK}
  t:card{cid = 101, power = 3000, level = 1, classes = {"奏羅：宇宙"}, color = COLOR_WHITE}
  t:card{cid = 103, power = 2000, level = 2, classes = {"精械：古代兵器"}, color = COLOR_BLACK}
  t:fill(100, 0, "main_deck", 10)
  t:fill(101, 1, "main_deck", 10)
  t:fill(101, 0, "life_cloth", 5)
  t:fill(101, 1, "life_cloth", 5)
  local center = t:put(N[center_no or "001"], 0, "lrig_center")
  t:put(t:no("WXDi-D01-004"), 1, "lrig_center")
  return center
end

local function main(t)
  t:begin(0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
end

local function ena(t, n)
  for _ = 1, n do t:put(100, 0, "ena") end
  return t:cards(0, "ena")
end

-- 카드의 【起】 중 n번째(등록 순서, 0부터)
local function abil(t, card, n)
  return t:action(ACT_ABILITY, card, n)
end

-- ── 001 ウムル＝フィーラ ──

case("D08-001: 【起】《ターン１回》 덱 위 3장을 트래시에. 덱이 2장이면 전부", "WD08-001 FAQ 3·4", function(t)
  local center = wd(t, "001")
  main(t)
  t:expect(t:answer(abil(t, center, 0)))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "trash") == 3 and t:count(0, "main_deck") == 7)
  t:expect(abil(t, center, 1) == nil, "턴 1회: 남은 【起】는 다운 하나")
end)

case("D08-001: 【起】《ダウン》 트래시의 시그니를 장에", "WD08-001", function(t)
  local center = wd(t, "001")
  local x = t:put(103, 0, "trash")
  main(t)
  t:expect(t:answer(abil(t, center, 1)))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(x))
  if t:wait(HINT_ZONE) then t:answer(t:request().options[1]) end
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(x, 0, "signi_left") or t:is_in(x, 0, "signi_center") or t:is_in(x, 0, "signi_right"))
end)

case("D08-001: 【出】 트래시 시그니의 다음 【起】 코스트가 없어진다. 한 번만", "WD08-001 FAQ 1·3", function(t)
  wd(t, "002")
  local fira = t:put(N["001"], 0, "lrig_deck")
  local neb = t:put(N["010"], 0, "trash")
  ena(t, 3)
  t:begin(0, PHASE_GROW)
  t:expect(t:wait(HINT_GROW))
  t:expect(t:answer(fira))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(table.unpack(t:cards(0, "ena"))))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(neb))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "ena") == 0, "에나 없음")
  t:expect(t:answer(t:action(ACT_ABILITY, neb)), "코스트 없이 쓸 수 있다")
  t:expect(t:wait(HINT_ZONE))
  t:expect(t:answer(t:request().options[1]))
  t:expect(t:wait(HINT_MAIN))
  t:expect(not t:is_in(neb, 0, "trash"))
end)

-- ── 009 ネッシー ──

case("D08-009: 트래시에서 시그니가 나오면 《黒》《黒》을 내고 상대 시그니 바니시", "WD08-009 FAQ 1", function(t)
  wd(t, "001")
  t:put(N["009"], 0, "signi_left")
  local dig = t:put(N["007"], 0, "lrig_deck")
  local x = t:put(100, 0, "trash")
  local o = t:put(101, 1, "signi_center")
  local e = ena(t, 3)
  main(t)
  t:expect(t:answer(t:action(ACT_USE, dig)))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(e[1]))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(x))
  t:expect(t:wait(HINT_ZONE))
  t:expect(t:answer(t:request().options[1]))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(o))
  t:expect(t:wait(HINT_SCRIPT))
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(e[2], e[3]))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(o, 1, "ena"))
end)

case("D08-009: 【起】는 트래시에 있을 때만. －8000 후 덱 아래로", "WD08-009 FAQ 4", function(t)
  wd(t, "001")
  local n = t:put(N["009"], 0, "hand")
  local o = t:put(101, 1, "signi_center")
  ena(t, 3)
  main(t)
  t:expect(t:action(ACT_ABILITY, n) == nil, "패에서는 못 쓴다")
  wd(t, "001")
  n = t:put(N["009"], 0, "trash")
  o = t:put(101, 1, "signi_center")
  ena(t, 3)
  main(t)
  t:expect(t:answer(t:action(ACT_ABILITY, n)), "트래시에서")
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(table.unpack(t:cards(0, "ena"))))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(o))
  t:expect(t:wait(HINT_MAIN))
  local deck = t:cards(0, "main_deck")
  t:expect(t:is_in(o, 1, "ena") and deck[1] == n, "덱 맨 아래")
end)

-- ── 010 ネビュラ ──

case("D08-010: 에나에 있으면 선언할 수 없다. 트래시에서 《黒》《黒》로 장에", "WD08-010 FAQ 1", function(t)
  wd(t, "002")
  local nb = t:put(N["010"], 0, "ena")
  ena(t, 2)
  main(t)
  t:expect(t:action(ACT_ABILITY, nb) == nil)
  wd(t, "002")
  nb = t:put(N["010"], 0, "trash")
  ena(t, 2)
  main(t)
  t:expect(t:answer(t:action(ACT_ABILITY, nb)))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(table.unpack(t:cards(0, "ena"))))
  t:expect(t:wait(HINT_ZONE))
  t:expect(t:answer(t:request().options[1]))
  t:expect(t:wait(HINT_MAIN))
  t:expect(not t:is_in(nb, 0, "trash") and t:count(0, "ena") == 0)
end)

-- ── 012 アステカ ──

case("D08-012: 레벨 1 ＜古代兵器＞를 트래시에서 내고, 턴 끝에 트래시에", "WD08-012", function(t)
  wd(t, "002")
  local az = t:put(N["012"], 0, "hand")
  local x = t:put(100, 0, "trash")
  main(t)
  t:expect(t:answer(t:action(ACT_PLAY, az, "signi_left")))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(x))
  t:expect(t:wait(HINT_ZONE))
  t:expect(t:answer(t:request().options[1]))
  t:expect(t:wait(HINT_MAIN))
  t:expect(not t:is_in(x, 0, "trash"))
  t:expect(t:answer(t:action(ACT_END)))
  t:expect(t:wait(HINT_MAIN), "상대 턴")
  t:expect(t:is_in(x, 0, "trash") and not t:is_in(az, 0, "trash"), "턴 끝에 그 시그니만 트래시")
end)

-- ── 013 カブレラ ──

case("D08-013: 트래시에 ＜古代兵器＞ 3장 이상이면 기본 파워 8000", "WD08-013", function(t)
  wd(t, "004")
  local k = t:put(N["013"], 0, "signi_left")
  t:put(100, 0, "trash"); t:put(100, 0, "trash")
  t:expect(t:power(k) == 5000)
  t:put(100, 0, "trash")
  t:expect(t:power(k) == 8000)
end)

-- ── 014 テキサハンマ ──

case("D08-014: 덱에서 트래시에 놓이면 장에 내도 된다. 패에서 버려지면 아니다", "WD08-014", function(t)
  local fira = wd(t, "001")
  local th = t:put(N["014"], 0, "main_deck")
  main(t)
  t:expect(t:answer(abil(t, fira, 0)))
  t:expect(t:wait(HINT_SCRIPT))
  t:expect(t:answer(1))
  if t:wait(HINT_ZONE) then t:answer(t:request().options[1]) end
  t:expect(t:wait(HINT_MAIN))
  t:expect(not t:is_in(th, 0, "trash") and not t:is_in(th, 0, "main_deck"), "장에 나왔다")
end)

-- ── 015 ヴォイニ ──

case("D08-015: 덱 위 3장이 모두 ＜古代兵器＞ 시그니면 1장 뽑는다", "WD08-015", function(t)
  wd(t, "004")
  local v = t:put(N["015"], 0, "signi_left")
  main(t)
  t:expect(t:answer(t:action(ACT_ABILITY, v)))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "trash") == 3 and t:count(0, "hand") == 1)
end)

-- ── 018 グレイブ・ペイン ──

case("D08-018: 내 시그니를 바니시하면 덱 위 5장을 트래시에", "WD08-018", function(t)
  wd(t, "004")
  local sp = t:put(N["018"], 0, "hand")
  local m = t:put(103, 0, "signi_left")
  main(t)
  t:expect(t:answer(t:action(ACT_USE, sp)))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(m))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(m, 0, "ena") and t:count(0, "main_deck") == 5)
end)
