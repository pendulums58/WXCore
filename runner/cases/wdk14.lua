-- WDK14 タウィル 구축덱 카드 스크립트 케이스와 【ビート】 룰. 근거는 카드별 FAQ(cards.json)·용어집

local N = {}
local RED, AK1, AK2, AK3, AK4, OPP, MID, BIG = 200000, 200001, 200002, 200003, 200004, 101000, 101500, 102000

local function wd(t, center)
  t:start{db = true, seed = 1}
  for i = 1, 22 do N[i] = t:no(("WDK14-%03d"):format(i)) end
  t:signi(RED, 1000, COLOR_RED, 1)
  for lv, cid in ipairs{AK1, AK2, AK3, AK4} do
    t:card{cid = cid, power = 1000 * lv, level = lv, classes = {"精像：悪魔"}, color = COLOR_RED}
  end
  t:signi(OPP, 3000, COLOR_BLUE, 1)
  t:signi(MID, 9000, COLOR_BLUE, 3)
  t:signi(BIG, 15000, COLOR_BLUE, 4)
  t:fill(RED, 0, "main_deck", 15)
  t:fill(OPP, 1, "main_deck", 15)
  t:fill(RED, 0, "life_cloth", 5)
  t:fill(OPP, 1, "life_cloth", 5)
  t:put(N[1], 1, "lrig_center")
  return t:put(N[center or 1], 0, "lrig_center")
end

local function main(t, p)
  t:begin(p or 0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
end

local function ena(t, n, cid)
  for _ = 1, n do t:put(cid or RED, 0, "ena") end
end

local function pick(t, hint, ...)
  t:expect(t:wait(hint), "힌트 " .. hint)
  t:expect(t:answer(...))
end

local function pay(t, n)
  t:expect(t:wait(HINT_PAY_ENA), "에나 " .. n)
  t:expect(t:answer(table.unpack(t:cards(0, "ena"), 1, n)))
end

local function use(t, c) t:expect(t:answer(t:action(ACT_USE, c))) end
local function ability(t, c, n) return t:action(ACT_ABILITY, c, n or 0) end

-- ── 【ビート】 룰 ──

case("ビート: 공개 존. 놓인 턴이 끝나면 패를 버린 뒤 전부 트래시", "용어집: ビート", function(t)
  local lc = wd(t)
  local s = t:put(AK2, 0, "signi_left")
  local o = t:put(OPP, 1, "beat")
  main(t)
  t:expect(t:answer(ability(t, lc, 0)))
  pick(t, HINT_SELECT, s)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(s, 0, "beat") and t:can_see(1, s) and t:count(0, "hand") == 1)
  t:expect(t:answer(t:action(ACT_END)))
  while t:wait(HINT_MAIN) and t:turn_player() == 0 do t:answer(t:action(ACT_END)) end
  t:expect(t:is_in(s, 0, "trash") and t:is_in(o, 1, "trash"), "양쪽 다")
end)

-- ── 카드 ──

case("タウィル＝フィーラ: 【ビート】에 레벨 1~4가 다 있으면 어택 페이즈 개시 시 뽑거나 エナチャージ", "WDK14-001", function(t)
  for _, full in ipairs{true, false} do
    wd(t)
    for _, cid in ipairs{AK1, AK2, AK3, full and AK4 or AK3} do t:put(cid, 0, "beat") end
    t:begin(0, PHASE_ATTACK)
    if full then pick(t, HINT_MODE, 0) end
    t:expect(t:wait(HINT_PRE_ATTACK) or t:wait(HINT_ATTACK_SIGNI))
    t:expect(t:count(0, "hand") == (full and 1 or 0))
  end
end)

case("タウィル＝フィーラ: プライマル 빨강 아츠를 루리그 트래시에 두고 트래시의 ＜悪魔＞ 3장까지 장에", "WDK14-001 FAQ 3", function(t)
  for _, arts in ipairs{true, false} do
    local lc = wd(t)
    t:add_coin(0, 1)
    local a = arts and t:put(N[7], 0, "lrig_deck")
    local x, y = t:put(AK1, 0, "trash"), t:put(AK2, 0, "trash")
    t:begin(0, PHASE_ATTACK)
    t:expect(t:wait(HINT_PRE_ATTACK))
    if not arts then
      t:expect(ability(t, lc, 0) == nil, "빨강 아츠가 없으면 쓸 수 없다")
    else
      t:expect(t:answer(ability(t, lc, 0)))
      pick(t, HINT_SELECT, a)
      pick(t, HINT_TARGET, x, y)
      t:expect(t:wait(HINT_ZONE))
      t:expect(t:answer(t:request().options[1]))
      t:expect(t:wait(HINT_ZONE))
      t:expect(t:answer(t:request().options[1]))
      t:expect(t:wait(HINT_PRE_ATTACK))
      t:expect(t:is_in(a, 0, "lrig_trash") and t:at(x) ~= nil and t:at(y) ~= nil and t:coins(0) == 0)
    end
  end
end)

case("緩急火号: 2장 뽑고 【エナチャージ２】, 자기 라이프 1장 크러시", "WDK14-007 FAQ 1", function(t)
  wd(t)
  local arts = t:put(N[7], 0, "lrig_deck")
  ena(t, 2)
  main(t)
  use(t, arts)
  pay(t, 2)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "hand") == 2 and t:count(0, "ena") == 3 and t:count(0, "life_cloth") == 4)
end)

case("回心転火: 1장 패, 1장 【ビート】, 【ビート】로 한 시그니와 같은 레벨을 바니시", "WDK14-008", function(t)
  wd(t)
  local arts = t:put(N[8], 0, "lrig_deck")
  local b = t:put(AK3, 0, "main_deck")
  local x, y = t:put(MID, 1, "signi_left"), t:put(BIG, 1, "signi_center")
  ena(t, 1)
  main(t)
  use(t, arts)
  pay(t, 1)
  t:expect(t:wait(HINT_SELECT))
  t:expect(t:answer(t:request().options[2]))
  pick(t, HINT_SELECT, b)
  t:expect(t:wait(HINT_ORDER) or true)
  if t:request().hint == HINT_ORDER then t:expect(t:answer(table.unpack(t:request().options))) end
  t:expect(t:wait(HINT_TARGET))
  t:expect(not t:answer(y), "레벨 4는 안 된다")
  t:expect(t:answer(x))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(b, 0, "beat") and t:is_in(x, 1, "ena") and t:count(0, "hand") == 1)
end)

case("奏楽の鍵主　ウムル: 덱 위 4장을 트래시에 두고, 센터가 ＜タウィル＞면 2장까지 장에", "WDK14-009 FAQ 2", function(t)
  wd(t)
  local k = t:put(N[9], 0, "lrig_deck")
  t:put(AK2, 0, "main_deck")
  t:add_coin(0, 1)
  main(t)
  t:expect(t:answer(t:action(ACT_KEY, k)))
  t:expect(t:wait(HINT_TARGET))
  local opts = t:request().options
  t:expect(#opts >= 2 and t:answer(opts[1], opts[2]), "덱에서 트래시에 둔 것도 고를 수 있다")
  t:expect(t:wait(HINT_ZONE))
  t:expect(t:answer(t:request().options[1]))
  t:expect(t:wait(HINT_ZONE))
  t:expect(t:answer(t:request().options[1]))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "signi_left") + t:count(0, "signi_center") + t:count(0, "signi_right") == 2)
end)

case("炎魔の聖墓　ムーンカル: 【ビート】 5장 이상이면 어택 페이즈 개시 시 바니시", "WDK14-011", function(t)
  for _, n in ipairs{5, 4} do
    wd(t)
    t:put(N[11], 0, "signi_left")
    for _ = 1, n do t:put(RED, 0, "beat") end
    local x = t:put(BIG, 1, "signi_left")
    t:begin(0, PHASE_ATTACK)
    if n == 5 then pick(t, HINT_TARGET, x) end
    t:expect(t:wait(HINT_PRE_ATTACK))
    t:expect(t:is_in(x, 1, n == 5 and "ena" or "signi_left"))
  end
end)

case("炎魔の聖墓　ナーキル: 코스트로 【ビート】가 4장이 되면 1장 뽑는다. 5장 이상이면 발동하지 않는다", "WDK14-013 FAQ 1", function(t)
  for _, before in ipairs{3, 2, 5} do
    wd(t)
    for _ = 1, before do t:put(RED, 0, "beat") end
    local s = t:put(N[13], 0, "hand")
    local c = t:put(AK1, 0, "trash")
    main(t)
    t:expect(t:answer(t:action(ACT_PLAY, s, "signi_left")))
    if before <= 4 then
      pick(t, HINT_USE_TRIGGER, 1)
      pick(t, HINT_SELECT, c)
    end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:count(0, "hand") == (before == 3 and 1 or 0) and t:is_in(c, 0, before <= 4 and "beat" or "trash"))
  end
end)

case("炎魔の孔雀　カイム: 다른 카드가 【ビート】가 되면 《赤》《赤》로 바니시. 내지 않아도 《ターン１回》", "WDK14-014 FAQ 2", function(t)
  local lc = wd(t)
  t:put(N[14], 0, "signi_left")
  local a, b = t:put(RED, 0, "signi_center"), t:put(RED, 0, "signi_right")
  local x = t:put(MID, 1, "signi_left")
  ena(t, 2)
  main(t)
  t:expect(t:answer(ability(t, lc, 0)))
  pick(t, HINT_SELECT, a)
  pick(t, HINT_TARGET, x)
  pick(t, HINT_SCRIPT, 0)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(a, 0, "beat") and t:is_in(x, 1, "signi_left"))
end)

case("炎魔の火鉢　ブリジット: 트래시에서 【ビート】가 돼도 《赤》로 바니시", "WDK14-015 FAQ 1", function(t)
  wd(t)
  local s = t:put(N[11], 0, "hand")
  local br = t:put(N[15], 0, "trash")
  local x = t:put(OPP, 1, "signi_left")
  ena(t, 2)
  main(t)
  t:expect(t:answer(t:action(ACT_PLAY, s, "signi_left")))
  pick(t, HINT_USE_TRIGGER, 1)
  pay(t, 1)
  pick(t, HINT_TARGET, br)
  pick(t, HINT_TARGET, x)
  pick(t, HINT_SCRIPT, 1)
  pay(t, 1)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(br, 0, "beat") and t:is_in(x, 1, "ena"))
end)

case("炎魔の幸運　カウカス: 【ビート】가 되면 1장 뽑고 1장 버린다(강제)", "WDK14-017 FAQ 1", function(t)
  local lc = wd(t)
  local s = t:put(N[17], 0, "signi_left")
  main(t)
  t:expect(t:answer(ability(t, lc, 0)))
  pick(t, HINT_SELECT, s)
  t:expect(t:wait(HINT_DISCARD))
  t:expect(t:answer(t:cards(0, "hand")[1]))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "hand") == 1 and t:count(0, "trash") == 1, "フィーラ로 1장, 카우카스로 뽑고 버림")
end)

case("熱音の稲光: ①은 ＜悪魔＞을 트래시에 두면 1장 버리고 2장. 패가 없어도 2장", "WDK14-022", function(t)
  wd(t)
  local sp = t:put(N[22], 0, "hand")
  local f = t:put(AK1, 0, "signi_left")
  main(t)
  use(t, sp)
  pick(t, HINT_MODE, 0)
  pick(t, HINT_TARGET, f)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(f, 0, "trash") and t:count(0, "hand") == 2)
end)
