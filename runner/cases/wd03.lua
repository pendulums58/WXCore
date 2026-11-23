-- WD03 ピルルク 구축덱 카드 스크립트 케이스. 근거는 카드별 FAQ(cards.json)

local N = {}

-- 100: 파란 시그니(덱 채우기·에나), 101: 상대 시그니(레벨 1), 102: 상대 시그니(레벨 2), 103: 상대 스펠(레벨 없음)
local function wd(t, center_no)
  t:start{db = true, seed = 1}
  for i = 1, 18 do
    local no = ("%03d"):format(i)
    N[no] = t:no("WD03-" .. no)
  end
  t:card{cid = 100, power = 1000, level = 1, classes = {"精械：電機"}, color = COLOR_BLUE}
  t:card{cid = 101, power = 3000, level = 1, classes = {"奏羅：宇宙"}, color = COLOR_WHITE}
  t:card{cid = 102, power = 5000, level = 2, classes = {"奏羅：宇宙"}, color = COLOR_WHITE}
  t:card{cid = 103, type = TYPE_SPELL, color = COLOR_WHITE}
  t:fill(100, 0, "main_deck", 10)
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

local function use(t, card, n)
  local paid = ena(t, n)
  main(t)
  t:expect(t:answer(t:action(ACT_USE, card)))
  if n > 0 then
    t:expect(t:wait(HINT_PAY_ENA))
    t:expect(t:answer(table.unpack(paid)))
  end
end

local function play(t, card)
  t:expect(t:answer(t:action(ACT_PLAY, card, "signi_left")))
end

-- ── 001 コード・ピルルク・Ｔ ──

case("D03-001: 《コードアート　Ｒ・Ｍ・Ｎ》가 있고 상대 패가 1장 이하인 동안 내 시그니 ＋2000", "WD03-001", function(t)
  wd(t, "001")
  local s = t:put(100, 0, "signi_left")
  local rmn = t:put(N["009"], 0, "signi_center")
  t:put(101, 1, "hand")
  main(t)
  t:expect(t:power(s) == 3000 and t:power(rmn) == 14000, "상대 패 1장")
  wd(t, "001")
  s = t:put(100, 0, "signi_left")
  t:put(N["009"], 0, "signi_center")
  t:put(101, 1, "hand")
  t:put(101, 1, "hand")
  main(t)
  t:expect(t:power(s) == 1000, "상대 패 2장이면 없다")
  wd(t, "001")
  s = t:put(100, 0, "signi_left")
  main(t)
  t:expect(t:power(s) == 1000, "R・M・N이 없으면 상대 패 0장이어도 없다")
end)

-- ── 006 ピーピング・アナライズ ──

case("D03-006: 숫자를 선언하고 상대 패를 본 뒤, 그 레벨의 시그니를 모두 버리게 한다", "WD03-006 FAQ 3", function(t)
  wd(t, "001")
  local arts = t:put(N["006"], 0, "lrig_deck")
  local l1 = t:put(101, 1, "hand")
  local l2a = t:put(102, 1, "hand")
  local l2b = t:put(102, 1, "hand")
  local sp = t:put(103, 1, "hand")
  use(t, arts, 3)
  t:expect(t:wait(HINT_DECLARE))
  t:expect(t:request().player == 0)
  t:expect(t:answer(2))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:can_see(0, l1) and t:can_see(0, sp), "상대 패를 본다")
  t:expect(t:is_in(l2a, 1, "trash") and t:is_in(l2b, 1, "trash"), "레벨 2 시그니는 전부")
  t:expect(t:is_in(l1, 1, "hand") and t:is_in(sp, 1, "hand"))
end)

-- ── 008 ドロー・ツー ──

case("D03-008: 카드를 2장 뽑는다. 덱이 1장이면 1장만 뽑고 끝", "WD03-008 FAQ 2", function(t)
  wd(t, "001")
  local arts = t:put(N["008"], 0, "lrig_deck")
  use(t, arts, 2)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "hand") == 2 and t:is_in(arts, 0, "lrig_trash"))
  wd(t, "001")
  arts = t:put(N["008"], 0, "lrig_deck")
  for _, c in ipairs(t:cards(0, "main_deck")) do t:move(c, 0, "trash") end
  t:put(100, 0, "main_deck")
  use(t, arts, 2)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "hand") == 1 and t:is_in(arts, 0, "lrig_trash"), "2장째는 뽑지 않는다")
end)

-- ── 009 コードアート　Ｒ・Ｍ・Ｎ ──

case("D03-009: 【出】《青》 — 내면 상대 패를 보지 않고 1장 골라 버리게 한다", "WD03-009 FAQ 3·4", function(t)
  wd(t, "001")
  local paid = ena(t, 1)
  local rmn = t:put(N["009"], 0, "hand")
  local h1 = t:put(101, 1, "hand")
  t:put(102, 1, "hand")
  main(t)
  play(t, rmn)
  t:expect(t:wait(HINT_USE_TRIGGER), "코스트가 있으면 임의")
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(table.unpack(paid)))
  t:expect(t:wait(HINT_SELECT))
  t:expect(t:request().player == 0 and #t:request().options == 2)
  t:expect(not t:can_see(0, h1), "보지 않고 고른다")
  t:expect(t:answer(h1))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(h1, 1, "trash") and t:count(1, "hand") == 1)
end)

case("D03-009: 【出】을 쓰지 않을 수 있다", "WD03-009 FAQ 3", function(t)
  wd(t, "001")
  ena(t, 1)
  local rmn = t:put(N["009"], 0, "hand")
  t:put(101, 1, "hand")
  main(t)
  play(t, rmn)
  t:expect(t:wait(HINT_USE_TRIGGER))
  t:expect(t:answer(0))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(1, "hand") == 1 and t:count(0, "ena") == 1)
end)

case("D03-009: 라이프 버스트 — 버릴 카드는 상대가 고른다", "WD03-009 FAQ 5", function(t)
  wd(t, "002")
  t:put(N["009"], 0, "life_cloth")
  t:card{cid = 111, power = 8000, level = 1}
  local att = t:put(111, 1, "signi_right")
  local h = t:put(102, 1, "hand")
  t:put(101, 1, "hand")
  t:begin(1, PHASE_ATTACK)
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:answer(att))
  t:expect(t:wait(HINT_LIFEBURST))
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_DISCARD))
  t:expect(t:request().player == 1)
  t:expect(t:answer(h))
  t:expect(t:wait(HINT_ATTACK_LRIG))
  t:expect(t:is_in(h, 1, "trash") and t:count(1, "hand") == 1)
end)

-- ── 011 コードアート　Ｓ・Ｍ・Ｐ ──

case("D03-011: 【出】 상대 패를 보고 레벨 1 카드 1장을 골라 버리게 한다", "WD03-011", function(t)
  wd(t, "001")
  local smp = t:put(N["011"], 0, "hand")
  local l1 = t:put(101, 1, "hand")
  local l2 = t:put(102, 1, "hand")
  main(t)
  play(t, smp)
  t:expect(t:wait(HINT_SELECT))
  local o = t:request().options
  t:expect(#o == 1 and o[1] == l1, "레벨 1만")
  t:expect(t:can_see(0, l2), "패를 본다")
  t:expect(t:answer(l1))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(l1, 1, "trash") and t:is_in(l2, 1, "hand"))
end)

case("D03-011: 레벨 1 카드가 없으면 보기만 한다", "WD03-011 FAQ 4", function(t)
  wd(t, "001")
  local smp = t:put(N["011"], 0, "hand")
  local l2 = t:put(102, 1, "hand")
  main(t)
  play(t, smp)
  t:expect(t:wait(HINT_MAIN))
  t:expect(not t:saw(HINT_SELECT) and t:can_see(0, l2) and t:is_in(l2, 1, "hand"))
end)

-- ── 014 コードアート　Ｒ・Ｆ・Ｒ ──

case("D03-014: 【出】 1장 뽑고 이어서 패 1장을 버린다", "WD03-014 FAQ 4", function(t)
  wd(t, "001")
  local rfr = t:put(N["014"], 0, "hand")
  local deck = t:cards(0, "main_deck")
  local top = deck[#deck]  -- 맨 위는 마지막
  main(t)
  play(t, rfr)
  t:expect(t:wait(HINT_DISCARD))
  local o = t:request().options
  t:expect(t:request().player == 0 and #o == 1 and o[1] == top, "뽑은 카드도 버릴 수 있다")
  t:expect(t:answer(top))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(top, 0, "trash") and t:count(0, "hand") == 0)
end)

-- ── 015 ＴＯＯ　ＢＡＤ ──

case("D03-015: 상대 패를 보지 않고 1장 골라 버리게 한다", "WD03-015 FAQ 2", function(t)
  wd(t, "001")
  local sp = t:put(N["015"], 0, "hand")
  local h = t:put(102, 1, "hand")
  t:put(101, 1, "hand")
  use(t, sp, 1)
  t:expect(t:wait(HINT_SELECT))
  t:expect(not t:can_see(0, h))
  t:expect(t:answer(h))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(h, 1, "trash") and t:count(1, "hand") == 1)
end)

case("D03-015: 상대 패가 없어도 쓸 수 있고, 아무 일도 일어나지 않는다", "WD03-015 FAQ 1", function(t)
  wd(t, "001")
  local sp = t:put(N["015"], 0, "hand")
  use(t, sp, 1)
  t:expect(t:wait(HINT_MAIN))
  t:expect(not t:saw(HINT_SELECT) and t:is_in(sp, 0, "trash"))
end)
