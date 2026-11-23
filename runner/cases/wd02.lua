-- WD02 花代 구축덱 카드 스크립트 케이스. 근거는 카드별 FAQ(cards.json)

local N = {}

-- 100: 빨간 시그니(덱 채우기·에나), 101: 상대 시그니(파워 3000), 102: 상대 시그니(파워 16000, 레벨 1: 상대 센터가 Lv3라 룰 처리에 걸리지 않게)
local function wd(t, center_no, opts)
  opts = opts or {}
  t:start{db = true, seed = opts.seed or 1}
  for i = 1, 18 do
    local no = ("%03d"):format(i)
    N[no] = t:no("WD02-" .. no)
  end
  t:card{cid = 100, power = 1000, level = 1, classes = {"精羅：鉱石"}, color = COLOR_RED}
  t:card{cid = 101, power = 3000, level = 1, classes = {"奏羅：宇宙"}, color = COLOR_WHITE}
  t:card{cid = 102, power = 16000, level = 1, classes = {"奏羅：宇宙"}, color = COLOR_WHITE}
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

-- ── 001 花代・肆 ──

case("D02-001: 내 턴에 《羅石　ヴォルカノ》가 있으면 내 시그니 ＋2000, 여러 체여도 한 번", "WD02-001 FAQ 1", function(t)
  wd(t, "001")
  local s = t:put(100, 0, "signi_left")
  t:put(N["009"], 0, "signi_center")
  t:put(N["009"], 0, "signi_right")
  main(t)
  t:expect(t:power(s) == 3000, "2체여도 ＋2000")
  wd(t, "001")
  s = t:put(100, 0, "signi_left")
  t:put(N["009"], 0, "signi_center")
  t:begin(1, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:power(s) == 1000, "상대 턴에는 없다")
end)

-- ── 006 飛火夏虫 ──

case("D02-006: 상대의 파워 15000 이하 시그니 1체를 바니시, 바니시된 시그니는 에나로", "WD02-006 FAQ 2·3", function(t)
  wd(t, "001")
  local arts = t:put(N["006"], 0, "lrig_deck")
  local small = t:put(101, 1, "signi_left")
  t:put(102, 1, "signi_center")
  use(t, arts, 3)
  t:expect(t:wait(HINT_TARGET))
  local o = t:request().options
  t:expect(#o == 1 and o[1] == small, "파워 15000 이하만")
  t:expect(t:answer(small))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(small, 1, "ena"))
end)

-- ── 007 背炎之陣 ──

case("D02-007: 패 3장을 버리면 내 시그니까지 모든 시그니를 바니시", "WD02-007", function(t)
  wd(t, "001")
  local arts = t:put(N["007"], 0, "lrig_deck")
  local h = {t:put(100, 0, "hand"), t:put(100, 0, "hand"), t:put(100, 0, "hand")}
  local mine = t:put(100, 0, "signi_left")
  local opp = t:put(102, 1, "signi_left")
  use(t, arts, 2)
  t:expect(t:wait(HINT_DISCARD))
  t:expect(t:answer(table.unpack(h)))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(mine, 0, "ena") and t:is_in(opp, 1, "ena"))
  t:expect(t:is_in(h[1], 0, "trash") and t:count(0, "hand") == 0)
end)

case("D02-007: 패가 2장 이하여도 쓸 수 있지만 아무 일도 일어나지 않는다", "WD02-007 FAQ 2", function(t)
  wd(t, "001")
  local arts = t:put(N["007"], 0, "lrig_deck")
  t:put(100, 0, "hand")
  t:put(100, 0, "hand")
  local opp = t:put(102, 1, "signi_left")
  use(t, arts, 2)
  t:expect(t:wait(HINT_MAIN))
  t:expect(not t:saw(HINT_DISCARD) and t:count(0, "hand") == 2 and t:is_in(opp, 1, "signi_left"))
  t:expect(t:is_in(arts, 0, "lrig_trash"), "사용은 했다")
end)

-- ── 008 焼石炎 / 015 轟音の火柱 ──

case("D02-008: 상대의 파워 7000 이하 시그니만 대상", "WD02-008 FAQ 2", function(t)
  wd(t, "001")
  local arts = t:put(N["008"], 0, "lrig_deck")
  local small = t:put(101, 1, "signi_left")
  t:put(102, 1, "signi_center")
  use(t, arts, 2)
  t:expect(t:wait(HINT_TARGET))
  t:expect(#t:request().options == 1)
  t:expect(t:answer(small))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(small, 1, "ena"))
end)

case("D02-015: 스펠, 상대의 파워 5000 이하 시그니만 대상", "WD02-015 FAQ 1", function(t)
  wd(t, "001")
  local sp = t:put(N["015"], 0, "hand")
  local small = t:put(101, 1, "signi_left")
  t:put(102, 1, "signi_center")
  use(t, sp, 1)
  t:expect(t:wait(HINT_TARGET))
  t:expect(#t:request().options == 1)
  t:expect(t:answer(small))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(small, 1, "ena"))
end)

-- ── 009 羅石　ヴォルカノ ──

case("D02-009: 【出】《赤》×3 — 내면 상대의 파워 15000 이하 시그니를 바니시, 안 내도 된다", "WD02-009 FAQ 1", function(t)
  wd(t, "001")
  local paid = ena(t, 3)
  local v = t:put(N["009"], 0, "hand")
  local small = t:put(101, 1, "signi_left")
  main(t)
  t:expect(t:answer(t:action(ACT_PLAY, v, "signi_left")))
  t:expect(t:wait(HINT_USE_TRIGGER), "코스트가 있으면 임의")
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(table.unpack(paid)))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(small))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(small, 1, "ena"))
end)

case("D02-009: 라이프 버스트 — 상대의 파워 7000 이하 시그니를 바니시", "WD02-009 FAQ 3", function(t)
  wd(t, "002")
  t:put(N["009"], 0, "life_cloth")
  t:card{cid = 111, power = 8000, level = 1}
  local att = t:put(111, 1, "signi_right")
  local small = t:put(101, 1, "signi_left")
  t:begin(1, PHASE_ATTACK)
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:answer(att))
  t:expect(t:wait(HINT_LIFEBURST))
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_TARGET))
  local o = t:request().options
  t:expect(#o == 1 and o[1] == small, "파워 8000인 어택 시그니는 아니다")
  t:expect(t:answer(small))
  t:expect(t:wait(HINT_ATTACK_LRIG))
  t:expect(t:is_in(small, 1, "ena"))
end)

-- ── 011 羅石　ガーネット ──

case("D02-011: 【出】 턴 종료 시까지 기본 파워 15000", "WD02-011 FAQ 1", function(t)
  wd(t, "002")
  local g = t:put(N["011"], 0, "hand")
  main(t)
  t:expect(t:answer(t:action(ACT_PLAY, g, "signi_left")))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:power(g) == 15000)
  t:reset_phase(PHASE_END)
  t:expect(t:power(g) == 7000)
end)

-- ── 014 羅石　アメジスト ──

case("D02-014: 【出】 파워 1000 이하 상대 시그니를 대상으로 하고, 바니시할지는 고른다", "WD02-014 FAQ 2", function(t)
  wd(t, "001")
  t:card{cid = 103, power = 1000, level = 1}
  local am = t:put(N["014"], 0, "hand")
  local tiny = t:put(103, 1, "signi_left")
  t:put(101, 1, "signi_center")
  main(t)
  t:expect(t:answer(t:action(ACT_PLAY, am, "signi_left")))
  t:expect(t:wait(HINT_TARGET))
  local o = t:request().options
  t:expect(#o == 1 and o[1] == tiny and t:request().min == 1, "코스트가 없어 대상은 반드시 고른다")
  t:expect(t:answer(tiny))
  t:expect(t:wait(HINT_SCRIPT))
  t:expect(t:answer(0))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(tiny, 1, "signi_left"), "바니시하지 않아도 된다")
end)
