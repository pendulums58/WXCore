-- WDK08 英血の器 優羽莉(LoV) 스타터 카드 스크립트 케이스. 血晶武装(용어집: 血晶武装)와 카드별 FAQ(cards.json)

local N = {}

-- 100: ＜紅蓮＞ 빨간 시그니(덱 채우기·에나·血晶武装 짝), 101: 상대 시그니(파워 3000), 103: 다른 이름의 ＜紅蓮＞
local function wd(t, center_no, opts)
  opts = opts or {}
  t:start{db = true, seed = opts.seed or 1}
  for i = 1, 20 do
    local no = ("L%02d"):format(i)
    N[no] = t:no("WDK08-" .. no)
  end
  t:card{cid = 100, power = 1000, level = 1, classes = {"精械：紅蓮"}, color = COLOR_RED}
  t:card{cid = 101, power = 3000, level = 1, classes = {"奏羅：宇宙"}, color = COLOR_WHITE}
  t:card{cid = 103, power = 2000, level = 1, classes = {"精械：紅蓮"}, color = COLOR_RED}
  if not opts.no_deck then t:fill(100, 0, "main_deck", 10) end
  t:fill(101, 1, "main_deck", 10)
  t:fill(101, 0, "life_cloth", 5)
  t:fill(101, 1, "life_cloth", 5)
  local center = t:put(N[center_no or "L01"], 0, "lrig_center")
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

-- 优羽莉 【起】로 s를 血晶武装［手札］. pick이 nil이면 놓지 않는다
local function arm(t, center, s, pick)
  t:expect(t:answer(t:action(ACT_ABILITY, center)))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(s))
  t:expect(t:wait(HINT_SELECT))
  local r = t:request()
  t:expect(r.min == 0, "패는 비공개 영역이라 놓지 않아도 된다(용어집: 非公開領域)")
  t:expect(t:answer(pick))
  return r.options
end

-- ── 血晶武装 룰 ──

case("blood: 패의 같은 이름 시그니만 밑에 놓을 수 있고, 놓으면 血晶武装状態. 優羽莉 【自】로 1장 뽑는다", "용어집: 血晶武装, WDK08-L01", function(t)
  local center = wd(t, "L01")
  local s = t:put(100, 0, "signi_left")
  local same, other = t:put(100, 0, "hand"), t:put(103, 0, "hand")
  main(t)
  local o = arm(t, center, s, same)
  t:expect(#o == 1 and o[1] == same and not contains(o, other), "같은 이름만")
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:flags(s) & CF_BLOOD ~= 0)
  t:expect(contains(t:under(s), same))
  t:expect(t:count(0, "hand") == 2, "1장 놓고 1장 뽑기")
  t:expect(t:action(ACT_ABILITY, center) == nil, "《ターン１回》")
end)

case("blood: 밑의 카드가 없어져도 상태 유지, 장을 떠나면 끝", "용어집: 血晶武装", function(t)
  local center = wd(t, "L01")
  local s = t:put(100, 0, "signi_left")
  local same = t:put(100, 0, "hand")
  main(t)
  arm(t, center, s, same)
  t:expect(t:wait(HINT_MAIN))
  t:move(same, 0, "trash")
  t:expect(t:flags(s) & CF_BLOOD ~= 0, "밑의 카드가 없어도 血晶武装状態")
  t:move(s, 0, "hand")
  t:move(s, 0, "signi_center")
  t:expect(t:flags(s) & CF_BLOOD == 0, "새 객체")
end)

case("blood: 이미 血晶武装状態인 시그니를 다시 血晶武装하면 「なったとき」는 트리거하지 않는다", "WDK08-L01 FAQ 2, WDK08-L17 FAQ 3", function(t)
  local center = wd(t, "L01")
  local s = t:put(100, 0, "signi_left")
  t:put(N["L17"], 0, "signi_right")
  t:set_flags(s, CF_BLOOD)
  local same = t:put(100, 0, "hand")
  main(t)
  arm(t, center, s, same)
  t:expect(t:wait(HINT_MAIN))
  t:expect(not t:saw(HINT_DISCARD) and t:count(0, "hand") == 0, "優羽莉·セルディッド 둘 다 트리거 없음")
  t:expect(contains(t:under(s), same), "밑에는 놓인다")
end)

-- ── L01 英血の器　優羽莉　Ｌｖ４ ──

case("L01: 【出】 덱이 4장 이하면 있는 만큼 공개, ＜紅蓮＞ 2장까지 패, 나머지 트래시", "WDK08-L01 FAQ 3", function(t)
  wd(t, "L02", {no_deck = true})
  local a, b, c = t:put(100, 0, "main_deck"), t:put(103, 0, "main_deck"), t:put(101, 0, "main_deck")
  local l1 = t:put(N["L01"], 0, "lrig_deck")
  local paid = ena(t, 1)
  t:begin(0, PHASE_GROW)
  t:expect(t:wait(HINT_GROW))
  t:expect(t:answer(l1))
  t:expect(t:wait(HINT_USE_TRIGGER), "코스트가 있으면 임의")
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(paid[1]))
  t:expect(t:wait(HINT_SELECT))
  local o = t:request().options
  t:expect(#o == 2 and contains(o, a) and contains(o, b) and not contains(o, c), "＜紅蓮＞만")
  t:expect(t:answer({a, b}))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(a, 0, "hand") and t:is_in(b, 0, "hand"))
  t:expect(t:is_in(c, 0, "trash") or t:refreshes(0) > 0, "나머지는 트래시(그 뒤 리프레시)")
end)

-- ── L06 血晶紅盾 ──

case("L06: 시그니가 없어도 쓸 수 있고, 다음 데미지 한 번만 받지 않는다", "WDK08-L06 FAQ 1·2", function(t)
  wd(t, "L01")
  local arts = t:put(N["L06"], 0, "lrig_deck")
  local paid = ena(t, 3)
  local x, y = t:put(101, 1, "signi_left"), t:put(101, 1, "signi_center")
  t:begin(1, PHASE_ATTACK)
  t:expect(t:wait(HINT_DEFENSE))
  t:expect(t:answer(t:action(ACT_USE, arts)))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(paid))
  t:expect(t:wait(HINT_DEFENSE))
  t:expect(not t:saw(HINT_TARGET), "대상이 없으면 그 부분만 건너뛴다")
  t:expect(t:answer(t:action(ACT_END)))
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:answer(x))
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:count(0, "life_cloth") == 5, "첫 데미지는 받지 않는다")
  t:expect(t:answer(y))
  t:expect(t:wait(HINT_ATTACK_LRIG))
  t:expect(t:count(0, "life_cloth") == 4, "두 번째는 받는다")
end)

case("L06: 「バニッシュされない」는 배틀·파워 0 이하 룰 처리 모두 막는다. 파워는 0으로 남는다", "WDK08-L06, 룰 해설 160513_02 問1", function(t)
  wd(t, "L01")
  local arts = t:put(N["L06"], 0, "lrig_deck")
  local paid = ena(t, 3)
  local s = t:put(103, 0, "signi_left")
  local x = t:put(101, 1, "signi_right")  -- 정면
  t:begin(1, PHASE_ATTACK)
  t:expect(t:wait(HINT_DEFENSE))
  t:expect(t:answer(t:action(ACT_USE, arts)))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(paid))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(s))
  t:expect(t:wait(HINT_DEFENSE))
  t:single(s, EFFECT_UPDATE_POWER, -5000, 1)
  t:expect(t:answer(t:action(ACT_END)))
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:is_in(s, 0, "signi_left") and t:power(s) == 0, "룰 처리: 파워 0으로 남는다")
  t:expect(t:answer(x))
  t:expect(t:wait(HINT_ATTACK_LRIG))
  t:expect(t:is_in(s, 0, "signi_left"), "배틀에 져도 남는다")
end)

-- ── L08 血晶魔杖 ──

case("L08: 파워 10000 이하 1체 바니시, ベット하면 대신 상대 시그니 전부", "WDK08-L08 FAQ 1, 용어집: ベット", function(t)
  wd(t, "L01")
  t:card{cid = 104, power = 15000, level = 1}
  local arts = t:put(N["L08"], 0, "lrig_deck")
  local paid = ena(t, 1)
  local small, big = t:put(101, 1, "signi_left"), t:put(104, 1, "signi_center")
  t:begin(0, PHASE_ATTACK)
  t:expect(t:wait(HINT_PRE_ATTACK))
  t:expect(t:answer(t:action(ACT_USE, arts)))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(paid[1]))
  t:expect(t:wait(HINT_TARGET))
  local o = t:request().options
  t:expect(#o == 1 and o[1] == small, "코인이 없으면 ベット를 묻지 않는다")
  t:expect(t:answer(small))
  t:expect(t:wait(HINT_PRE_ATTACK))
  t:expect(t:is_in(small, 1, "ena") and t:is_in(big, 1, "signi_center"))
  -- ベット
  wd(t, "L01")
  t:add_coin(0, 4)
  arts = t:put(N["L08"], 0, "lrig_deck")
  paid = ena(t, 1)
  small, big = t:put(101, 1, "signi_left"), t:put(104, 1, "signi_center")
  t:begin(0, PHASE_ATTACK)
  t:expect(t:wait(HINT_PRE_ATTACK))
  t:expect(t:answer(t:action(ACT_USE, arts)))
  t:expect(t:wait(HINT_BET))
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(paid[1]))
  t:expect(t:wait(HINT_PRE_ATTACK))
  t:expect(not t:saw(HINT_TARGET), "대신이라 대상을 고르지 않는다")
  t:expect(t:is_in(small, 1, "ena") and t:is_in(big, 1, "ena") and t:coins(0) == 0)
end)

-- ── L11 紅蓮の使い魔　ツクヨミ ──

case("L11: 血晶武装状態일 때만 어택 시 【自】. 《赤》《赤》를 내면 2체까지 바니시, 그 뒤 정면이 비어 데미지", "WDK08-L11 FAQ 3", function(t)
  local center = wd(t, "L01")
  local k = t:put(N["L11"], 0, "signi_left")
  local same = t:put(N["L11"], 0, "hand")
  local paid = ena(t, 2)
  local f, g = t:put(101, 1, "signi_right"), t:put(101, 1, "signi_center")  -- f가 정면
  -- 상태가 아니면 트리거 없음
  attack(t, k)
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(not t:saw(HINT_TARGET) and t:is_in(f, 1, "ena"), "배틀로 정면만 바니시")
  wd(t, "L01")
  center = t:center(0)
  k = t:put(N["L11"], 0, "signi_left")
  same = t:put(N["L11"], 0, "hand")
  paid = ena(t, 2)
  f, g = t:put(101, 1, "signi_right"), t:put(101, 1, "signi_center")
  main(t)
  arm(t, center, k, same)
  t:expect(t:wait(HINT_MAIN))
  attack(t, k)
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer({f, g}))
  t:expect(t:wait(HINT_SCRIPT))
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(paid))
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:is_in(f, 1, "ena") and t:is_in(g, 1, "ena"))
  t:expect(t:count(1, "life_cloth") == 4, "정면이 비어 데미지")
end)

-- ── L13 アマテラス / L15 コノハナサクヤ ──

case("L13: 血晶武装状態의 내 시그니(자신 포함)는 【ダブルクラッシュ】", "WDK08-L13 FAQ 2", function(t)
  wd(t, "L01")
  local a = t:put(N["L13"], 0, "signi_left")
  local s = t:put(100, 0, "signi_center")
  t:expect(not t:keyword(a, EFFECT_DOUBLE_CRUSH) and not t:keyword(s, EFFECT_DOUBLE_CRUSH))
  t:set_flags(a, CF_BLOOD)
  t:set_flags(s, CF_BLOOD)
  t:expect(t:keyword(a, EFFECT_DOUBLE_CRUSH) and t:keyword(s, EFFECT_DOUBLE_CRUSH))
end)

case("L15: 血晶武装状態인 동안만 【アサシン】", "WDK08-L15", function(t)
  wd(t, "L01")
  local k = t:put(N["L15"], 0, "signi_left")
  t:expect(not t:keyword(k, EFFECT_ASSASSIN))
  t:set_flags(k, CF_BLOOD)
  t:expect(t:keyword(k, EFFECT_ASSASSIN))
end)

-- ── L14 紅蓮の使い魔　清姫 ──

case("L14: 血晶武装状態면 3개까지, 같은 것도. ①①② 순서면 －2000 뒤에 4000 이하 판정", "WDK08-L14 FAQ 2", function(t)
  wd(t, "L01")
  t:card{cid = 105, power = 6000, level = 1}
  local k = t:put(N["L14"], 0, "signi_right")
  t:set_flags(k, CF_BLOOD)
  local v = t:put(105, 1, "signi_center")  -- 정면이 아니다(배틀로 바니시되지 않게)
  attack(t, k)
  t:expect(t:wait(HINT_MODE))
  t:expect(t:answer(1))  -- ②
  t:expect(t:wait(HINT_SCRIPT))
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_MODE))
  t:expect(t:answer(0))  -- ①
  t:expect(t:wait(HINT_SCRIPT))
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_MODE))
  t:expect(t:answer(0))  -- ①
  t:expect(t:wait(HINT_TARGET), "3개를 고르면 더 묻지 않는다")
  t:expect(t:answer(v))
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:is_in(v, 1, "ena"), "－2000으로 4000이 된 뒤 바니시")
end)

case("L14: 상태가 아니면 1개만", "WDK08-L14", function(t)
  wd(t, "L01")
  local k = t:put(N["L14"], 0, "signi_right")
  attack(t, k)
  t:expect(t:wait(HINT_MODE))
  t:expect(t:answer(2))  -- ③
  t:expect(t:wait(HINT_DISCARD), "더 고를지 묻지 않는다")
  t:expect(not t:saw(HINT_SCRIPT))
end)

-- ── L20 血晶の斧撃 ──

case("L20: ① 내 ＜紅蓮＞이 없으면 상대 시그니를 바니시하지 않는다", "WDK08-L20 FAQ 1·2", function(t)
  wd(t, "L01")
  local sp = t:put(N["L20"], 0, "hand")
  local x = t:put(101, 1, "signi_left")
  main(t)
  t:expect(t:answer(t:action(ACT_USE, sp)))
  t:expect(t:wait(HINT_MODE))
  t:expect(t:answer(0))
  t:expect(t:wait(HINT_TARGET), "내 ＜紅蓮＞이 없어도 상대 시그니는 대상으로 고른다")
  t:expect(t:answer(x))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(x, 1, "signi_left"))
  -- 있으면 트래시에 놓고 바니시
  wd(t, "L01")
  sp = t:put(N["L20"], 0, "hand")
  local mine = t:put(100, 0, "signi_left")
  x = t:put(101, 1, "signi_left")
  main(t)
  t:expect(t:answer(t:action(ACT_USE, sp)))
  t:expect(t:wait(HINT_MODE))
  t:expect(t:answer(0))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(mine))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(x))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(mine, 0, "trash") and t:is_in(x, 1, "ena"))
end)
