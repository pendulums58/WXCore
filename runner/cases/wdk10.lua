-- WDK10 ウリス 구축덱 카드 스크립트 케이스. 근거는 카드별 FAQ(cards.json)

local N = {}
local RY, RY4, BLK, OPP, MID, BIG, SPELL = 200000, 200004, 203000, 101000, 101500, 102000, 204000

local function wd(t, center)
  t:start{db = true, seed = 1}
  for i = 1, 22 do N[i] = t:no(("WDK10-%03d"):format(i)) end
  t:card{cid = RY, power = 4000, level = 2, classes = {"精生：龍獣"}, color = COLOR_BLACK}
  t:card{cid = RY4, power = 12000, level = 4, classes = {"精生：龍獣"}, color = COLOR_BLACK}
  t:signi(BLK, 1000, COLOR_BLACK, 1)
  t:signi(OPP, 3000, COLOR_RED, 1)
  t:signi(MID, 6000, COLOR_RED, 3)
  t:signi(BIG, 15000, COLOR_RED, 4)
  t:card{cid = SPELL, type = TYPE_SPELL, color = COLOR_BLACK}
  t:fill(BLK, 0, "main_deck", 15)
  t:fill(OPP, 1, "main_deck", 15)
  t:fill(BLK, 0, "life_cloth", 5)
  t:fill(OPP, 1, "life_cloth", 5)
  t:put(N[1], 1, "lrig_center")
  return t:put(N[center or 1], 0, "lrig_center")
end

local function main(t, p)
  t:begin(p or 0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
end

local function ena(t, n)
  for _ = 1, n do t:put(BLK, 0, "ena") end
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
local function trash(t, cid, n, p) for _ = 1, n do t:put(cid, p or 0, "trash") end end

local function deck(t, p, ...)
  for _, c in ipairs(t:cards(p, "main_deck")) do t:move(c, p, "exclude") end
  local out = {}
  for i, cid in ipairs{...} do out[i] = t:put(cid, p, "main_deck") end
  return out
end

-- ── 루리그 ──

case("爆掃の閻魔: 【出】 ＜龍獣＞ 2장까지", "WDK10-001 FAQ 1", function(t)
  for n = 0, 2 do
    wd(t, 2)
    local g, l = t:put(N[1], 0, "lrig_deck"), {t:put(RY, 0, "trash"), t:put(RY, 0, "trash")}
    t:put(BLK, 0, "trash")
    t:begin(0, PHASE_GROW)
    pick(t, HINT_GROW, g)
    t:expect(t:wait(HINT_TARGET))
    t:expect(#t:request().options == 2 and t:answer(table.unpack(l, 1, n)))
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:count(0, "hand") == n and t:coins(0) == 2)
  end
end)

case("爆掃の閻魔: 내 트래시 1장을 제외, 상대가 에나를 골라 패를 버리거나 트래시에", "WDK10-001 FAQ 2", function(t)
  for _, yes in ipairs{true, false} do
    local lc = wd(t)
    local x = t:put(BLK, 0, "trash")
    trash(t, OPP, 1, 1)
    local e, h = t:put(OPP, 1, "ena"), t:put(OPP, 1, "hand")
    main(t)
    t:expect(t:answer(t:action(ACT_ABILITY, lc)))
    t:step()
    if t:request().hint == HINT_SELECT then
      t:expect(#t:request().options == 1)
      t:expect(t:answer(x))
    end
    t:expect(t:wait(HINT_TARGET))
    t:expect(t:request().player == 1 and t:answer(e))
    t:expect(t:wait(HINT_DISCARD))
    t:expect(t:request().player == 1)
    if yes then t:expect(t:answer(h)) else t:expect(t:answer()) end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(x, 0, "exclude") and t:is_in(e, 1, yes and "ena" or "trash") and t:is_in(h, 1, yes and "trash" or "hand"))
    t:expect(t:action(ACT_ABILITY, lc, 0) == nil)
  end
end)

case("ディスペア: 라이프 클로스가 0장이면 ＜龍獣＞를 라이프 클로스에. 게임 1회", "WDK10-001 FAQ 3", function(t)
  for _, n in ipairs{0, 1} do
    local lc = wd(t)
    local x = t:put(RY, 0, "trash")
    for i, c in ipairs(t:cards(0, "life_cloth")) do if i > n then t:move(c, 0, "exclude") end end
    t:add_coin(0, 2)
    main(t)
    t:expect(t:answer(t:action(ACT_ABILITY, lc, 1)))
    pick(t, HINT_TARGET, x)
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:count(0, "life_cloth") == 1 and t:is_in(x, 0, n == 0 and "life_cloth" or "trash") and t:coins(0) == 1)
    t:expect(t:action(ACT_ABILITY, lc, 1) == nil)
  end
end)

case("ウリス 레벨 1·2", "WDK10-003, WDK10-004", function(t)
  wd(t, 4)
  local g = t:put(N[3], 0, "lrig_deck")
  t:add_coin(0, 1)
  ena(t, 1)
  t:begin(0, PHASE_GROW)
  pick(t, HINT_GROW, g)
  pay(t, 1)
  pick(t, HINT_USE_TRIGGER, 1)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:coins(0) == 0 and t:count(0, "hand") == 1)
  wd(t, 5)
  g = t:put(N[4], 0, "lrig_deck")
  local h = t:put(BLK, 0, "hand")
  t:begin(0, PHASE_GROW)
  pick(t, HINT_GROW, g)
  pick(t, HINT_USE_TRIGGER, 1)
  pick(t, HINT_DISCARD, h)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:coins(0) == 1 and t:is_in(h, 0, "trash"))
end)

-- ── 아츠 ──

case("ブラッディ・ストライク: 2체여야 한다", "WDK10-006", function(t)
  for n = 1, 2 do
    wd(t)
    local a, x = t:put(N[6], 0, "lrig_deck"), t:put(BIG, 1, "signi_left")
    local y = n == 2 and t:put(OPP, 1, "signi_center")
    ena(t, 6)
    t:begin(0, PHASE_ATTACK)
    t:expect(t:wait(HINT_PRE_ATTACK))
    use(t, a)
    pay(t, 6)
    if y then pick(t, HINT_TARGET, x, y) end
    t:wait(HINT_ATTACK_LRIG)
    t:expect(t:is_in(x, 1, n == 2 and "ena" or "signi_left"))
  end
end)

case("サーベイジ・イリュージョン: 키가 없어도 둘 다 고른다. 상대 키가 있으면 장에(【出】 없이)", "WDK10-007 FAQ 1·3", function(t)
  for _, c in ipairs{{true, true}, {true, false}, {false, true}} do  -- {상대 키, 상대 시그니}
    wd(t)
    local a, x = t:put(N[7], 0, "lrig_deck"), t:put(N[17], 0, "trash")
    local y = c[2] and t:put(BIG, 1, "signi_left")
    if c[1] then t:put(N[9], 1, "key") end
    ena(t, 2)
    t:begin(0, PHASE_ATTACK)
    t:expect(t:wait(HINT_PRE_ATTACK))
    use(t, a)
    pay(t, 2)
    if y then pick(t, HINT_TARGET, y) end
    pick(t, HINT_TARGET, x)
    if c[1] then zone(t) end
    t:wait(HINT_ATTACK_LRIG)
    t:expect(t:is_in(x, 0, "trash") == not c[1] and (not y or t:power(y) == 7000) and t:count(0, "main_deck") == 15)
  end
end)

case("ヴェイパー・コントロール: 3장이 공통된 색이면 흑 시그니를 2장(ベット 4장)까지. 무색·섞인 색은 0장", "WDK10-008 FAQ 1~3", function(t)
  for _, c in ipairs{{{OPP, OPP, OPP}, 0, 2}, {{OPP, OPP, OPP}, 1, 4}, {{OPP, OPP, BLK}, 1, nil}, {{73, 73, 73}, 0, nil}} do
    wd(t)
    local a, l = t:put(N[8], 0, "lrig_deck"), {}
    for i, cid in ipairs(c[1]) do l[i] = t:put(cid, 1, "trash") end
    local m = {}
    for i = 1, 5 do m[i] = t:put(BLK, 0, "trash") end
    t:add_coin(0, 2)
    ena(t, 1)
    main(t)
    use(t, a)
    pick(t, HINT_BET, c[2])
    pay(t, 1)
    pick(t, HINT_TARGET, l[1], l[2], l[3])
    if c[3] then
      t:expect(t:wait(HINT_TARGET))
      t:expect(t:request().max == c[3] and t:request().min == 0)
      t:expect(t:answer(table.unpack(m, 1, c[3])))
    end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:count(0, "hand") == (c[3] or 0) and t:is_in(l[3], 1, "exclude"))
  end
  wd(t)
  local a = t:put(N[8], 0, "lrig_deck")
  trash(t, OPP, 2, 1)
  ena(t, 1)
  main(t)
  t:expect(t:action(ACT_USE, a) == nil)
end)

-- ── 魅惑の冥者　ハナレ ──

case("ハナレ: 【出】 3장을 놓고 트래시 전체에서 흑 시그니. ＜ウリス＞면 1장 더", "WDK10-009 FAQ 1", function(t)
  for _, urith in ipairs{true, false} do
    local lc = wd(t)
    if not urith then
      t:lrig(300000, 4, 11, {"花代"}, COLOR_BLACK)
      t:move(lc, 0, "exclude")
      t:put(300000, 0, "lrig_center")
    end
    local k, x = t:put(N[9], 0, "lrig_deck"), t:put(RY, 0, "trash")
    t:add_coin(0, 1)
    main(t)
    t:expect(t:answer(t:action(ACT_KEY, k)))
    t:expect(t:wait(HINT_TARGET))
    t:expect(#t:request().options == 4 and t:answer(x))
    if urith then
      t:expect(t:wait(HINT_TARGET))
      t:expect(#t:request().options == 3 and t:answer(t:request().options[1]))
    end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:count(0, "hand") == (urith and 2 or 1))
  end
end)

case("ハナレ: 지정한 존의 시그니는 다음 내 턴이 시작할 때까지 레벨마다 −2000. 나중에 나온 것도, 키가 떠나도", "WDK10-009 FAQ 2~4", function(t)
  wd(t)
  local k, h = t:put(N[9], 0, "key"), t:put(BLK, 0, "hand")
  main(t)
  t:expect(t:answer(t:action(ACT_ABILITY, k)))
  pick(t, HINT_DISCARD, h)
  t:expect(t:wait(HINT_ZONE))
  t:expect(#t:request().options == 3 and t:answer(t:request().options[1]))
  t:expect(t:wait(HINT_MAIN))
  t:move(k, 0, "lrig_trash")
  local x, y = t:put(BIG, 1, "signi_left"), t:put(BIG, 1, "signi_center")
  t:expect(t:power(x) == 7000 and t:power(y) == 15000)
  t:expect(t:wait(HINT_ENA_CHARGE))
  t:expect(t:request().player == 1 and t:power(x) == 7000, "상대 턴")
  t:expect(t:answer())
  t:expect(t:wait(HINT_ENA_CHARGE))
  t:expect(t:request().player == 0 and t:power(x) == 15000, "다음 내 턴")
end)

-- ── 시그니 ──

case("アン＝ミラ: 【出】로 버린 것에도 −6000. 버린 레벨 3 이하를 낼 수 있다. 턴 2회", "WDK10-011 FAQ 2·3", function(t)
  for _, c in ipairs{{RY, true}, {RY4, false}} do
    wd(t)
    local h, d, x = t:put(N[11], 0, "hand"), t:put(c[1], 0, "hand"), t:put(BIG, 1, "signi_left")
    main(t)
    play(t, h)
    pick(t, HINT_USE_TRIGGER, 1)
    pick(t, HINT_DISCARD, d)
    if c[2] then
      t:expect(t:wait(HINT_TARGET))
      t:expect(t:answer(d))
      zone(t)
    end
    pick(t, HINT_TARGET, x)
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:power(x) == 9000 and t:is_in(d, 0, "trash") == not c[2])
  end
end)

case("アン＝ミラ: 엔드 페이즈에 버려도 발동(2회까지). 가드로 버린 것은 아니다", "WDK10-011 FAQ 1", function(t)
  wd(t)
  t:put(N[11], 0, "signi_left")
  t:put(BIG, 1, "signi_left")
  for _ = 1, 9 do t:put(BLK, 0, "hand") end
  main(t)
  local n = 0
  for _ = 1, 40 do
    t:step()
    local q = t:request()
    if not q or (q.hint == HINT_ENA_CHARGE and q.player == 1) then break end
    if q.hint == HINT_TARGET then n = n + 1 end
    if q.hint == HINT_MAIN then t:answer(t:action(ACT_END)) else t:answer(table.unpack(q.options, 1, q.min)) end
  end
  t:expect(n == 2, "발동 " .. n)
  wd(t)
  t:put(N[11], 0, "signi_left")
  local x = t:put(BIG, 1, "signi_left")
  local g, lc = t:put(N[18], 0, "hand"), t:cards(1, "lrig_center")[1]
  t:begin(1, PHASE_ATTACK)
  pick(t, HINT_ATTACK_LRIG, lc)
  pick(t, HINT_GUARD, g)
  t:wait(HINT_MAIN)
  t:expect(t:is_in(g, 0, "trash") and not t:saw(HINT_TARGET) and t:power(x) == 15000)
end)

case("ペイモン: 덱이 모자라도 ＜龍獣＞를 되찾고 리프레시", "WDK10-012 FAQ 1", function(t)
  for _, n in ipairs{15, 3} do
    wd(t)
    local h, x = t:put(N[12], 0, "hand"), t:put(RY, 0, "trash")
    for i, c in ipairs(t:cards(0, "main_deck")) do if i > n then t:move(c, 0, "exclude") end end
    ena(t, 1)
    main(t)
    play(t, h)
    pick(t, HINT_USE_TRIGGER, 1)
    pay(t, 1)
    t:expect(t:wait(HINT_TARGET))
    t:expect(t:refreshes(0) == 0 and t:answer(x))
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(x, 0, "hand") and t:refreshes(0) == (n == 3 and 1 or 0))
  end
end)

case("キュリア: ＜龍獣＞ 5장이면 ＋4000, 10장이면 어택할 때 상대 덱 4장", "WDK10-013 FAQ 1", function(t)
  for _, n in ipairs{4, 9, 10} do
    wd(t)
    local h = t:put(N[13], 0, "signi_left")
    trash(t, RY, n)
    trash(t, BLK, 5)
    t:expect(t:power(h) == (n >= 5 and 12000 or 8000))
    t:begin(0, PHASE_ATTACK)
    pick(t, HINT_ATTACK_SIGNI, h)
    t:wait(HINT_ATTACK_LRIG)
    t:expect(t:count(1, "main_deck") == (n == 10 and 11 or 15))
  end
end)

case("ベルゼブブ: ＜龍獣＞를 버리면 −8000. 정면을 바니시하면 대미지. 안 버려도 된다", "WDK10-014 FAQ 1", function(t)
  for _, yes in ipairs{true, false} do
    wd(t)
    local h, d = t:put(N[14], 0, "signi_center"), t:put(RY, 0, "hand")
    t:put(BLK, 0, "hand")
    t:signi(300000, 8000, COLOR_RED, 1)
    local x = t:put(300000, 1, "signi_center")
    t:begin(0, PHASE_ATTACK)
    pick(t, HINT_ATTACK_SIGNI, h)
    pick(t, HINT_TARGET, x)
    t:expect(t:wait(HINT_DISCARD))
    t:expect(#t:request().options == 1)
    if yes then t:expect(t:answer(d)) else t:expect(t:answer()) end
    t:wait(HINT_ATTACK_LRIG)
    t:expect(t:is_in(x, 1, yes and "ena" or "signi_center") and t:count(1, "life_cloth") == (yes and 4 or 5))
  end
end)

case("コスド: 버린 시그니 파워의 절반 이하를 바니시", "WDK10-015 FAQ 1", function(t)
  for _, c in ipairs{{RY4, true}, {RY, false}} do
    wd(t)
    local h, d = t:put(N[15], 0, "signi_center"), t:put(c[1], 0, "hand")
    local x = t:put(MID, 1, "signi_center")
    t:put(BIG, 1, "signi_left")
    t:begin(0, PHASE_ATTACK)
    pick(t, HINT_ATTACK_SIGNI, h)
    pick(t, HINT_DISCARD, d)
    if c[2] then
      t:expect(t:wait(HINT_TARGET))
      t:expect(#t:request().options == 1 and t:answer(x))
    end
    t:wait(HINT_ATTACK_LRIG)
    t:expect(t:is_in(x, 1, c[2] and "ena" or "signi_center") and t:count(1, "life_cloth") == (c[2] and 4 or 5))
  end
end)

case("スクブス: ＜龍獣＞ 3장이 놓이면 서로 1장 버린다. 2장뿐이면 아니다", "WDK10-017 FAQ 1", function(t)
  for _, c in ipairs{{{BLK, RY, RY, RY}, true}, {{BLK, RY, BLK, RY}, false}, {{RY, RY}, false}} do
    wd(t)
    local h, a, b = t:put(N[17], 0, "hand"), t:put(BLK, 0, "hand"), t:put(OPP, 1, "hand")
    deck(t, 0, table.unpack(c[1]))
    main(t)
    play(t, h)
    if c[2] then
      for _ = 1, 2 do
        t:step()
        if t:request().hint == HINT_DISCARD then t:answer(t:request().options[1]) end
      end
    end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(a, 0, c[2] and "trash" or "hand") and t:is_in(b, 1, c[2] and "trash" or "hand"))
    t:expect(t:refreshes(0) == (#c[1] == 2 and 1 or 0))
  end
end)

case("テクニカル・ボア: 방금 놓은 시그니는 되찾을 수 없다. ＜龍獣＞가 없으면 되찾지 않는다", "WDK10-022 FAQ 1·2", function(t)
  for _, on in ipairs{true, false} do
    wd(t)
    local sp, h, x = t:put(N[22], 0, "hand"), t:put(on and RY or BLK, 0, "signi_left"), t:put(RY4, 0, "trash")
    main(t)
    use(t, sp)
    pick(t, HINT_MODE, 0)
    if on then pick(t, HINT_TARGET, h) end
    t:expect(t:wait(HINT_TARGET))
    t:expect(#t:request().options == 1 and t:answer(x))
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(x, 0, on and "hand" or "trash"))
  end
end)
