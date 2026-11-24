-- WDK11 エマ 구축덱 카드 스크립트 케이스. 근거는 카드별 FAQ(cards.json)

local N = {}
local EI, EI4, WHITE, OPP, MID, BIG, BURST = 200000, 200004, 203000, 101000, 101500, 102000, 204000

local function wd(t, center)
  t:start{db = true, seed = 1}
  for i = 1, 22 do N[i] = t:no(("WDK11-%03d"):format(i)) end
  t:card{cid = EI, power = 4000, level = 2, classes = {"精像：英知"}, color = COLOR_WHITE}
  t:card{cid = EI4, power = 4000, level = 5, classes = {"精像：英知"}, color = COLOR_WHITE}
  t:signi(WHITE, 1000, COLOR_WHITE, 1)
  t:signi(OPP, 3000, COLOR_RED, 1)
  t:signi(MID, 9000, COLOR_RED, 3)
  t:signi(BIG, 15000, COLOR_RED, 4)
  t:card{cid = BURST, type = TYPE_SPELL, color = COLOR_WHITE}
  t:fill(WHITE, 0, "main_deck", 15)
  t:fill(OPP, 1, "main_deck", 15)
  t:fill(WHITE, 0, "life_cloth", 5)
  t:fill(OPP, 1, "life_cloth", 5)
  t:put(N[1], 1, "lrig_center")
  return t:put(N[center or 1], 0, "lrig_center")
end

local function main(t, p)
  t:begin(p or 0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
end

local function ena(t, n, cid)
  for _ = 1, n do t:put(cid or WHITE, 0, "ena") end
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

local function zone(t)
  t:expect(t:wait(HINT_ZONE), "존")
  t:expect(t:answer(t:request().options[1]))
end

local function use(t, c) t:expect(t:answer(t:action(ACT_USE, c))) end
local function play(t, c, z) t:expect(t:answer(t:action(ACT_PLAY, c, z or "signi_left"))) end

case("エマ　レベル４: 키를 루리그 덱에서 장에. 한정 조건·코스트 없이", "WDK11-001", function(t)
  for _, yes in ipairs{true, false} do
    wd(t, 2)
    local g, k, x = t:put(N[1], 0, "lrig_deck"), t:put(N[9], 0, "lrig_deck"), t:put(BIG, 1, "signi_left")
    t:begin(0, PHASE_GROW)
    pick(t, HINT_GROW, g)
    t:expect(t:wait(HINT_SELECT))
    if yes then
      t:expect(t:answer(k))
      pick(t, HINT_TARGET, x)
    else
      t:expect(t:answer())
    end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(k, 0, yes and "key" or "lrig_deck") and t:is_in(x, 1, yes and "hand" or "signi_left"))
  end
end)

case("エマ　レベル４: 어택하면 1장 뽑고, 《白》을 내면 낸 ＜英知＞도 되찾는다", "WDK11-001 FAQ 1·2", function(t)
  for _, key in ipairs{true, false} do
    local lc = wd(t)
    if key then t:put(N[9], 0, "key") end
    t:put(EI, 0, "signi_left")
    t:put(EI, 0, "ena")
    local e = t:cards(0, "ena")[1]
    t:begin(0, PHASE_ATTACK)
    pick(t, HINT_ATTACK_LRIG, lc)
    t:expect(t:wait(HINT_TRIGGER_ORDER))
    t:expect(t:answer(1), "드로를 먼저")
    if key then
      t:expect(t:wait(HINT_SCRIPT))
      t:expect(t:count(0, "hand") == 1 and t:answer(1))
      pay(t, 1)
      pick(t, HINT_TARGET, e)
    end
    t:wait(HINT_MAIN)
    t:expect(t:is_in(e, 0, key and "hand" or "ena") and not t:saw(key and HINT_USE_TRIGGER or HINT_SCRIPT))
  end
end)

case("エマ　レベル１: 1장 버리고 1장", "WDK11-004", function(t)
  for _, yes in ipairs{1, 0} do
    wd(t, 5)
    local g, h = t:put(N[4], 0, "lrig_deck"), t:put(WHITE, 0, "hand")
    t:begin(0, PHASE_GROW)
    pick(t, HINT_GROW, g)
    pick(t, HINT_USE_TRIGGER, yes)
    if yes == 1 then pick(t, HINT_DISCARD, h) end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(h, 0, yes == 1 and "trash" or "hand") and t:count(0, "hand") == 1)
  end
end)

case("サドゥン・クエスチョン: 둘 다 고르고, 상대 키가 있어야 두 번째도. 1체뿐이어도 쓴다", "WDK11-007 FAQ 1·2", function(t)
  for _, c in ipairs{{true, 2}, {false, 2}, {true, 1}} do  -- {상대 키, 상대 시그니}
    wd(t)
    local a, x = t:put(N[7], 0, "lrig_deck"), t:put(BIG, 1, "signi_left")
    local y = c[2] == 2 and t:put(OPP, 1, "signi_center")
    if c[1] then t:put(N[9], 1, "key") end
    ena(t, 2)
    t:begin(1, PHASE_ATTACK)
    t:expect(t:wait(HINT_DEFENSE))
    use(t, a)
    pay(t, 2)
    pick(t, HINT_TARGET, x)
    if y then
      t:expect(t:wait(HINT_TARGET))
      t:expect(#t:request().options == 1 and t:answer(y))
    end
    if not c[1] then
      t:expect(t:wait(HINT_ATTACK_SIGNI))
      t:expect(#t:request().options == 1 and t:request().options[1] == y)
    else
      t:expect(t:wait(HINT_ATTACK_LRIG))
      t:expect(t:request().player == 1 and not t:saw(HINT_ATTACK_SIGNI))
    end
  end
end)

case("スタディ・ハード: 시그니 2장까지(0장도 된다)", "WDK11-008 FAQ 1", function(t)
  for n = 0, 2 do
    wd(t)
    local a = t:put(N[8], 0, "lrig_deck")
    t:put(BURST, 0, "main_deck")
    main(t)
    use(t, a)
    t:expect(t:wait(HINT_SELECT))
    t:expect(#t:request().options == 15)
    t:expect(t:answer(table.unpack(t:request().options, 1, n)))
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:count(0, "hand") == n and t:count(0, "main_deck") == 16 - n)
  end
end)

case("ノーマン＆レイ: 코인 1과 《白》 2. 어택 페이즈에 엑시드 2로 어택을 막는다", "WDK11-009", function(t)
  local lc = wd(t)
  local k, x, y = t:put(N[9], 0, "lrig_deck"), t:put(BIG, 1, "signi_left"), t:put(OPP, 1, "signi_center")
  for i = 2, 3 do t:put_under(t:put(N[i], 0, "lrig_deck"), lc) end
  t:add_coin(0, 1)
  ena(t, 2)
  main(t)
  t:expect(t:answer(t:action(ACT_KEY, k)))
  pay(t, 2)
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:request().min == 0 and t:request().max == 2 and t:answer(x))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(x, 1, "hand") and t:coins(0) == 0)
  t:expect(t:wait(HINT_PRE_ATTACK))
  t:expect(t:answer(t:action(ACT_ABILITY, lc)))
  if t:wait(HINT_EXCEED) then t:expect(t:answer(table.unpack(t:under(lc)))) end
  pick(t, HINT_TARGET, y)
  t:wait(HINT_ATTACK_LRIG)
  t:expect(t:keyword(y, EFFECT_CANNOT_ATTACK) and #t:under(lc) == 0)
end)

case("ノーマン＆レイ: 센터가 ＜エマ＞가 아니거나 에나가 모자라면 낼 수 없다", "WDK11-009", function(t)
  local lc = wd(t)
  local k = t:put(N[9], 0, "lrig_deck")
  t:add_coin(0, 1)
  ena(t, 1)
  main(t)
  t:expect(t:action(ACT_KEY, k) == nil)
  lc = wd(t)
  t:lrig(300000, 4, 11, {"タマ"}, COLOR_WHITE)
  t:move(lc, 0, "exclude")
  t:put(300000, 0, "lrig_center")
  k = t:put(N[9], 0, "lrig_deck")
  t:add_coin(0, 1)
  ena(t, 2)
  main(t)
  t:expect(t:action(ACT_KEY, k) == nil)
end)

case("イザベラ: 다른 시그니를 놓고 정면을 바니시하면 대미지. 다른 시그니가 없으면 아무것도", "WDK11-011 FAQ 1·2", function(t)
  for _, c in ipairs{"yes", "no", "alone"} do
    wd(t)
    local h, x = t:put(N[11], 0, "signi_center"), t:put(BIG, 1, "signi_center")
    local o = c ~= "alone" and t:put(WHITE, 0, "signi_left")
    t:begin(0, PHASE_ATTACK)
    pick(t, HINT_ATTACK_SIGNI, h)
    pick(t, HINT_TARGET, x)
    if o then
      t:expect(t:wait(HINT_SELECT))
      t:expect(#t:request().options == 1)
      if c == "yes" then t:expect(t:answer(o)) else t:expect(t:answer()) end
    end
    t:wait(HINT_ATTACK_LRIG)
    t:expect(t:is_in(x, 1, c == "yes" and "ena" or "signi_center") and t:count(1, "life_cloth") == (c == "yes" and 4 or 5), c)
  end
end)

case("イザベラ: 【出】 자신 이외의 ＜英知＞를 장에. 존이 없거나 레벨이 높으면 못 낸다", "WDK11-011 FAQ 3·4", function(t)
  for _, c in ipairs{"ok", "full", "level"} do
    wd(t)
    local h, d = t:put(N[11], 0, "hand"), t:put(c == "level" and EI4 or EI, 0, "main_deck")
    t:put(N[11], 0, "main_deck")
    if c == "full" then
      t:put(WHITE, 0, "signi_center")
      t:put(WHITE, 0, "signi_right")
    end
    ena(t, 2)
    main(t)
    play(t, h)
    pick(t, HINT_USE_TRIGGER, 1)
    pay(t, 2)
    t:expect(t:wait(HINT_SELECT))
    t:expect(#t:request().options == 1 and t:answer(d))
    if c == "ok" then zone(t) end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(d, 0, "main_deck") == (c ~= "ok"), c)
  end
end)

case("イザベラ·ギルダ 등: LB", "WDK11-011, WDK11-013, WDK11-014", function(t)
  for _, c in ipairs{{11, 0, 0}, {13, 0, 1}, {14, 1, 0}} do  -- {카드, 패, 에나 차지}
    wd(t)
    t:put(N[c[1]], 0, "life_cloth")
    local x, y = t:put(BIG, 1, "signi_left"), t:put(BIG, 1, "signi_center")
    t:begin(1, PHASE_ATTACK)
    pick(t, HINT_ATTACK_SIGNI, x)
    pick(t, HINT_LIFEBURST, 1)
    if c[1] == 11 then pick(t, HINT_TARGET, y) end
    t:wait(c[1] == 11 and HINT_ATTACK_LRIG or HINT_ATTACK_SIGNI)
    t:expect(t:count(0, "hand") == c[2] and t:count(0, "ena") == 1 + c[3] and t:is_in(y, 1, c[1] == 11 and "hand" or "signi_center"))
  end
end)

case("クローネ: 《イザベラ》가 있으면 강제로 패에", "WDK11-012 FAQ 1", function(t)
  for _, on in ipairs{true, false} do
    wd(t)
    local h, x = t:put(N[12], 0, "hand"), t:put(BIG, 1, "signi_left")
    if on then t:put(N[11], 0, "signi_center") end
    main(t)
    play(t, h)
    t:expect(t:wait(HINT_TARGET))
    t:expect(t:request().min == 1 and t:answer(x))
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(x, 1, on and "hand" or "signi_left"))
  end
end)

case("アンナ: 어택하면 에나 차지. 덱이 1장이면 리프레시", "WDK11-013 FAQ 1", function(t)
  for _, n in ipairs{15, 1} do
    wd(t)
    local h = t:put(N[13], 0, "signi_left")
    for i, c in ipairs(t:cards(0, "main_deck")) do if i > n then t:move(c, 0, "trash") end end
    t:begin(0, PHASE_ATTACK)
    pick(t, HINT_ATTACK_SIGNI, h)
    t:wait(HINT_ATTACK_LRIG)
    t:expect(t:count(0, "ena") == 1 and t:refreshes(0) == (n == 1 and 1 or 0))
  end
end)

case("ギルダ·ナイラ: 1장만 버린다. 레벨 3 이하를 패로·백 스펠을 찾는다", "WDK11-014 FAQ 1·2, WDK11-017 FAQ 1", function(t)
  wd(t)
  local h, d = t:put(N[14], 0, "hand"), t:put(WHITE, 0, "hand")
  t:put(WHITE, 0, "hand")
  t:put(BIG, 1, "signi_left")
  local x = t:put(MID, 1, "signi_center")
  main(t)
  play(t, h)
  pick(t, HINT_USE_TRIGGER, 1)
  t:expect(t:wait(HINT_DISCARD))
  t:expect(t:request().max == 1 and t:answer(d))
  t:expect(t:wait(HINT_TARGET))
  t:expect(#t:request().options == 1 and t:answer(x))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(x, 1, "hand") and t:count(0, "hand") == 1)
  wd(t)
  h, d = t:put(N[17], 0, "hand"), t:put(EI, 0, "hand")
  t:put(WHITE, 0, "hand")
  local s = t:put(BURST, 0, "main_deck")
  main(t)
  play(t, h)
  pick(t, HINT_USE_TRIGGER, 1)
  t:expect(t:wait(HINT_DISCARD))
  t:expect(#t:request().options == 1 and t:answer(d))
  t:expect(t:wait(HINT_SELECT))
  t:expect(#t:request().options == 1 and t:answer(s))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(s, 0, "hand"))
end)

case("モーニング・コール: ＜英知＞를 놓고 찾는다. 덱에 없어도 놓은 시그니는 그대로", "WDK11-022 FAQ 1", function(t)
  for _, c in ipairs{"ok", "none", "field"} do
    wd(t)
    local sp, h = t:put(N[22], 0, "hand"), t:put(c == "field" and WHITE or EI, 0, "signi_left")
    local d = c ~= "none" and t:put(EI, 0, "main_deck")
    main(t)
    use(t, sp)
    pick(t, HINT_MODE, 0)
    if c ~= "field" then pick(t, HINT_TARGET, h) end
    if c == "ok" then pick(t, HINT_SELECT, d) end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(h, 0, c == "field" and "signi_left" or "trash") and t:count(0, "hand") == (c == "ok" and 1 or 0), c)
  end
end)
