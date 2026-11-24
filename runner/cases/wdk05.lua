-- WDK05 リメンバ 구축덱 카드 스크립트 케이스(タマ 쪽은 WDK-F03과 같은 카드). 근거는 카드별 FAQ(cards.json)

local N = {}
local EI, BLUE, OPP, OPP2, OPP3, BIG, SPELL = 200000, 203000, 101000, 101002, 101003, 102000, 204000

local function wd(t, center)
  t:start{db = true, seed = 1}
  for i = 1, 20 do N[i] = t:no(("WDK05-R%02d"):format(i)) end
  t:card{cid = EI, power = 4000, level = 2, classes = {"精像：英知"}, color = COLOR_BLUE}
  t:signi(BLUE, 1000, COLOR_BLUE, 1)
  t:signi(OPP, 3000, COLOR_RED, 1)
  t:signi(OPP2, 3000, COLOR_RED, 2)
  t:signi(OPP3, 3000, COLOR_RED, 3)
  t:signi(BIG, 15000, COLOR_RED, 4)
  t:card{cid = SPELL, type = TYPE_SPELL, color = COLOR_BLUE}
  t:fill(BLUE, 0, "main_deck", 15)
  t:fill(OPP, 1, "main_deck", 15)
  t:fill(BLUE, 0, "life_cloth", 5)
  t:fill(OPP, 1, "life_cloth", 5)
  t:put(N[1], 1, "lrig_center")
  return t:put(N[center or 1], 0, "lrig_center")
end

local function main(t, p)
  t:begin(p or 0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
end

local function ena(t, n)
  for _ = 1, n do t:put(BLUE, 0, "ena") end
end

local function pay(t, n)
  t:expect(t:wait(HINT_PAY_ENA), "에나 " .. n)
  t:expect(t:request().min == n, "코스트 " .. n)
  t:expect(t:answer(table.unpack(t:cards(0, "ena"), 1, n)))
end

local function pick(t, hint, ...)
  t:expect(t:wait(hint), "힌트 " .. hint)
  t:expect(t:answer(...))
end

local function use(t, c) t:expect(t:answer(t:action(ACT_USE, c))) end
local function play(t, c, z) t:expect(t:answer(t:action(ACT_PLAY, c, z or "signi_left"))) end
local function frozen(t, c) return t:flags(c) & CF_FROZEN ~= 0 end

-- 덱을 아래부터 이 카드들로
local function deck(t, ...)
  for _, c in ipairs(t:cards(0, "main_deck")) do t:move(c, 0, "exclude") end
  local out = {}
  for i, cid in ipairs{...} do out[i] = t:put(cid, 0, "main_deck") end
  return out
end

-- ── 루리그 ──

case("リメンバ・ナイト: 【出】 상대 시그니 모두 동결, 【起】 3장 뽑고 2장을 아래에. 덱이 모자라도 리프레시하지 않는다", "WDK05-R01 FAQ 1·2", function(t)
  for _, n in ipairs{3, 2} do
    wd(t, 2)
    local g, x, y = t:put(N[1], 0, "lrig_deck"), t:put(BIG, 1, "signi_left"), t:put(OPP, 1, "signi_center")
    t:begin(0, PHASE_GROW)
    pick(t, HINT_GROW, g)
    t:expect(t:wait(HINT_MAIN))
    t:expect(frozen(t, x) and frozen(t, y) and t:coins(0) == 2)
    for i, c in ipairs(t:cards(0, "main_deck")) do if i > n then t:move(c, 0, "trash") end end
    t:expect(t:answer(t:action(ACT_ABILITY, g)))
    t:expect(t:wait(HINT_SELECT))
    t:expect(t:request().min == 2 and t:request().max == 2)
    local o = t:request().options
    t:expect(t:answer(o[1], o[2]))
    pick(t, HINT_ORDER, o[2], o[1])
    t:expect(t:wait(HINT_MAIN))
    local d = t:cards(0, "main_deck")
    t:expect(t:count(0, "hand") == n - 2 and #d == 2 and t:refreshes(0) == 0 and t:coins(0) == 1)
    t:expect(t:action(ACT_ABILITY, g) == nil)
  end
end)

case("リメンバ 레벨 1~3", "WDK05-R02~R04 FAQ", function(t)
  wd(t, 3)
  local g = t:put(N[2], 0, "lrig_deck")
  ena(t, 2)
  t:begin(0, PHASE_GROW)
  pick(t, HINT_GROW, g)
  pay(t, 2)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:coins(0) == 2)
  for _, yes in ipairs{1, 0} do
    wd(t, 4)
    g = t:put(N[3], 0, "lrig_deck")
    t:add_coin(0, 1)
    ena(t, 1)
    t:begin(0, PHASE_GROW)
    pick(t, HINT_GROW, g)
    pay(t, 1)
    pick(t, HINT_USE_TRIGGER, yes)
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:coins(0) == 1 - yes and t:count(0, "hand") == yes)
    wd(t, 5)
    g = t:put(N[4], 0, "lrig_deck")
    local h = t:put(BLUE, 0, "hand")
    t:begin(0, PHASE_GROW)
    pick(t, HINT_GROW, g)
    pick(t, HINT_USE_TRIGGER, yes)
    if yes == 1 then pick(t, HINT_DISCARD, h) end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:coins(0) == yes and t:count(0, "hand") == 1 - yes)
  end
end)

-- ── 아츠 ──

case("ドロー・パーフェクト: 덱이 모자라면 있는 만큼 뽑고 리프레시", "WDK05-R06 FAQ 1", function(t)
  for _, n in ipairs{8, 5} do
    wd(t)
    local a = t:put(N[6], 0, "lrig_deck")
    ena(t, 4)
    for i, c in ipairs(t:cards(0, "main_deck")) do if i > n then t:move(c, 0, "trash") end end
    main(t)
    use(t, a)
    pay(t, 4)
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:count(0, "hand") == math.min(7, n) and t:refreshes(0) == (n == 5 and 1 or 0))
  end
end)

case("イコール・プライズ: 버린 시그니와 같은 레벨을 바니시. 같은 레벨은 같이 버릴 수 없다", "WDK05-R07 FAQ 1·2", function(t)
  wd(t)
  local a = t:put(N[7], 0, "lrig_deck")
  local h1, h1b, h2, h3 = t:put(BLUE, 0, "hand"), t:put(BLUE, 0, "hand"), t:put(EI, 0, "hand"), t:put(OPP3, 0, "hand")
  local x, y = t:put(OPP, 1, "signi_left"), t:put(OPP3, 1, "signi_center")
  ena(t, 2)
  t:begin(1, PHASE_ATTACK)
  t:expect(t:wait(HINT_DEFENSE))
  use(t, a)
  pay(t, 2)
  t:expect(t:wait(HINT_DISCARD))
  t:expect(t:request().min == 0 and t:request().max == 3)
  t:expect(not t:answer(h1, h1b))
  t:expect(t:answer(h1, h2, h3))
  pick(t, HINT_TARGET, x)
  pick(t, HINT_TARGET, y)
  t:wait(HINT_ATTACK_LRIG)
  t:expect(t:is_in(x, 1, "ena") and t:is_in(y, 1, "ena") and t:is_in(h2, 0, "trash"))
end)

case("イコール・プライズ: 1장도 버리지 않아도 된다", "WDK05-R07 FAQ 3", function(t)
  wd(t)
  local a, x = t:put(N[7], 0, "lrig_deck"), t:put(OPP, 1, "signi_left")
  t:put(BLUE, 0, "hand")
  ena(t, 2)
  t:begin(1, PHASE_ATTACK)
  t:expect(t:wait(HINT_DEFENSE))
  use(t, a)
  pay(t, 2)
  t:expect(t:wait(HINT_DISCARD) and t:answer())
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:is_in(x, 1, "signi_left"))
end)

case("イコール・プライズ: 《チドウ》 여러 장은 서로 다른 레벨로 친다", "WDK05-R07 FAQ 4", function(t)
  wd(t)
  t:move(t:cards(0, "lrig_center")[1], 0, "exclude")
  t:put(t:no("WD21-001"), 0, "lrig_center")  -- 카니발 한정
  local ch = t:no("WD21-012")
  t:put(ch, 0, "signi_left")
  local a, p, q = t:put(N[7], 0, "lrig_deck"), t:put(ch, 0, "hand"), t:put(ch, 0, "hand")
  local x, y = t:put(OPP2, 1, "signi_left"), t:put(OPP3, 1, "signi_center")
  ena(t, 2)
  t:begin(1, PHASE_ATTACK)
  t:expect(t:wait(HINT_DEFENSE))
  use(t, a)
  pay(t, 2)
  pick(t, HINT_DISCARD, p, q)
  pick(t, HINT_DECLARE, 2)
  pick(t, HINT_DECLARE, 2)
  t:expect(t:wait(HINT_DECLARE), "이미 친 레벨은 다시 묻는다")
  t:expect(t:answer(3))
  pick(t, HINT_TARGET, x)
  pick(t, HINT_TARGET, y)
  t:wait(HINT_ATTACK_LRIG)
  t:expect(t:is_in(x, 1, "ena") and t:is_in(y, 1, "ena"))
end)

case("ブルー・ジャミング: 다운·동결, 2장 뽑고 1장 버린다. 덱이 1장이면 리프레시는 나중에", "WDK05-R08 FAQ 1", function(t)
  for _, n in ipairs{15, 1} do
    wd(t)
    local a, x = t:put(N[8], 0, "lrig_deck"), t:put(OPP, 1, "signi_left")
    ena(t, 2)
    for i, c in ipairs(t:cards(0, "main_deck")) do if i > n then t:move(c, 0, "trash") end end
    t:begin(1, PHASE_ATTACK)
    t:expect(t:wait(HINT_DEFENSE))
    use(t, a)
    pay(t, 2)
    pick(t, HINT_TARGET, x)
    t:expect(t:wait(HINT_DISCARD))
    t:expect(t:answer(t:request().options[1]))
    t:wait(HINT_ATTACK_LRIG)
    t:expect(t:flags(x) & CF_DOWN ~= 0 and frozen(t, x) and t:count(0, "hand") == math.min(2, n) - 1)
    t:expect(t:refreshes(0) == (n == 1 and 1 or 0))
  end
end)

case("フリーズ・サッド: 동결된 상대 시그니만 모두 바니시", "WDK05-R09", function(t)
  wd(t)
  local a, x, y = t:put(N[9], 0, "lrig_deck"), t:put(BIG, 1, "signi_left"), t:put(OPP, 1, "signi_center")
  t:set_flags(x, CF_FROZEN)
  main(t)
  use(t, a)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(x, 1, "ena") and t:is_in(y, 1, "signi_center"))
end)

-- ── 시그니 ──

case("ノーベル: 덱 아래 2장의 레벨 합계와 같은 레벨을 바니시", "WDK05-R11 FAQ 1~3", function(t)
  for _, c in ipairs{{{EI, BLUE}, OPP3, true}, {{EI, BLUE}, OPP2, false}, {{SPELL, EI}, OPP2, true}, {{SPELL, SPELL}, OPP, false}} do
    wd(t)
    local h, x = t:put(N[11], 0, "signi_left"), t:put(c[2], 1, "signi_center")
    local d = deck(t, c[1][1], c[1][2], BLUE, BLUE)
    ena(t, 1)
    t:begin(0, PHASE_ATTACK)
    pick(t, HINT_ATTACK_SIGNI, h)
    pick(t, HINT_SCRIPT, 1)
    pay(t, 1)
    if c[3] then pick(t, HINT_TARGET, x) end
    t:wait(HINT_ATTACK_LRIG)
    t:expect(t:is_in(x, 1, c[3] and "ena" or "signi_center") and t:is_in(d[1], 0, "trash") and t:is_in(d[2], 0, "trash"))
  end
end)

case("ノーベル: 덱이 1장이면 그 1장으로 처리하고 리프레시", "WDK05-R11 FAQ 3", function(t)
  wd(t)
  local h, x = t:put(N[11], 0, "signi_left"), t:put(OPP2, 1, "signi_center")
  deck(t, EI)
  ena(t, 1)
  t:begin(0, PHASE_ATTACK)
  pick(t, HINT_ATTACK_SIGNI, h)
  pick(t, HINT_SCRIPT, 1)
  pay(t, 1)
  pick(t, HINT_TARGET, x)
  t:wait(HINT_ATTACK_LRIG)
  t:expect(t:is_in(x, 1, "ena") and t:refreshes(0) == 1)
end)

case("ノーベル: LB 다운하고 1장", "WDK05-R11", function(t)
  wd(t)
  t:put(N[11], 0, "life_cloth")
  local a, b = t:put(BIG, 1, "signi_left"), t:put(BIG, 1, "signi_center")
  t:begin(1, PHASE_ATTACK)
  pick(t, HINT_ATTACK_SIGNI, a)
  pick(t, HINT_LIFEBURST, 1)
  pick(t, HINT_TARGET, b)
  t:wait(HINT_ATTACK_LRIG)
  t:expect(t:flags(b) & CF_DOWN ~= 0 and t:count(0, "hand") == 1)
end)

case("ホロスチャート: 동결해서 3체가 되면 상대가 버린다", "WDK05-R12 FAQ 1", function(t)
  for _, n in ipairs{2, 1} do
    wd(t)
    local h = t:put(N[12], 0, "hand")
    local x = {t:put(OPP, 1, "signi_left"), t:put(OPP, 1, "signi_center"), t:put(OPP, 1, "signi_right")}
    for i = 1, n do t:set_flags(x[i], CF_FROZEN) end
    local o = t:put(OPP, 1, "hand")
    main(t)
    play(t, h)
    pick(t, HINT_TRIGGER_ORDER, 0)
    pick(t, HINT_TARGET, x[3])
    if n == 2 then pick(t, HINT_DISCARD, o) end
    t:expect(t:wait(HINT_MAIN))
    t:expect(frozen(t, x[3]) and t:count(1, "hand") == (n == 2 and 0 or 1))
  end
end)

case("カブケン·エンヤス: 1장 뽑을 때마다(턴 2회·1회)", "WDK05-R13 FAQ 1, WDK05-R15 FAQ 1", function(t)
  wd(t)
  local a, b = t:put(N[13], 0, "signi_left"), t:put(N[15], 0, "signi_center")
  local h = t:put(N[17], 0, "hand")
  local arts = t:put(N[6], 0, "lrig_deck")
  ena(t, 4)
  main(t)
  use(t, arts)
  pay(t, 4)
  for _ = 1, 12 do
    t:step()
    local q = t:request()
    if not q or q.hint == HINT_MAIN then break end
    t:answer(table.unpack(q.options, 1, q.min))
  end
  t:expect(t:power(a) == 16000 and t:power(b) == 10000)
end)

case("イグ・バナナン: 【起】 합계가 4면 2체까지 동결(시그니 1장과 스펠 1장이어도). 턴 1회", "WDK05-R14 FAQ 1·3·4", function(t)
  for _, c in ipairs{{{EI, EI}, true}, {{SPELL, BIG}, true}, {{EI, BLUE}, false}, {{SPELL, SPELL}, false}} do
    wd(t)
    local h, x = t:put(N[14], 0, "signi_left"), t:put(OPP, 1, "signi_left")
    deck(t, c[1][1], c[1][2], BLUE, BLUE)
    main(t)
    t:expect(t:answer(t:action(ACT_ABILITY, h)))
    if c[2] then
      t:expect(t:wait(HINT_TARGET))
      t:expect(t:request().min == 0)
      t:expect(t:answer(x))
    end
    t:expect(t:wait(HINT_MAIN))
    t:expect(frozen(t, x) == c[2] and t:count(0, "trash") == 2 and t:action(ACT_ABILITY, h) == nil)
  end
end)

case("イグ・バナナン·エンダカ: 1장 뽑고 1장을 덱 아래에. 덱이 1장이어도 리프레시하지 않는다", "WDK05-R14 FAQ 2, WDK05-R17 FAQ 1", function(t)
  for _, no in ipairs{14, 17} do
    wd(t)
    local h, k = t:put(N[no], 0, "hand"), t:put(EI, 0, "hand")
    deck(t, BLUE)
    main(t)
    play(t, h)
    pick(t, HINT_SELECT, k)
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(k, 0, "main_deck") and t:count(0, "hand") == 1 and t:refreshes(0) == 0)
  end
end)

case("FROZEN FINGER: ＜英知＞를 놓고 동결된 시그니를 바니시. 없으면 하지 않는다", "WDK05-R20 FAQ 1·2", function(t)
  for _, on in ipairs{true, false} do
    wd(t)
    local sp, h = t:put(N[20], 0, "hand"), t:put(on and EI or BLUE, 0, "signi_left")
    local x = t:put(BIG, 1, "signi_left")
    t:put(OPP, 1, "signi_center")
    t:set_flags(x, CF_FROZEN)
    main(t)
    use(t, sp)
    pick(t, HINT_MODE, 0)
    if on then pick(t, HINT_TARGET, h) end
    t:expect(t:wait(HINT_TARGET))
    t:expect(#t:request().options == 1)
    t:expect(t:answer(x))
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(x, 1, on and "ena" or "signi_left"))
  end
end)
