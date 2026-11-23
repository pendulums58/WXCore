-- WD07 イオナ 구축덱 카드 스크립트 케이스. 근거는 카드별 FAQ(cards.json)

local N = {}

-- 100: 흑 ＜古代兵器＞ 레벨 1(덱), 101: 상대 시그니(파워 3000), 102: 흰 시그니(레벨 1), 103: 흑 시그니(레벨 2)
local function wd(t, center_no)
  t:start{db = true, seed = 1}
  for i = 1, 18 do
    local no = ("%03d"):format(i)
    N[no] = t:no("WD07-" .. no)
  end
  t:card{cid = 100, power = 1000, level = 1, classes = {"精械：古代兵器"}, color = COLOR_BLACK}
  t:card{cid = 101, power = 3000, level = 1, classes = {"奏羅：宇宙"}, color = COLOR_WHITE}
  t:card{cid = 102, power = 1000, level = 1, classes = {"精械：迷宮"}, color = COLOR_WHITE}
  t:card{cid = 103, power = 2000, level = 2, classes = {"精械：古代兵器"}, color = COLOR_BLACK}
  t:fill(100, 0, "main_deck", 10)
  t:fill(101, 1, "main_deck", 10)
  t:fill(101, 0, "life_cloth", 5)
  t:fill(101, 1, "life_cloth", 5)
  local center = t:put(N[center_no or "001"], 0, "lrig_center")
  t:put(t:no("WXDi-D01-004"), 1, "lrig_center")  -- 상대 센터 Lv3
  return center
end

local function main(t, p)
  t:begin(p or 0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
end

local function ena(t, n, cid)
  for _ = 1, n do t:put(cid or 100, 0, "ena") end
  return t:cards(0, "ena")
end

-- ── 001~004 イオナ 공통 ──

case("D07-004: 상대 시그니는 어택할 수 있으면 해야 한다. 다운된 시그니는 하지 않아도 된다", "WD07-004 FAQ 1", function(t)
  wd(t, "004")
  local a = t:put(101, 1, "signi_left")
  local b = t:put(101, 1, "signi_right")
  t:begin(1, PHASE_ATTACK)
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(not t:answer(), "어택 끝내기 거부")
  t:expect(t:answer(a))
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(not t:answer())
  t:expect(t:answer(b))
  t:expect(t:wait(HINT_ATTACK_LRIG), "모두 다운되면 루리그 어택으로")
end)

case("D07-001: 내 장에 흰·검은 시그니가 있는 동안만 상대 시그니 －2000", "WD07-001", function(t)
  wd(t, "001")
  local o = t:put(101, 1, "signi_left")
  t:put(102, 0, "signi_left")
  t:expect(t:power(o) == 3000)
  t:put(103, 0, "signi_center")
  t:expect(t:power(o) == 1000)
end)

case("D07-001: 【起】《黒》 패의 흰·검은 시그니를 1장씩 버려 상대 시그니를 트래시에", "WD07-001", function(t)
  local center = wd(t, "001")
  local o = t:put(101, 1, "signi_left")
  local w = t:put(102, 0, "hand")
  local w2 = t:put(102, 0, "hand")
  local k = t:put(103, 0, "hand")
  local e = ena(t, 1)
  main(t)
  t:expect(t:answer(t:action(ACT_ABILITY, center)))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(e[1]))
  t:expect(t:wait(HINT_DISCARD))
  t:expect(not t:answer(w, w2), "흰 시그니 2장은 안 된다")
  t:expect(t:answer(w, k))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(o))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(o, 1, "trash") and t:is_in(w, 0, "trash") and t:is_in(k, 0, "trash") and t:is_in(w2, 0, "hand"))
end)

case("D07-003: 흰·검은 시그니가 있으면 내 시그니 ＋1000", "WD07-003", function(t)
  wd(t, "003")
  local w = t:put(102, 0, "signi_left")
  t:expect(t:power(w) == 1000)
  local k = t:put(103, 0, "signi_center")
  t:expect(t:power(w) == 2000 and t:power(k) == 3000)
end)

case("D07-002: 【出】《黒》 처리할 때 장에 있는 상대 시그니만 －2000", "WD07-002 FAQ 1", function(t)
  wd(t, "003")
  local pale = t:put(N["002"], 0, "lrig_deck")
  local o = t:put(101, 1, "signi_left")
  local e = {t:put(100, 0, "ena"), t:put(102, 0, "ena"), t:put(100, 0, "ena")}
  t:begin(0, PHASE_GROW)
  t:expect(t:wait(HINT_GROW))
  t:expect(t:answer(pale))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(e[1], e[2]))
  t:expect(t:wait(HINT_USE_TRIGGER))
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(e[3]))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:power(o) == 1000)
  local o2 = t:put(101, 1, "signi_right")
  t:expect(t:power(o2) == 3000, "나중에 나온 시그니는 그대로")
end)

-- ── 009 コードメイズ 금자탑 ──

case("D07-009: 상대가 시그니를 놓을 때 이 시그니의 정면이 비어 있으면 거기만", "WD07-009 FAQ 1", function(t)
  wd(t, "001")
  t:put(N["009"], 0, "signi_center")
  local h = t:put(101, 1, "hand")
  main(t, 1)
  t:expect(t:action(ACT_PLAY, h, "signi_left") == nil, "왼쪽 거부")
  t:expect(t:action(ACT_PLAY, h, "signi_right") == nil, "오른쪽 거부")
  t:expect(t:answer(t:action(ACT_PLAY, h, "signi_center")), "정면만")
end)

case("D07-009: 정면이 차 있으면 어디든", "WD07-009", function(t)
  wd(t, "001")
  t:put(N["009"], 0, "signi_center")
  t:put(101, 1, "signi_center")
  local h = t:put(101, 1, "hand")
  main(t, 1)
  t:expect(t:action(ACT_PLAY, h, "signi_left") ~= nil and t:action(ACT_PLAY, h, "signi_right") ~= nil)
end)

case("D07-009: 【起】《ダウン》 위 3장 중 흰·검은 시그니 1장을 패에, 나머지는 순서대로 덱 위에", "WD07-009 FAQ 2", function(t)
  wd(t, "001")
  local m = t:put(N["009"], 0, "signi_left")
  local deck = t:cards(0, "main_deck")
  local a, b, c = deck[#deck], deck[#deck - 1], deck[#deck - 2]
  main(t)
  t:expect(t:answer(t:action(ACT_ABILITY, m)))
  t:expect(t:wait(HINT_SELECT))
  t:expect(t:answer(a))
  t:expect(t:wait(HINT_ORDER))
  t:expect(t:answer(c, b))
  t:expect(t:wait(HINT_MAIN))
  deck = t:cards(0, "main_deck")
  t:expect(t:is_in(a, 0, "hand") and deck[#deck] == c and deck[#deck - 1] == b)
end)

-- ── 010 コードメイズ 바벨 ──

case("D07-010: 패가 0장이면 【起】를 쓸 수 없다", "WD07-010 FAQ 2", function(t)
  wd(t, "001")
  local m = t:put(N["010"], 0, "signi_left")
  main(t)
  t:expect(t:action(ACT_ABILITY, m) == nil)
end)

-- ── 012 コードアンチ 비마나 ──

case("D07-012: 정면 시그니보다 파워가 낮은 상대 시그니가 어택하면 바니시. 데미지 없음", "WD07-012 FAQ 1", function(t)
  wd(t, "001")
  t:put(N["012"], 0, "signi_center")
  local a = t:put(101, 1, "signi_center")
  t:begin(1, PHASE_ATTACK)
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:answer(a))
  t:expect(t:wait(HINT_ATTACK_LRIG))
  t:expect(t:is_in(a, 1, "ena") and t:count(0, "life_cloth") == 5)
end)

case("D07-012: 정면이 비마나가 아니어도 그 정면 시그니와 비교한다. 정면이 없으면 트리거하지 않는다", "WD07-012", function(t)
  wd(t, "001")
  t:put(N["012"], 0, "signi_left")
  t:put(103, 0, "signi_center")  -- 2000
  local a = t:put(101, 1, "signi_center")  -- 3000
  t:begin(1, PHASE_ATTACK)
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:answer(a))
  t:expect(t:wait(HINT_ATTACK_LRIG))
  t:expect(t:is_in(a, 1, "signi_center"), "3000 ≥ 2000이라 그대로")
end)

case("D07-012: 【出】《黒》 레벨이 다른 ＜古代兵器＞ 4장을 덱 아래로 돌리면 －10000. 0장이나 4장만", "WD07-012 FAQ 4", function(t)
  wd(t, "001")
  local v = t:put(N["012"], 0, "hand")
  local o = t:put(101, 1, "signi_left")
  local tr = {t:put(100, 0, "trash"), t:put(103, 0, "trash"), t:put(N["013"], 0, "trash"), t:put(N["012"], 0, "trash")}
  local e = ena(t, 1)
  main(t)
  t:expect(t:answer(t:action(ACT_PLAY, v, "signi_left")))
  t:expect(t:wait(HINT_USE_TRIGGER))
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(e[1]))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(o))
  t:expect(t:wait(HINT_SELECT))
  t:expect(not t:answer(tr[1], tr[2]), "2장은 안 된다")
  t:expect(t:answer(table.unpack(tr)))
  t:expect(t:wait(HINT_ORDER))
  t:expect(t:answer(table.unpack(tr)))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "trash") == 1 and t:count(0, "main_deck") == 14, "에나 1장만 트래시, 4장은 덱 아래")
  t:expect(t:is_in(o, 1, "ena"), "－10000으로 0 이하가 되어 바니시")
end)

-- ── 013~015 기본 파워 ──

case("D07-013·014·015: 다른 ＜古代兵器＞가 있으면 기본 파워가 바뀐다", "WD07-013, WD07-014, WD07-015", function(t)
  wd(t, "004")
  local i = t:put(N["013"], 0, "signi_left")
  t:expect(t:power(i) == 8000)
  local m = t:put(N["014"], 0, "signi_center")
  local c = t:put(N["015"], 0, "signi_right")
  t:expect(t:power(i) == 12000 and t:power(m) == 8000 and t:power(c) == 5000)
end)

-- ── 006 グレイブ・ナイト ──

case("D07-006: 덱에서 레벨이 다른 시그니 3장까지 트래시에", "WD07-006", function(t)
  wd(t, "001")
  local arts = t:put(N["006"], 0, "lrig_deck")
  local lv2 = t:put(103, 0, "main_deck")
  local e = ena(t, 1)
  main(t)
  t:expect(t:answer(t:action(ACT_USE, arts)))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(e[1]))
  t:expect(t:wait(HINT_SELECT))
  local deck = t:cards(0, "main_deck")
  local lv1a, lv1b
  for _, x in ipairs(deck) do
    if x ~= lv2 then if lv1a then lv1b = lv1b or x else lv1a = x end end
  end
  t:expect(not t:answer(lv1a, lv1b), "같은 레벨 2장은 안 된다")
  t:expect(t:answer(lv1a, lv2))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(lv1a, 0, "trash") and t:is_in(lv2, 0, "trash"))
end)

-- ── 007 ブラック・クライシス ──

case("D07-007: 위 4장을 트래시에. 검은 카드가 있으면 트래시의 검은 시그니를 패에(방금 놓은 것도)", "WD07-007", function(t)
  wd(t, "001")
  local arts = t:put(N["007"], 0, "lrig_deck")
  local e = {t:put(100, 0, "ena"), t:put(102, 0, "ena")}
  main(t)
  t:expect(t:answer(t:action(ACT_USE, arts)))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(e[1], e[2]))
  t:expect(t:wait(HINT_TARGET))
  local x = t:cards(0, "trash")
  t:expect(t:answer(x[#x]))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "hand") == 1 and t:count(0, "main_deck") == 6)
end)

-- ── 018 スラッシュ・ミラクル ──

case("D07-018: 모드는 선언 때. ② 상대 시그니 －8000", "WD07-018 FAQ 1", function(t)
  wd(t, "004")
  local sp = t:put(N["018"], 0, "hand")
  local o = t:put(101, 1, "signi_left")
  local e = {t:put(103, 0, "ena"), t:put(102, 0, "ena")}
  main(t)
  t:expect(t:answer(t:action(ACT_USE, sp)))
  t:expect(t:wait(HINT_MODE))
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(table.unpack(e)))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(o))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(o, 1, "ena"))
end)
