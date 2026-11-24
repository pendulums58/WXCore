-- WDK03 緑子 구축덱 카드 스크립트 케이스. 근거는 카드별 FAQ(cards.json)

local N = {}
local KA, GREEN, OPP, BIG = 200000, 203000, 101000, 102000

local function wd(t, center)
  t:start{db = true, seed = 1}
  for i = 1, 20 do N[i] = t:no(("WDK03-%03d"):format(i)) end
  t:card{cid = KA, power = 4000, level = 2, classes = {"精生：怪異"}, color = COLOR_GREEN}
  t:signi(GREEN, 1000, COLOR_GREEN, 1)
  t:signi(OPP, 3000, COLOR_RED, 1)
  t:signi(BIG, 15000, COLOR_RED, 4)
  t:fill(GREEN, 0, "main_deck", 15)
  t:fill(OPP, 1, "main_deck", 15)
  t:fill(GREEN, 0, "life_cloth", 5)
  t:fill(OPP, 1, "life_cloth", 5)
  t:put(N[1], 1, "lrig_center")
  return t:put(N[center or 1], 0, "lrig_center")
end

local function main(t, p)
  t:begin(p or 0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
end

local function ena(t, n)
  for _ = 1, n do t:put(GREEN, 0, "ena") end
end

local function pay(t, n)
  t:expect(t:wait(HINT_PAY_ENA), "에나 " .. n)
  t:expect(t:request().min == n, "코스트 " .. n .. " / " .. t:request().min)
  t:expect(t:answer(table.unpack(t:cards(0, "ena"), 1, n)))
end

local function pick(t, hint, ...)
  t:expect(t:wait(hint), "힌트 " .. hint)
  t:expect(t:answer(...))
end

local function use(t, c) t:expect(t:answer(t:action(ACT_USE, c))) end
local function play(t, c, z) t:expect(t:answer(t:action(ACT_PLAY, c, z or "signi_left"))) end

-- ── 루리그·키 ──

case("翠子 레벨 1~3", "WDK03-002~004 FAQ", function(t)
  for _, c in ipairs{{2, 3, 2, 1, 0, 0, 1, 0}, {3, 4, 1, 0, 1, 0, 0, 1}, {4, 5, 0, 0, 0, 1, 1, 0}} do
    wd(t, c[2])
    local g = t:put(N[c[1]], 0, "lrig_deck")
    t:add_coin(0, c[5])
    ena(t, c[3] + c[4])
    local h = c[6] > 0 and t:put(GREEN, 0, "hand")
    t:begin(0, PHASE_GROW)
    pick(t, HINT_GROW, g)
    if c[3] > 0 then pay(t, c[3]) end
    pick(t, HINT_USE_TRIGGER, 1)
    if c[4] > 0 then pay(t, c[4]) end
    if h then pick(t, HINT_DISCARD, h) end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:coins(0) == c[7] and t:count(0, "hand") == c[8], c[1])
  end
end)

case("四型絆娘 翠子: 코인 1개로 《異体同心 華代》를 장에. 【出】은 2체까지. 있던 키는 루리그 트래시로", "WDK03-001, WDK03-006 FAQ 2", function(t)
  for _, n in ipairs{2, 1} do
    local lc = wd(t)
    local k, old = t:put(N[6], 0, "lrig_deck"), t:put(N[6], 0, "key")
    local x = t:put(BIG, 1, "signi_left")
    local y = n == 2 and t:put(OPP, 1, "signi_center")
    t:add_coin(0, 1)
    main(t)
    t:expect(t:answer(t:action(ACT_ABILITY, lc, 0)))
    pick(t, HINT_SELECT, k)
    if y then pick(t, HINT_TARGET, x, y) else pick(t, HINT_TARGET, x) end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(k, 0, "key") and t:is_in(old, 0, "lrig_trash") and t:coins(0) == 0)
    t:expect(t:is_in(x, 1, "ena") and (not y or t:is_in(y, 1, "ena")))
  end
end)

case("四型絆娘 翠子: 【エナチャージ２】는 턴 1회", "WDK03-001", function(t)
  local lc = wd(t)
  t:add_coin(0, 2)
  main(t)
  t:expect(t:answer(t:action(ACT_ABILITY, lc, 1)))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "ena") == 2 and t:coins(0) == 1 and t:action(ACT_ABILITY, lc, 1) == nil)
end)

case("異体同心 華代: 센터가 緑子가 아니면 1체. 어택 페이즈에 엑시드 2로 바니시", "WDK03-006", function(t)
  local lc = wd(t)
  t:lrig(300000, 4, 11, {"花代"}, COLOR_RED)
  t:move(lc, 0, "exclude")
  lc = t:put(300000, 0, "lrig_center")
  local k, x, y = t:put(N[6], 0, "lrig_deck"), t:put(BIG, 1, "signi_left"), t:put(OPP, 1, "signi_center")
  for _ = 1, 2 do t:put_under(t:put(N[2], 0, "lrig_deck"), lc) end
  t:add_coin(0, 2)
  main(t)
  t:expect(t:answer(t:action(ACT_KEY, k)))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:request().min == 1 and t:request().max == 1)
  t:expect(t:answer(x))
  t:expect(t:wait(HINT_PRE_ATTACK))
  t:expect(t:answer(t:action(ACT_ABILITY, lc)))
  if t:wait(HINT_EXCEED) then t:expect(t:answer(table.unpack(t:under(lc)))) end
  pick(t, HINT_TARGET, y)
  t:wait(HINT_ATTACK_LRIG)
  t:expect(t:is_in(x, 1, "ena") and t:is_in(y, 1, "ena") and #t:under(lc) == 0)
end)

-- ── 아츠 ──

case("大願成就: 상대 장의 시그니만 모두 트래시", "WDK03-007 FAQ 1·2", function(t)
  wd(t)
  local a, x, y, h = t:put(N[7], 0, "lrig_deck"), t:put(BIG, 1, "signi_left"), t:put(OPP, 1, "signi_center"), t:put(OPP, 1, "hand")
  ena(t, 4)
  main(t)
  use(t, a)
  pay(t, 4)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(x, 1, "trash") and t:is_in(y, 1, "trash") and t:is_in(h, 1, "hand") and not t:saw(HINT_TARGET))
end)

case("青天白日: 레벨 4만. 베트하면 에나 없이", "WDK03-009", function(t)
  for _, yes in ipairs{0, 1} do
    wd(t)
    local a, x = t:put(N[9], 0, "lrig_deck"), t:put(BIG, 1, "signi_left")
    t:put(OPP, 1, "signi_center")
    t:add_coin(0, 1)
    ena(t, 2)
    main(t)
    use(t, a)
    pick(t, HINT_BET, yes)
    if yes == 0 then pay(t, 2) end
    t:expect(t:wait(HINT_TARGET))
    t:expect(#t:request().options == 1)
    t:expect(t:answer(x))
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(x, 1, "ena") and t:count(0, "ena") == 2 * yes)
  end
end)

-- ── 시그니 ──

case("ピーター: 아츠를 쓰면 ＜怪異＞ 모두 【ランサー】. 아츠를 처리한 뒤에, 나중에 나온 것은 아니다. 턴 1회", "WDK03-011 FAQ 1", function(t)
  wd(t)
  local p, k, g = t:put(N[11], 0, "signi_left"), t:put(KA, 0, "signi_center"), t:put(GREEN, 0, "signi_right")
  local a, x, late = t:put(N[9], 0, "lrig_deck"), t:put(BIG, 1, "signi_left"), t:put(KA, 0, "hand")
  ena(t, 2)
  main(t)
  use(t, a)
  pay(t, 2)
  t:expect(t:wait(HINT_TARGET))
  t:expect(not t:keyword(k, EFFECT_LANCER), "처리 전")
  t:expect(t:answer(x))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:keyword(p, EFFECT_LANCER) and t:keyword(k, EFFECT_LANCER) and not t:keyword(g, EFFECT_LANCER))
  t:move(g, 0, "ena")
  t:move(late, 0, "signi_right")
  t:expect(not t:keyword(late, EFFECT_LANCER))
end)

case("キュウソ: 아츠를 쓰면 【ランサー】. 스펠이나 상대의 아츠는 아니다", "WDK03-017", function(t)
  wd(t)
  local k, sp = t:put(N[17], 0, "signi_left"), t:put(N[20], 0, "hand")
  local a = t:put(N[9], 0, "lrig_deck")
  t:put(BIG, 1, "signi_left")
  ena(t, 2)
  main(t)
  use(t, sp)
  pick(t, HINT_MODE, 1)
  t:expect(t:wait(HINT_MAIN))
  t:expect(not t:keyword(k, EFFECT_LANCER), "스펠")
  use(t, a)
  pay(t, 2)
  pick(t, HINT_TARGET, t:cards(1, "signi_left")[1])
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:keyword(k, EFFECT_LANCER))
  wd(t)
  k = t:put(N[17], 0, "signi_left")
  a = t:put(N[9], 1, "lrig_deck")
  t:add_coin(1, 1)
  main(t, 1)
  use(t, a)
  t:wait(HINT_MAIN)
  t:expect(not t:keyword(k, EFFECT_LANCER), "상대의 아츠")
end)

case("ネコムス: 왼쪽에 나오면 에나 차지. 그 카드를 두 번째 능력의 코스트나 대상으로", "WDK03-012 FAQ 1~4", function(t)
  for _, z in ipairs{"signi_left", "signi_center"} do
    wd(t)
    local h = t:put(N[12], 0, "hand")
    ena(t, 1)
    main(t)
    play(t, h, z)
    if z == "signi_left" then
      pick(t, HINT_TRIGGER_ORDER, 0)
      t:expect(t:wait(HINT_USE_TRIGGER))
      t:expect(t:count(0, "ena") == 2)
    else
      t:expect(t:wait(HINT_USE_TRIGGER))
      t:expect(t:count(0, "ena") == 1)
    end
    t:expect(t:answer(1))
    local e = t:cards(0, "ena")
    pick(t, HINT_PAY_ENA, e[#e])
    if z == "signi_left" then pick(t, HINT_TARGET, e[1]) end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:count(0, "hand") == (z == "signi_left" and 1 or 0))
  end
end)

case("ヌリカベ·イッタンモメン: 루리그 트래시의 아츠 2장·1장", "WDK03-013, WDK03-015", function(t)
  wd(t)
  local a, b = t:put(N[13], 0, "signi_left"), t:put(N[15], 0, "signi_center")
  t:put(N[2], 0, "lrig_trash")
  t:expect(t:power(a) == 8000 and t:power(b) == 5000, "루리그는 세지 않는다")
  t:put(N[7], 0, "lrig_trash")
  t:expect(t:power(a) == 8000 and t:power(b) == 10000)
  t:put(N[9], 0, "lrig_trash")
  t:expect(t:power(a) == 15000)
end)

case("ティンベル: 적힌 코스트 3 이상인 아츠만 《緑》 1 줄어든다. 2체면 2", "WDK03-014 FAQ 1", function(t)
  for n = 1, 2 do
    wd(t)
    for i = 1, n do t:put(N[14], 0, ({"signi_left", "signi_center"})[i]) end
    local a, b = t:put(N[7], 0, "lrig_deck"), t:put(N[9], 0, "lrig_deck")
    ena(t, 6)
    main(t)
    use(t, a)
    pay(t, 4 - n)
    t:expect(t:wait(HINT_MAIN))
    use(t, b)
    pay(t, 2)
    t:expect(t:wait(HINT_MAIN))
  end
end)

case("ティンベル: 베트해서 코스트가 바뀌어도 적힌 코스트로 본다", "WDK03-014 FAQ 1, WDK03-008", function(t)
  wd(t)
  t:put(N[14], 0, "signi_left")
  local a = t:put(N[8], 0, "lrig_deck")
  t:add_coin(0, 2)
  ena(t, 4)
  main(t)
  use(t, a)
  pick(t, HINT_BET, 0)
  pay(t, 3)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "life_cloth") == 6)
end)

case("連鎖: ＜怪異＞가 없으면 바니시하지 않는다", "WDK03-020 FAQ 2", function(t)
  for _, c in ipairs{{KA, "ena"}, {GREEN, "signi_left"}} do
    wd(t)
    local sp, h, x = t:put(N[20], 0, "hand"), t:put(c[1], 0, "signi_left"), t:put(BIG, 1, "signi_left")
    t:put(OPP, 1, "signi_center")
    main(t)
    use(t, sp)
    pick(t, HINT_MODE, 0)
    if c[1] == KA then pick(t, HINT_TARGET, h) end
    t:expect(t:wait(HINT_TARGET))
    t:expect(#t:request().options == 1, "8000 이상")
    t:expect(t:answer(x))
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(x, 1, c[2]))
  end
end)
