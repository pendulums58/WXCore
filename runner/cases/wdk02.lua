-- WDK02 ピルルク 구축덱 카드 스크립트 케이스. 근거는 카드별 FAQ(cards.json)

local N = {}
local AK, BLUE, OPP, BIG = 200000, 203000, 101000, 102000

local function wd(t, center)
  t:start{db = true, seed = 1}
  for i = 1, 20 do N[i] = t:no(("WDK02-%03d"):format(i)) end
  t:card{cid = AK, power = 4000, level = 2, classes = {"精像：悪魔"}, color = COLOR_BLUE}
  t:signi(BLUE, 1000, COLOR_BLUE, 1)
  t:signi(OPP, 3000, COLOR_GREEN, 1)
  t:signi(BIG, 15000, COLOR_GREEN, 4)
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
local function play(t, c) t:expect(t:answer(t:action(ACT_PLAY, c, "signi_left"))) end

-- 상대의 패를 뒷면으로 n장 고른다
local function blind(t, n)
  t:expect(t:wait(HINT_SELECT))
  t:expect(t:request().player == 0 and t:request().min == n)
  t:expect(t:answer(table.unpack(t:cards(1, "hand"), 1, n)))
end

-- ── 루리그 ──

case("TET: 【出】 상대 패를 뒷면으로 1장, 코인 3개. 패가 없으면 아무 일도 없다", "WDK02-001 FAQ 1", function(t)
  for _, n in ipairs{2, 0} do
    wd(t, 2)
    local g = t:put(N[1], 0, "lrig_deck")
    t:fill(OPP, 1, "hand", n)
    t:begin(0, PHASE_GROW)
    pick(t, HINT_GROW, g)
    if n > 0 then blind(t, 1) end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:count(1, "hand") == math.max(0, n - 1) and t:coins(0) == 3)
  end
end)

case("TET: 어택하면 《青》을 내고 뽑는다. 내지 않아도 된다", "WDK02-001 FAQ 2", function(t)
  for _, yes in ipairs{1, 0} do
    local lc = wd(t)
    ena(t, 1)
    t:begin(0, PHASE_ATTACK)
    pick(t, HINT_ATTACK_LRIG, lc)
    pick(t, HINT_SCRIPT, yes)
    if yes == 1 then pay(t, 1) end
    t:wait(HINT_MAIN)
    t:expect(t:count(0, "hand") == yes and t:count(0, "ena") == 1 - yes)
  end
end)

case("ピルルク 레벨 1~3", "WDK02-002~004 FAQ", function(t)
  -- {카드, 지금, 그로우, 【出】 에나, 시작 코인, 버리기, 끝 코인, 끝 패}
  for _, c in ipairs{{2, 3, 2, 1, 0, 0, 1, 0}, {3, 4, 1, 0, 1, 0, 0, 1}, {4, 5, 0, 0, 0, 1, 1, 0}} do
    for _, yes in ipairs{1, 0} do
      wd(t, c[2])
      local g = t:put(N[c[1]], 0, "lrig_deck")
      t:add_coin(0, c[5])
      ena(t, c[3] + c[4])
      local h = c[6] > 0 and t:put(BLUE, 0, "hand")
      t:begin(0, PHASE_GROW)
      pick(t, HINT_GROW, g)
      if c[3] > 0 then pay(t, c[3]) end
      pick(t, HINT_USE_TRIGGER, yes)
      if yes == 1 and c[4] > 0 then pay(t, c[4]) end
      if yes == 1 and h then pick(t, HINT_DISCARD, h) end
      t:expect(t:wait(HINT_MAIN))
      t:expect(t:coins(0) == (yes == 1 and c[7] or c[5]) and t:count(0, "hand") == (yes == 1 and c[8] or c[6]), c[1])
    end
  end
end)

-- ── 아츠·키 ──

case("スリー・ダスト: 레벨 3 이상일 때만. 3장, 모자라면 모두", "WDK02-007", function(t)
  for _, n in ipairs{4, 2} do
    wd(t)
    local a = t:put(N[7], 0, "lrig_deck")
    t:fill(OPP, 1, "hand", n)
    ena(t, 2)
    main(t)
    use(t, a)
    pay(t, 2)
    blind(t, math.min(3, n))
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:count(1, "hand") == math.max(0, n - 3))
  end
  wd(t, 3)
  local a = t:put(N[7], 0, "lrig_deck")
  ena(t, 2)
  main(t)
  t:expect(t:action(ACT_USE, a) == nil)
end)

case("ドント・リブミー: 1체, 베트하면 2체를 다운", "WDK02-008 FAQ 1", function(t)
  for _, yes in ipairs{0, 1} do
    wd(t)
    local a, x, y = t:put(N[8], 0, "lrig_deck"), t:put(OPP, 1, "signi_left"), t:put(OPP, 1, "signi_center")
    t:add_coin(0, 2)
    ena(t, 1)
    t:begin(1, PHASE_ATTACK)
    t:expect(t:wait(HINT_DEFENSE))
    use(t, a)
    pick(t, HINT_BET, yes)
    pay(t, 1)
    if yes == 1 then pick(t, HINT_TARGET, x, y) else pick(t, HINT_TARGET, x) end
    t:wait(HINT_ATTACK_LRIG)
    t:expect(t:flags(x) & CF_DOWN ~= 0 and (t:flags(y) & CF_DOWN ~= 0) == (yes == 1))
  end
end)

case("コード・ピルルク KEY: 레벨 2 이상의 센터가 얻는다. 엑시드 1로 뽑고 상대는 버린다(패가 없어도). 턴 1회", "WDK02-009 FAQ 3", function(t)
  for _, n in ipairs{1, 0} do
    local lc = wd(t)
    t:put(N[9], 0, "key")
    for _ = 1, 2 do t:put_under(t:put(N[4], 0, "lrig_deck"), lc) end
    t:fill(OPP, 1, "hand", n)
    main(t)
    t:expect(t:answer(t:action(ACT_ABILITY, lc)))
    if t:wait(HINT_EXCEED) then t:expect(t:answer(t:under(lc)[1])) end
    if n == 1 then pick(t, HINT_DISCARD, t:cards(1, "hand")[1]) end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:count(0, "hand") == 1 and t:count(1, "hand") == 0 and #t:under(lc) == 1)
    t:expect(t:action(ACT_ABILITY, lc) == nil, "턴 1회")
  end
  local lc = wd(t, 4)
  t:put(N[9], 0, "key")
  t:put_under(t:put(N[5], 0, "lrig_deck"), lc)
  main(t)
  t:expect(t:action(ACT_ABILITY, lc) == nil, "레벨 1")
end)

case("コード・ピルルク KEY: 어택 페이즈에 엑시드 2로 다운·동결. 그로우해도 키가 남는다", "WDK02-009 FAQ 2", function(t)
  wd(t, 2)
  local k, g = t:put(N[9], 0, "key"), t:put(N[1], 0, "lrig_deck")
  local lc = t:cards(0, "lrig_center")[1]
  t:put_under(t:put(N[4], 0, "lrig_deck"), lc)
  local x = t:put(BIG, 1, "signi_left")
  t:begin(0, PHASE_GROW)
  pick(t, HINT_GROW, g)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(k, 0, "key"))
  t:expect(t:wait(HINT_PRE_ATTACK))
  t:expect(t:answer(t:action(ACT_ABILITY, g)))
  if t:wait(HINT_EXCEED) then t:expect(t:answer(table.unpack(t:under(g), 1, 2))) end
  pick(t, HINT_TARGET, x)
  t:wait(HINT_ATTACK_LRIG)
  t:expect(t:flags(x) & CF_DOWN ~= 0 and t:flags(x) & CF_FROZEN ~= 0)
end)

-- ── 시그니 ──

case("スクリュー・カーミラ: 어택할 때 내 패가 1장 이하면 상대가 버린다", "WDK02-011 FAQ 1", function(t)
  for _, n in ipairs{1, 2} do
    wd(t)
    local h = t:put(N[11], 0, "signi_left")
    t:fill(BLUE, 0, "hand", n)
    t:fill(OPP, 1, "hand", 2)
    t:begin(0, PHASE_ATTACK)
    pick(t, HINT_ATTACK_SIGNI, h)
    if n == 1 then pick(t, HINT_DISCARD, t:cards(1, "hand")[1]) end
    t:wait(HINT_ATTACK_LRIG)
    t:expect(t:count(1, "hand") == (n == 1 and 1 or 2))
  end
end)

case("スクリュー・カーミラ: LB 상대 패가 2장 이하면 바니시", "WDK02-011", function(t)
  for _, n in ipairs{2, 3} do
    wd(t)
    t:put(N[11], 0, "life_cloth")
    t:fill(OPP, 1, "hand", n)
    local a = t:put(BIG, 1, "signi_left")
    t:begin(1, PHASE_ATTACK)
    pick(t, HINT_ATTACK_SIGNI, a)
    pick(t, HINT_LIFEBURST, 1)
    pick(t, HINT_TARGET, a)
    t:wait(HINT_ATTACK_LRIG)
    t:expect(t:is_in(a, 1, n == 2 and "ena" or "signi_left"))
  end
end)

case("スライムクイーン: 2장 버려 바니시. 1장이면 발동할 수 없다", "WDK02-012 FAQ 1", function(t)
  for _, n in ipairs{2, 1} do
    wd(t)
    local h, x = t:put(N[12], 0, "hand"), t:put(BIG, 1, "signi_left")
    t:fill(BLUE, 0, "hand", n)
    main(t)
    play(t, h)
    if n == 2 then
      pick(t, HINT_USE_TRIGGER, 1)
      pick(t, HINT_DISCARD, table.unpack(t:cards(0, "hand")))
      pick(t, HINT_TARGET, x)
    end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(x, 1, n == 2 and "ena" or "signi_left"))
  end
end)

case("アーマードスライム·シャッコー: 패가 1장 이하인 동안 ＋4000·＋3000", "WDK02-013, WDK02-015", function(t)
  wd(t)
  local a, b = t:put(N[13], 0, "signi_left"), t:put(N[15], 0, "signi_center")
  t:put(BLUE, 0, "hand")
  t:expect(t:power(a) == 12000 and t:power(b) == 8000)
  t:put(BLUE, 0, "hand")
  t:expect(t:power(a) == 8000 and t:power(b) == 5000)
end)

case("シャークスピア: 패 2장 이하 −1000, 0장 −5000. 그 뒤 패가 늘어도 그대로", "WDK02-014 FAQ 1", function(t)
  for n, v in pairs{[0] = 10000, [1] = 14000, [2] = 14000, [3] = 15000} do
    wd(t)
    local h, x = t:put(N[14], 0, "hand"), t:put(BIG, 1, "signi_left")
    t:fill(BLUE, 0, "hand", n)
    main(t)
    play(t, h)
    pick(t, HINT_TARGET, x)
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:power(x) == v, n)
    t:fill(BLUE, 0, "hand", 3)
    t:expect(t:power(x) == v)
  end
end)

case("マノミン: 각자 1장 버린다. 한쪽만 있어도", "WDK02-017 FAQ 1", function(t)
  for _, n in ipairs{1, 0} do
    wd(t)
    local h = t:put(N[17], 0, "hand")
    local a = n == 1 and t:put(BLUE, 0, "hand")
    local b = t:put(OPP, 1, "hand")
    main(t)
    play(t, h)
    if a then pick(t, HINT_DISCARD, a) end
    t:expect(t:wait(HINT_DISCARD))
    t:expect(t:request().player == 1)
    t:expect(t:answer(b))
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:count(0, "hand") == 0 and t:count(1, "hand") == 0)
  end
end)

case("DEVIL SEAL: ＜悪魔＞를 놓아야 상대가 버린다. ②는 에나 차지", "WDK02-020 FAQ 1", function(t)
  for _, c in ipairs{{0, AK, 0}, {0, BLUE, 1}, {1, BLUE, 1}} do  -- {모드, 내 시그니, 상대 패}
    wd(t)
    local sp, h = t:put(N[20], 0, "hand"), t:put(c[2], 0, "signi_left")
    local o = t:put(OPP, 1, "hand")
    main(t)
    use(t, sp)
    pick(t, HINT_MODE, c[1])
    if c[2] == AK then
      pick(t, HINT_TARGET, h)
      pick(t, HINT_DISCARD, o)
    end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:count(1, "hand") == c[3] and t:count(0, "ena") == c[1])
  end
end)
