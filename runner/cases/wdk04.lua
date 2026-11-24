-- WDK04 グズ子 구축덱 카드 스크립트 케이스(WDK-F02도 같은 카드). 근거는 카드별 FAQ(cards.json)

local N = {}
local TR, TR1, BLK, OPP, BIG = 200000, 201000, 203000, 101000, 102000

local function wd(t, center)
  t:start{db = true, seed = 1}
  for i = 1, 20 do N[i] = t:no(("WDK04-%03d"):format(i)) end
  t:card{cid = TR, power = 4000, level = 2, classes = {"精武：トリック"}, color = COLOR_BLACK}
  t:card{cid = TR1, power = 4000, level = 1, classes = {"精武：トリック"}, color = COLOR_BLACK}
  t:signi(BLK, 1000, COLOR_BLACK, 1)
  t:signi(OPP, 3000, COLOR_RED, 1)
  t:signi(BIG, 15000, COLOR_RED, 4)
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

local function use(t, c) t:expect(t:answer(t:action(ACT_USE, c))) end
local function play(t, c, z) t:expect(t:answer(t:action(ACT_PLAY, c, z or "signi_left"))) end

local function zone(t)
  t:expect(t:wait(HINT_ZONE))
  t:expect(t:answer(t:request().options[1]))
end

-- ── 루리그 ──

-- 再来의 어택: 키가 있으면 《黒》《黒》을 내고 상대의 가드를 어렵게 한다
local function attack(t, key, yes)
  local lc = wd(t)
  if key then t:put(N[6], 0, "key") end
  ena(t, 2)
  local g = {t:put(N[19], 1, "hand"), t:put(N[18], 1, "hand")}
  t:begin(0, PHASE_ATTACK)
  pick(t, HINT_ATTACK_LRIG, lc)
  if key then
    pick(t, HINT_SCRIPT, yes)
    if yes == 1 then pay(t, 2) end
  end
  return g
end

case("再来の駄姫: 키가 있으면 《黒》2로, 가드하려면 가드 카드 2장을 버려야 한다", "WDK04-001 FAQ 1", function(t)
  local g = attack(t, true, 1)
  t:expect(t:wait(HINT_GUARD))
  t:expect(t:request().min == 0 and t:request().max == 2)
  t:expect(not t:answer(g[1]), "1장으로는 안 된다")
  t:expect(t:answer(g[1], g[2]))
  t:wait(HINT_MAIN)
  t:expect(t:count(1, "life_cloth") == 5 and t:is_in(g[1], 1, "trash") and t:is_in(g[2], 1, "trash"))
end)

case("再来の駄姫: 키가 없거나 내지 않으면 1장으로 가드", "WDK04-001", function(t)
  for _, c in ipairs{{false, 0}, {true, 0}} do
    local g = attack(t, c[1], c[2])
    t:expect(t:wait(HINT_GUARD))
    t:expect(t:request().max == 1)
    t:expect(t:answer(g[1]))
    t:wait(HINT_MAIN)
    t:expect(t:count(1, "life_cloth") == 5 and t:is_in(g[2], 1, "hand"))
  end
end)

case("再来の駄姫: 추가로 버리는 것은 가드할 수 없는 레벨이어도 된다. 가드하는 것은 안 된다", "WDK04-001 FAQ 2", function(t)
  local lc = wd(t)
  t:put(N[6], 0, "key")
  ena(t, 2)
  local a, b, c = t:put(N[19], 1, "hand"), t:put(N[19], 1, "hand"), t:put(N[18], 1, "hand")
  t:script(300000, [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetRange(LOCATION_SZONE)
  e1:SetOperation(function(e,tp)
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_GUARD)
    e2:SetTargetRange(0,1)
    e2:SetValue(1)
    e2:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e2,tp)
  end)
  c:RegisterEffect(e1)
end]])
  t:signi(300000, 1000, COLOR_BLACK, 1)
  local s = t:put(300000, 0, "signi_left")
  main(t)
  t:expect(t:answer(t:action(ACT_ABILITY, s)))
  t:expect(t:wait(HINT_MAIN))
  pick(t, HINT_ATTACK_LRIG, lc)
  pick(t, HINT_SCRIPT, 1)
  pay(t, 2)
  t:expect(t:wait(HINT_GUARD))
  t:expect(not t:answer(a, b), "둘 다 레벨 1")
  t:expect(t:answer(a, c))
  t:wait(HINT_MAIN)
  t:expect(t:is_in(a, 1, "trash") and t:is_in(c, 1, "trash"))
end)

case("再来の駄姫: 가드 카드가 모자라면 묻지 않는다", "WDK04-001 FAQ 1", function(t)
  local lc = wd(t)
  t:put(N[6], 0, "key")
  ena(t, 2)
  t:put(N[19], 1, "hand")
  t:begin(0, PHASE_ATTACK)
  pick(t, HINT_ATTACK_LRIG, lc)
  pick(t, HINT_SCRIPT, 1)
  pay(t, 2)
  t:wait(HINT_MAIN)
  t:expect(not t:saw(HINT_GUARD) and t:count(1, "life_cloth") == 4)
end)

case("再来の駄姫: 【出】 트래시의 시그니를 패에, 【起】는 메인·어택 페이즈에 턴 1회", "WDK04-001 FAQ 3", function(t)
  wd(t, 2)
  local g, x = t:put(N[1], 0, "lrig_deck"), t:put(TR, 0, "trash")
  t:begin(0, PHASE_GROW)
  pick(t, HINT_GROW, g)
  pick(t, HINT_TARGET, x)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(x, 0, "hand"))
  t:expect(t:answer(t:action(ACT_ABILITY, g)))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "trash") == 1 and t:action(ACT_ABILITY, g) == nil)
  local lc = wd(t)
  t:begin(0, PHASE_ATTACK)
  t:expect(t:wait(HINT_PRE_ATTACK))
  t:expect(t:action(ACT_ABILITY, lc) ~= nil)
end)

case("グズ子 레벨 2·3", "WDK04-002, WDK04-003 FAQ", function(t)
  for _, c in ipairs{{2, 3, 2, 1, 0, 1, 0}, {3, 4, 1, 0, 1, 0, 1}} do
    wd(t, c[2])
    local g = t:put(N[c[1]], 0, "lrig_deck")
    t:add_coin(0, c[5])
    ena(t, c[3] + c[4])
    t:begin(0, PHASE_GROW)
    pick(t, HINT_GROW, g)
    pay(t, c[3])
    pick(t, HINT_USE_TRIGGER, 1)
    if c[4] > 0 then pay(t, c[4]) end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:coins(0) == c[6] and t:count(0, "hand") == c[7])
  end
end)

-- ── いっしょにあーや！ ──

local function aya(t, declare, deck)
  wd(t)
  t:put(N[6], 0, "key")
  for _, c in ipairs(t:cards(0, "main_deck")) do t:move(c, 0, "exclude") end
  for _, cid in ipairs(deck) do t:put(cid, 0, "main_deck") end
  t:put(N[19], 0, "hand")
  local lc = t:cards(1, "lrig_center")[1]
  t:begin(1, PHASE_ATTACK)
  pick(t, HINT_ATTACK_LRIG, lc)
  t:expect(t:wait(HINT_MODE))
  t:expect(t:request().player == 1)
  t:expect(t:answer(declare))
end

case("いっしょにあーや！: 선언과 레벨이 다르면 어택이 무효(가드도 묻지 않는다)", "WDK04-006 FAQ 2", function(t)
  for _, c in ipairs{{0, BLK, true}, {1, BLK, false}, {0, TR, false}, {1, TR, true}} do  -- {0 짝수·1 홀수, 나오는 시그니, 무효}
    aya(t, c[1], {c[2], N[20]})
    if c[3] then
      t:wait(HINT_MAIN)
      t:expect(not t:saw(HINT_GUARD) and t:count(0, "life_cloth") == 5)
    else
      t:expect(t:wait(HINT_GUARD))
      t:expect(t:count(0, "main_deck") == 2 and t:refreshes(0) == 0)
    end
  end
end)

case("いっしょにあーや！: 시그니가 없으면 무효가 되지 않고 섞어서 덱으로", "WDK04-006 FAQ 3·4", function(t)
  aya(t, 0, {N[20], N[20]})
  t:expect(t:wait(HINT_GUARD))
  t:expect(t:count(0, "main_deck") == 2 and t:refreshes(0) == 0)
end)

-- ── 아츠 ──

case("バッド・ボンバー: 그때 있는 상대 시그니 모두 −12000", "WDK04-007", function(t)
  wd(t)
  local a, x, y, late = t:put(N[7], 0, "lrig_deck"), t:put(BIG, 1, "signi_left"), t:put(OPP, 1, "signi_center"), t:put(BIG, 1, "hand")
  ena(t, 1)
  main(t)
  use(t, a)
  pay(t, 1)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:power(x) == 3000 and t:is_in(y, 1, "ena"))
  t:move(late, 1, "signi_right")
  t:expect(t:power(late) == 15000)
end)

case("ブラッディ・アウト: 내 시그니를 놓아야 바니시. 베트하면 하나 더", "WDK04-008 FAQ 1~3", function(t)
  for _, c in ipairs{{0, true}, {1, true}, {1, false}} do  -- {베트, 내 시그니}
    wd(t)
    local a = t:put(N[8], 0, "lrig_deck")
    local h = c[2] and t:put(BLK, 0, "signi_left")
    local x, y = t:put(OPP, 1, "signi_left"), t:put(BIG, 1, "signi_center")
    t:add_coin(0, 2)
    ena(t, 2)
    main(t)
    use(t, a)
    pick(t, HINT_BET, c[1])
    pay(t, 2)
    pick(t, HINT_TARGET, x)
    if c[1] == 1 then
      t:expect(t:wait(HINT_TARGET))
      t:expect(#t:request().options == 1, "같은 시그니는 고를 수 없다")
      t:expect(t:answer(y))
    end
    if h then pick(t, HINT_SELECT, h) end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(x, 1, c[2] and "ena" or "signi_left") and t:is_in(y, 1, (c[2] and c[1] == 1) and "ena" or "signi_center"))
  end
end)

case("ブラッディ・アウト: 레벨 5 하나뿐이어도 베트하면 바니시", "WDK04-008 FAQ 4", function(t)
  wd(t)
  t:lrig(300000, 5, 12, {"グズ子"}, COLOR_BLACK)
  t:move(t:cards(1, "lrig_center")[1], 1, "exclude")
  t:put(300000, 1, "lrig_center")
  t:signi(300001, 15000, COLOR_RED, 5)
  local a, h, x = t:put(N[8], 0, "lrig_deck"), t:put(BLK, 0, "signi_left"), t:put(300001, 1, "signi_left")
  t:add_coin(0, 2)
  ena(t, 2)
  main(t)
  use(t, a)
  pick(t, HINT_BET, 1)
  pay(t, 2)
  pick(t, HINT_TARGET, x)
  pick(t, HINT_SELECT, h)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(x, 1, "ena"))
end)

case("グレイブ・アウェイク: 내 턴 2, 상대 턴 흑 3. 존이 없으면 내지 못한다", "WDK04-009 FAQ 1", function(t)
  for p = 0, 1 do
    wd(t)
    local a, x = t:put(N[9], 0, "lrig_deck"), t:put(TR, 0, "trash")
    ena(t, 3)
    if p == 0 then
      main(t)
    else
      t:begin(1, PHASE_ATTACK)
      t:expect(t:wait(HINT_DEFENSE))
    end
    use(t, a)
    pay(t, 2 + p)
    pick(t, HINT_TARGET, x)
    zone(t)
    t:wait(p == 0 and HINT_MAIN or HINT_ATTACK_LRIG)
    t:expect(t:at(x) ~= "trash")
  end
  wd(t)
  local a, x = t:put(N[9], 0, "lrig_deck"), t:put(TR, 0, "trash")
  for _, z in ipairs{"signi_left", "signi_center", "signi_right"} do t:put(BLK, 0, z) end
  ena(t, 2)
  main(t)
  use(t, a)
  pay(t, 2)
  pick(t, HINT_TARGET, x)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(x, 0, "trash"))
end)

-- ── 시그니 ──

case("ダークアリス: 짝수는 패에, 홀수는 트래시하고 −8000, 시그니가 아니면 그대로", "WDK04-011 FAQ 1", function(t)
  for _, c in ipairs{{TR, "hand"}, {TR1, "trash"}, {nil, "main_deck"}} do
    wd(t)
    local h, x = t:put(N[11], 0, "signi_left"), t:put(BIG, 1, "signi_left")
    local top = t:put(c[1] or N[20], 0, "main_deck")
    ena(t, 1)
    main(t)
    t:expect(t:answer(t:action(ACT_ABILITY, h)))
    pay(t, 1)
    if c[2] == "trash" then pick(t, HINT_TARGET, x) end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(top, 0, c[2]) and t:power(x) == (c[2] == "trash" and 7000 or 15000))
    t:expect(t:action(ACT_ABILITY, h) == nil)
  end
end)

case("ダイシャリン: 짝수 시그니면 에나에", "WDK04-012 FAQ 1", function(t)
  for _, c in ipairs{{TR, "ena"}, {TR1, "main_deck"}} do
    wd(t)
    local h, top = t:put(N[12], 0, "hand"), t:put(c[1], 0, "main_deck")
    main(t)
    play(t, h)
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(top, 0, c[2]))
  end
end)

case("バラバラ·チェシャ: 3장 보고 일부를 트래시, 나머지는 순서대로 위에", "WDK04-013 FAQ 1, WDK04-017", function(t)
  for n = 0, 3 do
    wd(t)
    local h = t:put(N[13], 0, "hand")
    local l = {t:put(TR, 0, "main_deck"), t:put(TR1, 0, "main_deck"), t:put(BLK, 0, "main_deck")}
    main(t)
    play(t, h)
    t:expect(t:wait(HINT_SELECT))
    t:expect(t:answer(table.unpack(l, 1, n)))
    if n < 2 then
      t:expect(t:wait(HINT_ORDER))
      t:expect(t:answer(table.unpack(l, n + 1, 3)))
    end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:count(0, "trash") == n)
    local d = t:cards(0, "main_deck")
    if n < 3 then t:expect(d[#d] == l[n + 1]) end
  end
  wd(t)
  local h = t:put(N[17], 0, "hand")
  local a, b, c = t:put(TR, 0, "main_deck"), t:put(TR1, 0, "main_deck"), t:put(BLK, 0, "main_deck")
  main(t)
  play(t, h)
  pick(t, HINT_ORDER, a, c, b)
  t:expect(t:wait(HINT_MAIN))
  local d = t:cards(0, "main_deck")
  t:expect(d[#d] == a and d[#d - 1] == c and d[#d - 2] == b)
end)

case("ジャバウォック: 가운데에서 어택, 홀수면 ＋5000과 【ランサー】. 짝수여도 아래에 놓을 수 있다", "WDK04-014 FAQ 1", function(t)
  for _, c in ipairs{{TR1, 1, "signi_center", true}, {TR, 1, "signi_center", false}, {TR1, 0, "signi_center", true}, {TR1, nil, "signi_left", false}} do
    wd(t)
    local h, top = t:put(N[14], 0, c[3]), t:put(c[1], 0, "main_deck")
    t:begin(0, PHASE_ATTACK)
    pick(t, HINT_ATTACK_SIGNI, h)
    if c[2] then pick(t, HINT_SCRIPT, c[2]) end
    t:expect(t:wait(HINT_ATTACK_LRIG))
    t:expect(t:power(h) == (c[4] and 12000 or 7000) and t:keyword(h, EFFECT_LANCER) == c[4])
    local d = t:cards(0, "main_deck")
    t:expect((d[1] == top) == (c[2] == 1))
  end
end)

case("マッドハッター: 홀수면 위에 두어도 《黒》으로 ＋7000과 능력", "WDK04-015 FAQ 1·2", function(t)
  wd(t)
  local h, x, top = t:put(N[15], 0, "hand"), t:put(BIG, 1, "signi_left"), t:put(TR1, 0, "main_deck")
  ena(t, 1)
  main(t)
  play(t, h)
  pick(t, HINT_SCRIPT, 0)
  pick(t, HINT_SCRIPT, 1)
  pay(t, 1)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:power(h) == 12000 and t:is_in(top, 0, "main_deck"))
  pick(t, HINT_ATTACK_SIGNI, h)
  pick(t, HINT_TARGET, x)
  t:wait(HINT_ATTACK_LRIG)
  t:expect(t:power(x) == 13000)
  wd(t)
  h = t:put(N[15], 0, "hand")
  t:put(TR, 0, "main_deck")
  ena(t, 1)
  main(t)
  play(t, h)
  pick(t, HINT_SCRIPT, 1)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:power(h) == 5000 and t:count(0, "ena") == 1)
end)

case("ウィッチ・ニッチ: 방금 놓은 시그니는 되돌릴 수 없다. ＜トリック＞가 없으면 되돌리지 않는다", "WDK04-020 FAQ 1~3", function(t)
  for _, on in ipairs{true, false} do
    wd(t)
    local sp, h, x = t:put(N[20], 0, "hand"), t:put(on and TR or BLK, 0, "signi_left"), t:put(TR1, 0, "trash")
    main(t)
    use(t, sp)
    pick(t, HINT_MODE, 0)
    if on then pick(t, HINT_TARGET, h) end
    t:expect(t:wait(HINT_TARGET))
    t:expect(#t:request().options == 1)
    t:expect(t:answer(x))
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(x, 0, on and "hand" or "trash"))
  end
end)
