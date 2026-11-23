-- WD01 ホワイト・ホープ 카드 스크립트 케이스. 근거는 카드별 FAQ(cards.json)

local N = {}

-- 100: 흰 시그니(덱 채우기·에나), 101: 상대 시그니, 102: 파란 시그니
local function wd(t, center_no, opts)
  opts = opts or {}
  t:start{db = true, seed = opts.seed or 1}
  for i = 1, 18 do
    local no = ("%03d"):format(i)
    N[no] = t:no("WD01-" .. no)
  end
  t:card{cid = 100, power = 1000, level = 1, classes = {"精武：アーム"}, color = COLOR_WHITE}
  t:card{cid = 101, power = 3000, level = 1, classes = {"奏羅：宇宙"}, color = COLOR_WHITE}
  t:card{cid = 102, power = 1000, level = 1, classes = {"精羅：宇宙"}, color = COLOR_BLUE}
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

-- 상대(1)가 시그니로 어택해 라이프 클로스를 크러시한다. 라이프 버스트를 발동한다
local function crushed(t, burst)
  t:put(burst, 0, "life_cloth")
  t:card{cid = 111, power = 3000, level = 1}
  local att = t:put(111, 1, "signi_right")
  t:begin(1, PHASE_ATTACK)
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:answer(att))
  t:expect(t:wait(HINT_LIFEBURST))
  t:expect(t:answer(1))
end

-- ── 001 満月の巫女　タマヨリヒメ ──

case("D01-001: 《甲冑　ローメイル》가 있으면 내 시그니 ＋2000, 여러 체여도 한 번", "WD01-001 FAQ 4", function(t)
  wd(t, "001")
  local s = t:put(100, 0, "signi_left")
  main(t)
  t:expect(t:power(s) == 1000)
  local r1 = t:put(N["009"], 0, "signi_center")
  t:expect(t:power(s) == 3000 and t:power(r1) == 14000)
  t:put(N["009"], 0, "signi_right")
  t:expect(t:power(s) == 3000, "2체여도 ＋2000")
end)

-- ── 006 ロココ・バウンダリー ──

case("D01-006: 상대 시그니를 2체까지 패로, 1체뿐이어도 쓸 수 있다", "WD01-006 FAQ 3, 용어집: 対象", function(t)
  wd(t, "001")
  local arts = t:put(N["006"], 0, "lrig_deck")
  local paid = ena(t, 5)
  local opp = t:put(101, 1, "signi_left")
  main(t)
  t:expect(t:answer(t:action(ACT_USE, arts)))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(table.unpack(paid)))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:request().min == 0 and t:request().max == 2, "「まで」는 0체부터")
  t:expect(t:answer(opp))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(opp, 1, "hand"))
end)

-- ── 007 エイボン ──

case("D01-007: 덱에서 흰 시그니를 2장까지, 1장만 찾아도 된다", "WD01-007 FAQ 2", function(t)
  wd(t, "001", {no_deck = true})
  local arts = t:put(N["007"], 0, "lrig_deck")
  local paid = ena(t, 3)
  local w = t:put(100, 0, "main_deck")
  t:put(102, 0, "main_deck")
  t:put(N["018"], 0, "main_deck")
  main(t)
  t:expect(t:answer(t:action(ACT_USE, arts)))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(table.unpack(paid)))
  t:expect(t:wait(HINT_SELECT))
  local o = t:request().options
  t:expect(#o == 1 and o[1] == w, "흰 시그니만")
  t:expect(t:answer(w))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(w, 0, "hand") and t:count(0, "main_deck") == 2)
end)

-- ── 008 バロック・ディフェンス ──

case("D01-008: 상대 센터 루리그나 시그니 1체가 턴 종료 시까지 「アタックできない」를 얻는다", "WD01-008", function(t)
  local center = wd(t, "001")
  local arts = t:put(N["008"], 0, "lrig_deck")
  local paid = ena(t, 2)
  local mine = t:put(100, 0, "signi_left")
  local opp = t:put(101, 1, "signi_left")
  local opp_center = t:cards(1, "lrig_center")[1]
  t:begin(0, PHASE_ATTACK)
  t:expect(t:wait(HINT_PRE_ATTACK))
  t:expect(t:answer(t:action(ACT_USE, arts)))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(table.unpack(paid)))
  t:expect(t:wait(HINT_TARGET))
  local o = t:request().options
  t:expect(contains(o, opp) and contains(o, opp_center), "상대 센터 루리그와 시그니")
  t:expect(not contains(o, mine) and not contains(o, center), "내 카드는 아니다")
  t:expect(t:answer(opp))
  t:expect(t:wait(HINT_DEFENSE))
  t:expect(t:keyword(opp, EFFECT_CANNOT_ATTACK))
  t:reset_phase(PHASE_END)
  t:expect(not t:keyword(opp, EFFECT_CANNOT_ATTACK), "턴 종료 시까지")
end)

-- ── 009 甲冑　ローメイル ──

case("D01-009: 상대 턴 동안 내 시그니 ＋1000, 2체면 겹친다", "WD01-009 FAQ 3", function(t)
  wd(t, "002")
  local s = t:put(100, 0, "signi_left")
  local r1 = t:put(N["009"], 0, "signi_center")
  t:put(N["009"], 0, "signi_right")
  main(t)
  t:expect(t:power(s) == 1000 and t:power(r1) == 12000, "내 턴에는 없다")
  wd(t, "002")
  s = t:put(100, 0, "signi_left")
  r1 = t:put(N["009"], 0, "signi_center")
  t:put(N["009"], 0, "signi_right")
  t:begin(1, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:power(s) == 3000 and t:power(r1) == 14000)
end)

case("D01-009: 라이프 버스트 — 상대 시그니 1체를 패로, 없으면 아무것도 하지 않는다", "WD01-009 FAQ 4", function(t)
  wd(t, "002")
  local opp = t:put(101, 1, "signi_left")
  crushed(t, N["009"])
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(opp))
  t:expect(t:wait(HINT_ATTACK_LRIG))
  t:expect(t:is_in(opp, 1, "hand"))
  wd(t, "002")
  crushed(t, N["009"])  -- 상대 시그니는 어택한 111뿐: 대상 후보
  t:expect(t:wait(HINT_TARGET))
  t:expect(#t:request().options == 1)
end)

-- ── 011 篭手　トレット ──

case("D01-011: 【出】《白》 — 내면 덱에서 《甲冑　ローメイル》를 찾아 패에, 안 내도 된다", "WD01-011 FAQ 3·4", function(t)
  wd(t, "001")
  local paid = ena(t, 1)
  local r = t:put(N["009"], 0, "main_deck")
  local tr = t:put(N["011"], 0, "hand")
  main(t)
  t:expect(t:answer(t:action(ACT_PLAY, tr, "signi_left")))
  t:expect(t:wait(HINT_USE_TRIGGER), "코스트가 있으면 임의")
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(paid[1]))
  t:expect(t:wait(HINT_SELECT))
  local o = t:request().options
  t:expect(#o == 1 and o[1] == r and t:request().min == 0, "ローメイル만, 찾지 않아도 된다")
  t:expect(t:answer(r))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(r, 0, "hand"))
  -- 안 내기
  wd(t, "001")
  ena(t, 1)
  tr = t:put(N["011"], 0, "hand")
  main(t)
  t:expect(t:answer(t:action(ACT_PLAY, tr, "signi_left")))
  t:expect(t:wait(HINT_USE_TRIGGER))
  t:expect(t:answer(0))
  t:expect(t:wait(HINT_MAIN))
  t:expect(not t:saw(HINT_SELECT) and t:count(0, "ena") == 1)
end)

-- ── 014 小弓　ボーニャ ──

case("D01-014: 【出】 덱 위 3장을 원하는 순서로, 2장이면 2장만", "WD01-014 FAQ 3", function(t)
  wd(t, "001", {no_deck = true})
  local a, b = t:put(100, 0, "main_deck"), t:put(102, 0, "main_deck")  -- b가 맨 위
  local bo = t:put(N["014"], 0, "hand")
  main(t)
  t:expect(t:answer(t:action(ACT_PLAY, bo, "signi_left")))
  t:expect(t:wait(HINT_ORDER))
  t:expect(#t:request().options == 2)
  t:expect(t:answer(a, b))
  t:expect(t:wait(HINT_MAIN))
  local deck = t:cards(0, "main_deck")
  t:expect(deck[#deck] == a and deck[#deck - 1] == b, "처음 고른 카드가 맨 위")
end)

-- ── 015 ゲット・バイブル ──

case("D01-015: 덱에서 시그니 1장까지, 찾지 않아도 된다", "WD01-015 FAQ 1", function(t)
  wd(t, "001", {no_deck = true})
  local paid = ena(t, 1)
  local s = t:put(102, 0, "main_deck")
  t:put(N["018"], 0, "main_deck")
  local sp = t:put(N["015"], 0, "hand")
  main(t)
  t:expect(t:answer(t:action(ACT_USE, sp)))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(paid[1]))
  t:expect(t:wait(HINT_SELECT))
  local o = t:request().options
  t:expect(#o == 1 and o[1] == s and t:request().min == 0, "시그니만, 0장도 된다")
  t:expect(t:answer(s))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(s, 0, "hand"))
end)

-- ── 016 サーバント　Ｄ ──

case("D01-016: 라이프 버스트 【エナチャージ１】, 에나에서 【マルチエナ】", "WD01-016", function(t)
  wd(t, "002")
  crushed(t, N["016"])
  t:expect(t:wait(HINT_ATTACK_LRIG))
  t:expect(t:count(0, "ena") == 2, "버스트한 카드 + 에나 차지 1장")
  local d = t:put(N["016"], 0, "ena")
  t:expect(t:keyword(d, EFFECT_MULTI_ENA))
end)

-- ── 018 噴流する知識 ──

case("D01-018: 1장 뽑는다. 덱이 1장이면 뽑은 뒤 리프레시", "WD01-018 FAQ 1", function(t)
  wd(t, "001", {no_deck = true})
  local top = t:put(100, 0, "main_deck")
  t:fill(100, 0, "trash", 5)
  local sp = t:put(N["018"], 0, "hand")
  main(t)
  t:expect(t:answer(t:action(ACT_USE, sp)))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(top, 0, "hand") and t:refreshes(0) == 1)
end)
