-- WD05 ウリス 구축덱 카드 스크립트 케이스. 근거는 카드별 FAQ(cards.json)

local N = {}

-- 100: 검은 시그니(덱·에나·트래시 채우기), 101: 상대 시그니(파워 3000), 102: 상대 시그니(파워 12000)
local function wd(t, center_no, deck_n)
  t:start{db = true, seed = 1}
  for i = 1, 18 do
    local no = ("%03d"):format(i)
    N[no] = t:no("WD05-" .. no)
  end
  t:card{cid = 100, power = 1000, level = 1, classes = {"精像：悪魔"}, color = COLOR_BLACK}
  t:card{cid = 101, power = 3000, level = 1, classes = {"奏羅：宇宙"}, color = COLOR_WHITE}
  t:card{cid = 102, power = 12000, level = 3, classes = {"奏羅：宇宙"}, color = COLOR_WHITE}
  t:fill(100, 0, "main_deck", deck_n or 10)
  t:fill(101, 1, "main_deck", 10)
  t:fill(101, 0, "life_cloth", 5)
  t:fill(101, 1, "life_cloth", 5)
  local center = t:put(N[center_no or "001"], 0, "lrig_center")
  t:put(t:no("WXDi-D01-004"), 1, "lrig_center")  -- 상대 센터 Lv3
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

local function use(t, card, paid)
  main(t)
  t:expect(t:answer(t:action(ACT_USE, card)))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(table.unpack(paid)))
end

local function play(t, card, zone)
  t:expect(t:answer(t:action(ACT_PLAY, card, zone or "signi_left")))
end

local function contains(list, x)
  for _, v in ipairs(list) do if v == x then return true end end
  return false
end

-- 상대가 어택해서 내 라이프 버스트를 띄운다. 어택 안 한 시그니를 하나 남겨 턴이 넘어가지 않게 한다
local function burst(t, card)
  t:put(card, 0, "life_cloth")
  local att = t:put(101, 1, "signi_right")
  t:put(101, 1, "signi_left")
  t:begin(1, PHASE_ATTACK)
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:answer(att))
  t:expect(t:wait(HINT_LIFEBURST))
  t:expect(t:answer(1))
end

-- ── 001 獄卒の閻魔　ウリス ──

case("D05-001: メツム가 있고 트래시 20장 이상이면 내 시그니 ＋2000. 2체여도 한 번", "WD05-001 FAQ 1", function(t)
  wd(t, "001")
  local s = t:put(100, 0, "signi_left")
  local m = t:put(N["009"], 0, "signi_center")
  t:fill(100, 0, "trash", 19)
  t:expect(t:power(s) == 1000, "트래시 19장이면 없다")
  t:put(100, 0, "trash")
  t:expect(t:power(s) == 3000 and t:power(m) == 14000, "트래시 20장")
  t:put(N["009"], 0, "signi_right")
  t:expect(t:power(s) == 3000, "メツム 2체여도 ＋2000")
  wd(t, "001")
  s = t:put(100, 0, "signi_left")
  t:fill(100, 0, "trash", 20)
  t:expect(t:power(s) == 1000, "メツム가 없으면 없다")
end)

-- ── 006 モーメント・パニッシュ / 007 エターナル・パニッシュ / 017 ホール・ダーク ──

case("D05-006·007·017: 상대 시그니 1체 －7000/－15000/－4000. 0 이하면 룰로 바니시되어 에나에", "WD05-006 FAQ 1, WD05-007 FAQ 1, WD05-017 FAQ 1", function(t)
  local function run(no, where, mine_power)
    wd(t, "001")
    local card = t:put(N[no], 0, where)
    local small = t:put(101, 1, "signi_left")
    local big = t:put(102, 1, "signi_center")
    local mine = t:put(100, 0, "signi_left")
    local e = ena(t, 3)
    local cost = {["006"] = 2, ["007"] = 3, ["017"] = 1}
    local paid = {}
    for i = 1, cost[no] do paid[i] = e[i] end
    use(t, card, paid)
    t:expect(t:wait(HINT_TARGET))
    local o = t:request().options
    t:expect(#o == 2 and not contains(o, mine), "상대 시그니만")
    return small, big
  end
  local small, big = run("017", "hand")
  t:expect(t:answer(small))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(small, 1, "ena"), "3000－4000은 바니시")
  small, big = run("006", "lrig_deck")
  t:expect(t:answer(big))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:power(big) == 5000 and t:is_in(big, 1, "signi_center"), "12000－7000")
  small, big = run("007", "lrig_deck")
  t:expect(t:answer(big))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(big, 1, "ena"), "12000－15000은 바니시")
end)

-- ── 008 グレイブ・アウト ──

case("D05-008: 트래시 시그니 3장까지. 2장 이하여도 쓸 수 있고, 코스트로 트래시에 간 시그니도 고를 수 있다", "WD05-008 FAQ 1·2", function(t)
  wd(t, "001")
  local arts = t:put(N["008"], 0, "lrig_deck")
  local tr = t:put(100, 0, "trash")
  local e = ena(t, 5)
  use(t, arts, e)
  t:expect(t:wait(HINT_TARGET))
  local o = t:request().options
  t:expect(#o == 6 and contains(o, e[1]) and contains(o, tr), "트래시 1장 + 코스트 5장")
  t:expect(t:request().min == 0 and t:request().max == 3, "3장까지")
  t:expect(t:answer(tr, e[1]))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(tr, 0, "hand") and t:is_in(e[1], 0, "hand") and t:count(0, "hand") == 2)
end)

-- ── 009 堕落の砲女　メツム ──

case("D05-009: 【出】 두 플레이어가 덱 위 7장을 트래시에", "WD05-009 FAQ 1", function(t)
  wd(t, "001")
  local m = t:put(N["009"], 0, "hand")
  main(t)
  play(t, m)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "trash") == 7 and t:count(0, "main_deck") == 3, "내 덱")
  t:expect(t:count(1, "trash") == 7 and t:count(1, "main_deck") == 3, "상대 덱")
end)

case("D05-009: 덱이 7장 미만이면 전부 놓고 효과가 끝난 뒤 리프레시", "WD05-009 FAQ 3", function(t)
  wd(t, "001", 2)
  local m = t:put(N["009"], 0, "hand")
  main(t)
  play(t, m)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "main_deck") > 0, "리프레시로 덱이 돌아온다")
  t:expect(t:count(1, "trash") == 7, "상대는 그대로 7장")
end)

case("D05-009: 라이프 버스트 — 트래시의 카드 1장(시그니가 아니어도)을 패에", "WD05-009", function(t)
  wd(t, "001")
  local sp = t:put(N["017"], 0, "trash")
  local s = t:put(100, 0, "trash")
  burst(t, N["009"])
  t:expect(t:wait(HINT_TARGET))
  local o = t:request().options
  t:expect(contains(o, sp) and contains(o, s), "스펠도 고를 수 있다")
  t:expect(t:answer(sp))
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:is_in(sp, 0, "hand"))
end)

-- ── 011 堕落の砲女　キャリ ──

case("D05-011: 트래시 10장 이상인 동안 ＋5000", "WD05-011", function(t)
  wd(t, "001")
  local k = t:put(N["011"], 0, "signi_left")
  t:fill(100, 0, "trash", 9)
  t:expect(t:power(k) == 7000, "9장")
  t:put(100, 0, "trash")
  t:expect(t:power(k) == 12000, "10장")
end)

case("D05-011: 라이프 버스트 — 1장 뽑는다", "WD05-011", function(t)
  wd(t, "001")
  burst(t, N["011"])
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:count(0, "hand") == 1)
end)

-- ── 014 堕落の砲女　サキュ ──

case("D05-014: 【出】 내 덱 위 3장을 트래시에. 상대 덱은 그대로", "WD05-014", function(t)
  wd(t, "001")
  local sk = t:put(N["014"], 0, "hand")
  main(t)
  play(t, sk)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "trash") == 3 and t:count(0, "main_deck") == 7)
  t:expect(t:count(1, "trash") == 0)
end)

-- ── 018 想起する祝福 ──

case("D05-018: 트래시 시그니 1장을 패에. 코스트로 트래시에 간 시그니도 고를 수 있다. 스펠은 못 고른다", "WD05-018 FAQ 1", function(t)
  wd(t, "001")
  local sp = t:put(N["018"], 0, "hand")
  local other = t:put(N["017"], 0, "trash")
  local e = ena(t, 2)
  use(t, sp, e)
  t:expect(t:wait(HINT_TARGET))
  local o = t:request().options
  t:expect(#o == 2 and contains(o, e[1]) and not contains(o, other))
  t:expect(t:answer(e[2]))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(e[2], 0, "hand"))
end)

case("D05-018: 라이프 버스트 — 트래시 시그니 1장을 패에", "WD05-018", function(t)
  wd(t, "001")
  local s = t:put(100, 0, "trash")
  burst(t, N["018"])
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(s))
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:is_in(s, 0, "hand"))
end)
