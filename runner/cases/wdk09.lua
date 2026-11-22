-- WDK09 ブルーウムル 카드 스크립트 케이스. 근거는 카드별 FAQ(cards.json)

local N = {}

local function wdk(t, center_no, opts)
  opts = opts or {}
  t:start{db = true, seed = opts.seed or 1}
  for i = 1, 22 do
    local no = ("%03d"):format(i)
    N[no] = t:no("WDK09-" .. no)
  end
  t:card{cid = 100, power = 1000, level = 1, classes = {"精械：迷宮"}, color = COLOR_BLUE}
  t:card{cid = 101, power = 3000, level = 1, classes = {"奏羅：宇宙"}, color = COLOR_WHITE}
  if not opts.no_deck then t:fill(100, 0, "main_deck", 10) end
  if not opts.no_opp_deck then t:fill(101, 1, "main_deck", 10) end
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

local function use(t, card)
  main(t)
  t:expect(t:answer(t:action(ACT_USE, card)))
end

-- ── 001 ウムル＝フィーラ ──

case("K09-001: 그로우하면 【出】 상대 존에 【ゲート】 + 1장, 코인 3", "WDK09-001, PR-322 FAQ", function(t)
  wdk(t, "002")
  local feela = t:put(N["001"], 0, "lrig_deck")
  t:begin(0, PHASE_GROW)
  t:expect(t:wait(HINT_GROW))
  t:expect(t:answer(feela))
  t:expect(t:wait(HINT_ZONE))
  t:expect(#t:request().options == 3)
  t:expect(t:answer(t:request().options[2]))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:gate(1, "signi_center") and t:count(0, "hand") == 1 and t:coins(0) == 3)
end)

local function opp_attack(t, top_burst)
  local center = wdk(t, "001")
  t:place_gate(1, "signi_left")
  local gated = t:put(101, 1, "signi_left")
  local free = t:put(101, 1, "signi_right")
  if top_burst then
    t:card{cid = 102, power = 1000, level = 1, burst = 1}
    t:put(102, 1, "main_deck")
  end
  t:begin(1, PHASE_ATTACK)
  return gated, free
end

case("K09-001: 【自】 상대 덱 맨 위가 버스트가 없으면 【ゲート】 존의 시그니는 어택할 수 없다", "WDK09-001 FAQ 2", function(t)
  local gated, free = opp_attack(t, false)
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  local o = t:request().options
  t:expect(#o == 1 and o[1] == free)
  local top = t:cards(1, "main_deck")[10]
  t:expect(t:can_see(0, top), "공개한 카드는 덱 맨 위에 남는다")
end)

case("K09-001: 버스트가 있으면 막지 않는다", "WDK09-001", function(t)
  local gated, free = opp_attack(t, true)
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(#t:request().options == 2)
end)

case("K09-001: 【ゲート】 존에 나중에 온 시그니도 어택할 수 없다", "WDK09-001 FAQ 4", function(t)
  local gated, free = opp_attack(t, false)
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:move(gated, 1, "trash")
  local late = t:put(101, 1, "signi_left")
  t:expect(t:answer(free))
  -- 남은 업 시그니는 late뿐인데 어택할 수 없으니 시그니 어택 요청 없이 루리그 어택으로 간다
  t:expect(t:wait(HINT_ATTACK_LRIG))
  t:expect(t:flags(late) & CF_DOWN == 0 and t:keyword(late, EFFECT_CANNOT_ATTACK))
end)

case("K09-001: プライマル 《ゲーム1回》 코인 1 — 【ゲート】 존의 상대 시그니를 덱에 넣고 섞는다", "WDK09-001 FAQ 5", function(t)
  local center = wdk(t, "001")
  t:add_coin(0, 2)
  t:place_gate(1, "signi_left")
  local a = t:put(101, 1, "signi_left")
  local b = t:put(101, 1, "signi_right")
  main(t)
  t:expect(t:answer(t:action(ACT_ABILITY, center)))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(a, 1, "main_deck") and t:is_in(b, 1, "signi_right") and t:coins(0) == 1)
  t:expect(t:action(ACT_ABILITY, center) == nil, "《ゲーム1回》")
end)

-- ── 002·003·004 ──

local function grow(t, from_no, to_no, ena)
  wdk(t, from_no)
  for _ = 1, ena or 0 do t:put(100, 0, "ena") end
  local next = t:put(N[to_no], 0, "lrig_deck")
  t:begin(0, PHASE_GROW)
  t:expect(t:wait(HINT_GROW))
  t:expect(t:answer(next))
  return next
end

case("K09-002: 【出】 코인 1", "WDK09-002", function(t)
  grow(t, "003", "002", 2)
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(t:cards(0, "ena")))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:coins(0) == 1)
end)

case("K09-003: 【出】《コインアイコン》 — 코인을 내면 1장, 없으면 묻지 않는다", "WDK09-003", function(t)
  grow(t, "004", "003", 1)
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(t:cards(0, "ena")))
  t:expect(t:wait(HINT_MAIN))
  t:expect(not t:saw(HINT_USE_TRIGGER), "코인이 없으면 묻지 않는다")
  wdk(t, "004")
  t:add_coin(0, 1)
  t:put(100, 0, "ena")
  local next = t:put(N["003"], 0, "lrig_deck")
  t:begin(0, PHASE_GROW)
  t:expect(t:wait(HINT_GROW))
  t:expect(t:answer(next))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(t:cards(0, "ena")))
  t:expect(t:wait(HINT_USE_TRIGGER))
  t:expect(t:request().source_desc == N["003"] * 32 + 16, "능력 줄 0번(설계: 효과 설명 문자열)")
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:coins(0) == 0 and t:count(0, "hand") == 1)
end)

case("K09-004: 【出】 손패 1장을 버리면 코인 1", "WDK09-004", function(t)
  wdk(t, "005")
  local h = t:put(100, 0, "hand")
  local next = t:put(N["004"], 0, "lrig_deck")
  t:begin(0, PHASE_GROW)
  t:expect(t:wait(HINT_GROW))
  t:expect(t:answer(next))
  t:expect(t:wait(HINT_USE_TRIGGER))
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_DISCARD))
  t:expect(t:answer(h))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:coins(0) == 1 and t:is_in(h, 0, "trash"))
end)

-- ── 006 ブリリアント・エコー ──

case("K09-006: 앙코르로 코인 2를 더 내면 【ゲート】를 놓고 루리그 덱으로", "WDK09-006 FAQ 2", function(t)
  wdk(t, "001")
  t:add_coin(0, 2)
  for _ = 1, 6 do t:put(100, 0, "ena") end
  local arts = t:put(N["006"], 0, "lrig_deck")
  use(t, arts)
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(t:cards(0, "ena")))
  t:expect(t:wait(HINT_ENCORE))
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_ZONE))
  t:expect(t:answer(t:request().options[1]))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:gate(1, "signi_left") and t:is_in(arts, 0, "lrig_deck") and t:coins(0) == 0)
end)

-- ── 007 ドント・ムーブ ──

case("K09-007: 상대 시그니가 1체여도 쓸 수 있다(「２体まで」)", "WDK09-007 FAQ 2", function(t)
  wdk(t, "001")
  for _ = 1, 3 do t:put(100, 0, "ena") end
  local arts = t:put(N["007"], 0, "lrig_deck")
  local s = t:put(101, 1, "signi_center")
  t:begin(0, PHASE_ATTACK)
  t:expect(t:wait(HINT_PRE_ATTACK))
  t:expect(t:answer(t:action(ACT_USE, arts)))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(t:cards(0, "ena")))
  t:expect(t:wait(HINT_TARGET))
  t:expect(#t:request().options == 1, "후보가 1체")
  t:expect(t:answer(s))
  t:expect(t:wait(HINT_PRE_ATTACK))
  t:expect(t:flags(s) & CF_DOWN ~= 0)
end)

-- ── 008 フォルテ・バレーノ ──

case("K09-008: 2장 뽑고, 상대 장에 키가 있으면 상대가 2장 버린다", "WDK09-008 FAQ 1", function(t)
  wdk(t, "001")
  t:put(100, 0, "ena")
  local arts = t:put(N["008"], 0, "lrig_deck")
  t:put(N["009"], 1, "key")
  t:fill(101, 1, "hand", 3)
  use(t, arts)
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(t:cards(0, "ena")))
  t:expect(t:wait(HINT_DISCARD))
  t:expect(t:request().player == 1 and t:request().min == 2)
  local h = t:cards(1, "hand")
  t:expect(t:answer(h[1], h[2]))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "hand") == 2 and t:count(1, "hand") == 1)
end)

-- ── 009 眩しき者　タウィル ──

case("K09-009: 코인 1로 키를 내면 【出】 1장, 상대 손패 상한 5", "WDK09-009 FAQ 1", function(t)
  wdk(t, "001")
  t:add_coin(0, 1)
  local key = t:put(N["009"], 0, "lrig_deck")
  main(t)
  t:expect(t:answer(t:action(ACT_KEY, key)))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(key, 0, "key") and t:count(0, "hand") == 1 and t:coins(0) == 0)
  t:expect(t:hand_limit(1) == 5 and t:hand_limit(0) == 6)
end)

case("K09-009: 센터가 얻은 【起】 엑시드2 — 상대 시그니가 「アタックできない」를 얻는다", "WDK09-009", function(t)
  local center = wdk(t, "001")
  t:put(N["009"], 0, "key")
  local u1, u2 = t:put(N["005"], 0, "lrig_trash"), t:put(N["004"], 0, "lrig_trash")
  t:put_under(u1, center)
  t:put_under(u2, center)
  local s = t:put(101, 1, "signi_center")
  t:begin(0, PHASE_ATTACK)
  t:expect(t:wait(HINT_PRE_ATTACK))
  local act = t:action(ACT_ABILITY, center)
  t:expect(act ~= nil, "《アタックフェイズアイコン》")
  t:expect(t:answer(act))
  t:expect(t:wait(HINT_EXCEED))
  t:expect(t:answer(u1, u2))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(s))
  t:expect(t:wait(HINT_PRE_ATTACK))
  t:expect(t:keyword(s, EFFECT_CANNOT_ATTACK) and #t:under(center) == 0)
end)

-- ── 010 レイズ・オブ・エッジ ──

case("K09-010: 상대 시그니 1체를 트래시에", "WDK09-010", function(t)
  wdk(t, "001")
  t:put(100, 0, "ena")
  t:put(100, 0, "ena")
  local arts = t:put(N["010"], 0, "lrig_deck")
  local s = t:put(101, 1, "signi_center")
  use(t, arts)
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(t:cards(0, "ena")))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(s))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(s, 1, "trash"))
end)

-- ── 011 リュウジョウ ──

case("K09-011: 【自】 상대 어택 페이즈 시작 때 선언한 레벨이 맞으면 1장", "WDK09-011", function(t)
  wdk(t, "001")
  t:put(N["011"], 0, "signi_center")
  t:begin(1, PHASE_ATTACK)
  t:expect(t:wait(HINT_DECLARE))
  t:expect(t:request().player == 0)
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_ATTACK_LRIG))
  t:expect(t:count(1, "trash") == 1 and t:count(0, "hand") == 1, "Lv1 시그니가 맞았다")
end)

case("K09-011: 【出】《青》 【ゲート】 존의 상대 시그니를 덱 위 세 번째에, 덱 1장이면 맨 아래", "WDK09-011 FAQ 1·3", function(t)
  wdk(t, "001", {no_opp_deck = true})
  t:put(101, 1, "main_deck")
  t:place_gate(1, "signi_left")
  local target = t:put(101, 1, "signi_left")
  t:put(101, 1, "signi_right")
  local ryu = t:put(N["011"], 0, "hand")
  t:put(100, 0, "ena")
  main(t)
  t:expect(t:answer(t:action(ACT_PLAY, ryu, "signi_center")))
  t:expect(t:wait(HINT_USE_TRIGGER))
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(t:cards(0, "ena")))
  t:expect(t:wait(HINT_TARGET))
  t:expect(#t:request().options == 1, "【ゲート】 존만")
  t:expect(t:answer(target))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:cards(1, "main_deck")[1] == target)
end)

case("K09-011: 라이프 버스트 — 손패 0장이어도 상대 시그니를 덱 맨 위에", "WDK09-011 FAQ 4", function(t)
  wdk(t, "001")
  t:put(N["011"], 0, "life_cloth")
  t:card{cid = 111, power = 3000, level = 1}
  local att = t:put(111, 1, "signi_right")
  local s = t:put(101, 1, "signi_left")
  t:begin(1, PHASE_ATTACK)
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:answer(att))
  t:expect(t:wait(HINT_LIFEBURST))
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(s))
  t:expect(t:wait(HINT_ATTACK_LRIG))
  local deck = t:cards(1, "main_deck")
  t:expect(deck[#deck] == s)
end)

-- ── 012 パブロペ ──

case("K09-012: 【起】《青》《青》《ダウン》 상대 시그니를 덱 위 세 번째에", "WDK09-012", function(t)
  wdk(t, "001")
  local p = t:put(N["012"], 0, "signi_center")
  t:put(100, 0, "ena")
  t:put(100, 0, "ena")
  local s = t:put(101, 1, "signi_center")
  main(t)
  t:expect(t:answer(t:action(ACT_ABILITY, p)))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(t:cards(0, "ena")))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(s))
  t:expect(t:wait(HINT_MAIN))
  local deck = t:cards(1, "main_deck")
  t:expect(deck[#deck - 2] == s and t:flags(p) & CF_DOWN ~= 0)
  t:expect(t:action(ACT_ABILITY, p) == nil, "다운 상태라 코스트를 낼 수 없다")
end)

-- ── 013 B・スカイジュ ──

case("K09-013: 【出】 상대 트래시 2장을 상대가 정한 순서로 덱 아래, 그 뒤 【自】 한 번 -2000", "WDK09-013 FAQ 1", function(t)
  wdk(t, "001")
  local x, y = t:put(101, 1, "trash"), t:put(101, 1, "trash")
  local s = t:put(101, 1, "signi_center")
  local sky = t:put(N["013"], 0, "hand")
  main(t)
  t:expect(t:answer(t:action(ACT_PLAY, sky, "signi_center")))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(x, y))
  t:expect(t:wait(HINT_ORDER))
  t:expect(t:request().player == 1)
  t:expect(t:answer(x, y))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(s))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:power(s) == 1000 and t:is_in(x, 1, "main_deck") and t:is_in(y, 1, "main_deck"))
end)

-- ── 014 オタル ──

case("K09-014: 이 턴에 내 효과로 상대 카드가 덱에 갔으면 어택할 때 1장", "WDK09-014", function(t)
  wdk(t, "001")
  local o = t:put(N["014"], 0, "signi_center")
  t:put(100, 0, "ena")
  t:put(100, 0, "ena")
  local p = t:put(N["012"], 0, "signi_left")
  local s = t:put(101, 1, "signi_right")
  main(t)
  t:expect(t:answer(t:action(ACT_ABILITY, p)))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(t:cards(0, "ena")))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(s))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:answer(t:action(ACT_END)))
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:answer(o))
  t:expect(t:wait(HINT_ATTACK_LRIG))
  t:expect(t:count(0, "hand") == 1)
end)

-- ── 015 バンクバ ──

case("K09-015: 상대 트래시 1장을 덱 아래에 놓으면 시그니를 다른 존으로 옮길 수 있다", "WDK09-015 FAQ 2", function(t)
  wdk(t, "001")
  local b = t:put(N["015"], 0, "signi_center")
  local x = t:put(101, 1, "trash")
  local s = t:put(101, 1, "signi_left")
  main(t)
  t:expect(t:answer(t:action(ACT_ABILITY, b)))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(x))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(s))
  t:expect(t:wait(HINT_SCRIPT))
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_ZONE))
  t:expect(#t:request().options == 2, "상대 쪽 빈 존 둘")
  t:expect(t:answer(t:request().options[1]))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(x, 1, "main_deck") and t:is_in(s, 1, "signi_center"))
end)

case("K09-015: 상대 트래시가 비어 있으면 옮기지 않는다", "WDK09-015 FAQ 1", function(t)
  wdk(t, "001")
  local b = t:put(N["015"], 0, "signi_center")
  local s = t:put(101, 1, "signi_left")
  main(t)
  t:expect(t:answer(t:action(ACT_ABILITY, b)))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(s))
  t:expect(t:wait(HINT_MAIN))
  t:expect(not t:saw(HINT_ZONE) and t:is_in(s, 1, "signi_left"))
end)

-- ── 017 マリナカ ──

case("K09-017: 중앙에 나오면 상대 패를 보고 무색이 아닌 카드 1장까지 — 상대는 덱 아래에 놓고 1장 뽑는다", "WDK09-017 FAQ 1", function(t)
  wdk(t, "001")
  local h = t:put(101, 1, "hand")
  t:put(N["018"], 1, "hand")  -- 무색
  local m = t:put(N["017"], 0, "hand")
  main(t)
  t:expect(t:answer(t:action(ACT_PLAY, m, "signi_center")))
  t:expect(t:wait(HINT_SELECT))
  t:expect(#t:request().options == 1 and t:can_see(0, h))
  t:expect(t:answer(h))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(h, 1, "main_deck") and t:count(1, "hand") == 2)
end)

case("K09-017: 중앙이 아니면 아무것도 없다", "WDK09-017", function(t)
  wdk(t, "001")
  t:put(101, 1, "hand")
  local m = t:put(N["017"], 0, "hand")
  main(t)
  t:expect(t:answer(t:action(ACT_PLAY, m, "signi_left")))
  t:expect(t:wait(HINT_MAIN))
  t:expect(not t:saw(HINT_SELECT))
end)

-- ── 018 サーバント　Ｄ４ ──

case("K09-018: 라이프 버스트 — 트래시의 ＜精元＞ 시그니를 패로", "WDK09-018", function(t)
  wdk(t, "001")
  local d2 = t:put(N["019"], 0, "trash")
  t:put(N["018"], 0, "life_cloth")
  t:card{cid = 111, power = 3000, level = 1}
  local att = t:put(111, 1, "signi_right")
  t:begin(1, PHASE_ATTACK)
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:answer(att))
  t:expect(t:wait(HINT_LIFEBURST))
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(d2))
  t:expect(t:wait(HINT_ATTACK_LRIG))
  t:expect(t:is_in(d2, 0, "hand"))
end)

-- ── 022 ＢＲＩＧＨＴＮＥＳＳ ──

local function bright(t, field, trash)
  wdk(t, "001")
  local f = field and t:put(N["016"], 0, "signi_center") or nil
  local tr = trash and t:put(N["016"], 0, "trash") or nil
  local sp = t:put(N["022"], 0, "hand")
  use(t, sp)
  t:expect(t:wait(HINT_MODE))
  t:expect(t:answer(0))
  return f, tr
end

case("K09-022: ① 장의 ＜迷宮＞을 트래시에, 트래시의 ＜迷宮＞을 패로", "WDK09-022 FAQ 3", function(t)
  local f, tr = bright(t, true, true)
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(f))
  t:expect(t:wait(HINT_TARGET))
  t:expect(#t:request().options == 1, "사용 시점의 트래시 카드만(FAQ 1)")
  t:expect(t:answer(tr))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(f, 0, "trash") and t:is_in(tr, 0, "hand"))
end)

case("K09-022: ① 장에 ＜迷宮＞이 없으면 트래시에서 패로 넣지 않는다", "WDK09-022 FAQ 4", function(t)
  local _, tr = bright(t, false, true)
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(tr))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(tr, 0, "trash"))
end)
