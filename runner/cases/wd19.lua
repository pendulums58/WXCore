-- WD19 ナナシ 구축덱 카드 스크립트 케이스. 【ウィルス】(용어집: ウィルス·感染状態)와 카드별 FAQ(cards.json)

local N = {}

-- 100: 검은 시그니(덱 채우기·에나), 101: 상대 시그니(파워 3000), 102: 상대 시그니(파워 12000, 레벨 1)
local function wd(t, center_no, opts)
  opts = opts or {}
  t:start{db = true, seed = opts.seed or 1}
  for i = 1, 18 do
    local no = ("%03d"):format(i)
    N[no] = t:no("WD19-" .. no)
  end
  t:card{cid = 100, power = 1000, level = 1, classes = {"精羅：微菌"}, color = COLOR_BLACK}
  t:card{cid = 101, power = 3000, level = 1, classes = {"奏羅：宇宙"}, color = COLOR_WHITE}
  t:card{cid = 102, power = 12000, level = 1, classes = {"奏羅：宇宙"}, color = COLOR_WHITE}
  if not opts.no_deck then t:fill(100, 0, "main_deck", 10) end
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

local function contains(list, x)
  for _, v in ipairs(list) do if v == x then return true end end
  return false
end

local function ena(t, n)
  for _ = 1, n do t:put(100, 0, "ena") end
  return t:cards(0, "ena")
end

local function attack(t, signi)
  t:begin(0, PHASE_ATTACK)
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:answer(signi))
end

-- ── 【ウィルス】 룰 ──

case("virus: 같은 존의 시그니는 감염 상태, 다른 존으로 옮기면 아니다. 존 하나에 하나까지", "용어집: ウィルス, 感染状態", function(t)
  wd(t, "001")
  local s = t:put(101, 1, "signi_left")
  t:expect(not t:infected(s))
  t:place_virus(1, "signi_left")
  t:expect(t:virus(1, "signi_left") and t:infected(s))
  t:move(s, 1, "signi_center")
  t:expect(not t:infected(s) and t:virus(1, "signi_left"), "【ウィルス】는 존에 남는다")
end)

-- ── 009 羅菌　ニホコカビ ──

case("D19-009: 어택하면 상대 시그니 존 전부에 【ウィルス】", "WD19-009", function(t)
  wd(t, "001")
  local n = t:put(N["009"], 0, "signi_left")
  attack(t, n)
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:virus(1, "signi_left") and t:virus(1, "signi_center") and t:virus(1, "signi_right"))
end)

case("D19-009: 【ウィルス】가 여러 개 치워져도 《ターン１回》라 －5000은 한 번", "WD19-009 FAQ 1, WD19-001 FAQ 2", function(t)
  local center = wd(t, "001")
  t:put(N["009"], 0, "signi_left")
  local a, b = t:put(102, 1, "signi_left"), t:put(102, 1, "signi_center")
  t:place_virus(1, "signi_left")
  t:place_virus(1, "signi_center")
  main(t)
  t:expect(t:answer(t:action(ACT_ABILITY, center)))
  t:expect(t:wait(HINT_DECLARE))
  t:expect(t:answer(2))
  t:expect(t:wait(HINT_ZONE))
  t:expect(t:answer(t:request().options[1]))
  t:expect(t:wait(HINT_ZONE))
  t:expect(t:answer(t:request().options[1]))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(a))
  t:expect(t:wait(HINT_TARGET), "ニホコカビ 트리거")
  t:expect(t:answer(b))
  t:expect(t:wait(HINT_MAIN))
  t:expect(not t:virus(1, "signi_left") and not t:virus(1, "signi_center"))
  t:expect(t:is_in(a, 1, "ena"), "－20000으로 바니시")
  t:expect(t:power(b) == 7000, "－5000은 한 번만")
end)

case("D19-009: 라이프 버스트 — 존을 고른다. 【ウィルス】가 이미 있어도 그 존의 시그니는 －8000", "WD19-009 FAQ 3·4", function(t)
  wd(t, "002")
  t:put(N["009"], 0, "life_cloth")
  t:card{cid = 111, power = 10000, level = 1}
  local att = t:put(111, 1, "signi_right")
  local s = t:put(102, 1, "signi_left")
  t:place_virus(1, "signi_left")
  t:begin(1, PHASE_ATTACK)
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:answer(att))
  t:expect(t:wait(HINT_LIFEBURST))
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_ZONE))
  t:expect(#t:request().options == 3, "【ウィルス】가 있는 존도 고를 수 있다")
  t:expect(t:answer(t:request().options[1]))  -- 상대(P2) signi_left
  t:expect(t:wait(HINT_ATTACK_LRIG))
  t:expect(t:power(s) == 4000 and t:virus(1, "signi_left"))
end)

-- ── 011 羅菌　ショウコカビ ──

case("D19-011: 어택하면 감염 상태인 상대 시그니만 대상, 감염이 풀려도 －4000 그대로", "WD19-011 FAQ 1", function(t)
  wd(t, "001")
  local sh = t:put(N["011"], 0, "signi_left")
  t:put(100, 0, "signi_right")  -- 한 체 더: 다음 어택 고르기가 같은 턴에 온다
  t:card{cid = 103, power = 20000, level = 1}  -- 배틀로 바니시되지 않게
  local inf, clean = t:put(103, 1, "signi_left"), t:put(102, 1, "signi_center")
  t:place_virus(1, "signi_left")
  attack(t, sh)
  t:expect(t:wait(HINT_TARGET))
  local o = t:request().options
  t:expect(#o == 1 and o[1] == inf and not contains(o, clean))
  t:expect(t:answer(inf))
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:power(inf) == 16000)
  t:remove_virus(1, "signi_left")
  t:expect(not t:infected(inf) and t:power(inf) == 16000, "감염이 풀려도 턴 끝까지 －4000")
end)

-- ── 013 羅菌　ナットー / 015 羅菌　クロコウジ ──

case("D19-013: 【出】 상대 시그니 존 하나에 【ウィルス】. 이미 있는 존은 고르지 않는다", "WD19-013, 용어집: ウィルス", function(t)
  wd(t, "001")
  t:place_virus(1, "signi_left")
  local n = t:put(N["013"], 0, "hand")
  main(t)
  t:expect(t:answer(t:action(ACT_PLAY, n, "signi_left")))
  t:expect(t:wait(HINT_ZONE))
  t:expect(#t:request().options == 2)
  t:expect(t:answer(t:request().options[1]))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:virus(1, "signi_center") or t:virus(1, "signi_right"))
end)

case("D19-015: 【出】 상대 시그니 존 어디에도 【ウィルス】가 없을 때만 놓는다", "WD19-015 FAQ 1", function(t)
  wd(t, "001")
  t:place_virus(1, "signi_right")
  local k = t:put(N["015"], 0, "hand")
  main(t)
  t:expect(t:answer(t:action(ACT_PLAY, k, "signi_left")))
  t:expect(t:wait(HINT_MAIN))
  t:expect(not t:saw(HINT_ZONE) and not t:virus(1, "signi_left") and not t:virus(1, "signi_center"))
  wd(t, "001")
  k = t:put(N["015"], 0, "hand")
  main(t)
  t:expect(t:answer(t:action(ACT_PLAY, k, "signi_left")))
  t:expect(t:wait(HINT_ZONE))
  t:expect(#t:request().options == 3)
end)

-- ── 007 シックネス・ラブ ──

case("D19-007: 감염 상태 시그니의 【ウィルス】를 치우고 －8000, ベット하면 －15000", "WD19-007", function(t)
  wd(t, "001")
  local arts = t:put(N["007"], 0, "lrig_deck")
  local paid = ena(t, 1)
  local inf, clean = t:put(102, 1, "signi_left"), t:put(101, 1, "signi_center")
  t:place_virus(1, "signi_left")
  main(t)
  t:expect(t:answer(t:action(ACT_USE, arts)))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(paid[1]))
  t:expect(t:wait(HINT_TARGET))
  local o = t:request().options
  t:expect(#o == 1 and o[1] == inf, "감염 상태만")
  t:expect(t:answer(inf))
  t:expect(t:wait(HINT_MAIN))
  t:expect(not t:virus(1, "signi_left") and t:power(inf) == 4000 and t:power(clean) == 3000)
  -- ベット
  wd(t, "001")
  t:add_coin(0, 1)
  arts = t:put(N["007"], 0, "lrig_deck")
  paid = ena(t, 1)
  inf = t:put(102, 1, "signi_left")
  t:place_virus(1, "signi_left")
  main(t)
  t:expect(t:answer(t:action(ACT_USE, arts)))
  t:expect(t:wait(HINT_BET), "ベット를 에나 코스트보다 먼저 묻는다(결정 2026-11-23)")
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(paid[1]))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(inf))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(inf, 1, "ena"), "－15000으로 바니시")
end)

-- ── 006 フェイタル・パニッシュ ──

case("D19-006: 상대 시그니 전부 －7000, ベット(코인 2)하면 －12000", "WD19-006", function(t)
  wd(t, "001")
  local arts = t:put(N["006"], 0, "lrig_deck")
  local paid = ena(t, 3)
  local a, b = t:put(102, 1, "signi_left"), t:put(102, 1, "signi_center")
  main(t)
  t:expect(t:answer(t:action(ACT_USE, arts)))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(table.unpack(paid)))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:power(a) == 5000 and t:power(b) == 5000)
  wd(t, "001")
  t:add_coin(0, 2)
  arts = t:put(N["006"], 0, "lrig_deck")
  paid = ena(t, 3)
  a = t:put(102, 1, "signi_left")
  main(t)
  t:expect(t:answer(t:action(ACT_USE, arts)))
  t:expect(t:wait(HINT_BET))
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(table.unpack(paid)))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(a, 1, "ena") and t:coins(0) == 0)
end)

-- ── 004 ナナシ　其ノ壱 ──

case("D19-004: 【出】《コイン》 — 덱 위 2장을 트래시에 놓은 뒤 그중의 검은 카드도 패로", "WD19-004 FAQ 1", function(t)
  wd(t, "005", {no_deck = true})
  t:add_coin(0, 1)
  t:fill(100, 0, "main_deck", 3)
  local top = t:put(100, 0, "main_deck")
  local next = t:put(N["004"], 0, "lrig_deck")
  t:begin(0, PHASE_GROW)
  t:expect(t:wait(HINT_GROW))
  t:expect(t:answer(next))
  t:expect(t:wait(HINT_USE_TRIGGER))
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_TARGET))
  t:expect(contains(t:request().options, top), "방금 트래시에 놓은 카드도 대상")
  t:expect(t:answer(top))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(top, 0, "hand") and t:count(0, "trash") == 1 and t:coins(0) == 0)
end)

-- ── 018 ラブリー・バイオ ──

case("D19-018: ① 내 ＜微菌＞을 바니시하면 상대 존에 【ウィルス】, ② 바니시하면 상대 시그니 －7000", "WD19-018 FAQ 1", function(t)
  wd(t, "001")
  local sp = t:put(N["018"], 0, "hand")
  local mine = t:put(100, 0, "signi_left")
  main(t)
  t:expect(t:answer(t:action(ACT_USE, sp)))
  t:expect(t:wait(HINT_MODE))
  t:expect(t:answer(0))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(mine))
  t:expect(t:wait(HINT_ZONE))
  t:expect(t:answer(t:request().options[1]))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(mine, 0, "ena") and (t:virus(1, "signi_left") or t:virus(1, "signi_center") or t:virus(1, "signi_right")))
  -- ②: 처리 직전에 내 시그니와 상대 시그니를 함께 고른다
  wd(t, "001")
  sp = t:put(N["018"], 0, "hand")
  mine = t:put(100, 0, "signi_left")
  local opp = t:put(102, 1, "signi_left")
  main(t)
  t:expect(t:answer(t:action(ACT_USE, sp)))
  t:expect(t:wait(HINT_MODE))
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(mine))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(opp))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(mine, 0, "ena") and t:power(opp) == 5000)
end)
