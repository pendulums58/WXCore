-- WDK01 レイラ 구축덱 카드 스크립트 케이스 + ライド·ドライブ状態 룰. 근거는 카드별 FAQ(cards.json)·용어집: ライド, ドライブ状態

local N = {}
local JO, JO3, RED, OPP, BIG = 200000, 201000, 203000, 101000, 102000

local function wd(t, center)
  t:start{db = true, seed = 1}
  for i = 1, 20 do N[i] = t:no(("WDK01-%03d"):format(i)) end
  t:card{cid = JO, power = 4000, level = 2, classes = {"精械：乗機"}, color = COLOR_RED}
  t:card{cid = JO3, power = 5000, level = 3, classes = {"精械：乗機"}, color = COLOR_RED}
  t:signi(RED, 1000, COLOR_RED, 1)
  t:signi(OPP, 3000, COLOR_GREEN, 1)
  t:signi(BIG, 15000, COLOR_GREEN, 4)
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

local function ena(t, n)
  for _ = 1, n do t:put(RED, 0, "ena") end
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
local function ability(t, c, n) return t:action(ACT_ABILITY, c, n or 0) end

local function ride(t, lc, c)
  t:expect(t:answer(ability(t, lc)))
  pick(t, HINT_TARGET, c)
end

-- 火旗相当 ①로 c에 탄다
local function switch(t, c)
  local a = t:put(N[8], 0, "lrig_deck")
  return function()
    use(t, a)
    pick(t, HINT_MODE, 0)
    pay(t, 1)
    pick(t, HINT_TARGET, c)
  end
end

-- ── ライド ──

case("ライド: ＜乗機＞에만, ドライブ状態면 쓸 수 없다. 루리그는 어택할 수 없고 시그니는 할 수 있다", "용어집: ライド, ドライブ状態", function(t)
  local lc = wd(t)
  local j = t:put(JO, 0, "signi_left")
  t:put(RED, 0, "signi_center")
  main(t)
  t:expect(t:answer(ability(t, lc)))
  t:expect(t:wait(HINT_TARGET))
  t:expect(#t:request().options == 1)
  t:expect(t:answer(j))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:drive(lc) and t:drive(j) and ability(t, lc) == nil)
  t:expect(#t:under(lc) == 0, "밑의 카드가 아니다")
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:answer(j))
  t:wait(HINT_MAIN)
  t:expect(not t:saw(HINT_ATTACK_LRIG), "루리그는 어택할 수 없다")
end)

case("ライド: 턴이 끝나면 ドライブ状態가 아니다", "용어집: ライド(ターン終了時まで)", function(t)
  local lc = wd(t)
  local j = t:put(JO, 0, "signi_left")
  main(t)
  ride(t, lc, j)
  t:expect(t:wait(HINT_MAIN) and t:drive(j))
  t:expect(t:answer(t:action(ACT_END)))
  t:wait(HINT_MAIN)
  t:expect(not t:drive(lc) and not t:drive(j))
end)

case("ライド: 탄 시그니가 장을 떠나면 루리그도 ドライブ状態가 아니다. 데미지도 【出】도 없다", "용어집: ドライブ状態, WDK01-001 FAQ 3·4", function(t)
  local lc = wd(t)
  local j, sp, x = t:put(JO, 0, "signi_left"), t:put(N[20], 0, "hand"), t:put(OPP, 1, "signi_left")
  main(t)
  ride(t, lc, j)
  t:expect(t:wait(HINT_MAIN))
  use(t, sp)
  pick(t, HINT_MODE, 0)
  pick(t, HINT_TARGET, j)
  pick(t, HINT_TARGET, x)
  t:expect(t:wait(HINT_MAIN))
  t:expect(not t:drive(lc) and t:count(0, "life_cloth") == 5 and not t:saw(HINT_USE_TRIGGER))
  t:expect(t:wait(HINT_ATTACK_LRIG), "다시 어택할 수 있다")
end)

case("ライド: 장 안에서 옮기거나 ＜乗機＞가 아니게 돼도 그대로", "용어집: ライド", function(t)
  local lc = wd(t)
  local j = t:put(JO, 0, "signi_left")
  main(t)
  ride(t, lc, j)
  t:expect(t:wait(HINT_MAIN))
  t:move(j, 0, "signi_center")
  t:expect(t:drive(j) and t:drive(lc))
end)

case("ライド: 그로우하면 ドライブ状態를 이어받고, 떠난 뒤에는 새 루리그가 다시 쓸 수 있다", "WDK01-001 FAQ 1", function(t)
  local lc = wd(t, 2)
  t:script(300000, [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetRange(LOCATION_SZONE)
  e1:SetOperation(function(e,tp) Duel.SendToTrash(e:GetHandler(),REASON_EFFECT) end)
  c:RegisterEffect(e1)
end]])
  t:card{cid = 300000, power = 4000, level = 2, classes = {"精械：乗機"}, color = COLOR_RED}
  local j, k = t:put(300000, 0, "signi_left"), t:put(JO, 0, "signi_center")
  main(t)
  ride(t, lc, j)
  t:expect(t:wait(HINT_MAIN))
  local up = t:put(N[1], 0, "lrig_deck")
  t:move(up, 0, "lrig_center")
  t:put_under(lc, up)
  t:expect(t:drive(up) and t:drive(j))
  t:expect(t:answer(ability(t, j)))
  t:expect(t:wait(HINT_MAIN))
  t:expect(not t:drive(up) and ability(t, up) ~= nil)
  ride(t, up, k)
  t:expect(t:wait(HINT_MAIN) and t:drive(k))
end)

-- ── 루리그 ──

case("レイラ＝フルスロットル: 【出】 바니시, 【起】 코인으로 ＜乗機＞를 찾아 장에. 찾지 않아도 된다", "WDK01-001 FAQ 5·6", function(t)
  for _, yes in ipairs{true, false} do
    wd(t, 2)
    local g, x, j = t:put(N[1], 0, "lrig_deck"), t:put(BIG, 1, "signi_left"), t:put(JO3, 0, "main_deck")
    t:add_coin(0, 1)
    ena(t, 1)
    t:begin(0, PHASE_GROW)
    pick(t, HINT_GROW, g)
    pick(t, HINT_USE_TRIGGER, 1)
    pay(t, 1)
    pick(t, HINT_TARGET, x)
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(x, 1, "ena"))
    t:expect(t:answer(ability(t, g, 1)))
    t:expect(t:wait(HINT_SELECT))
    if yes then
      t:expect(t:answer(j))
      t:expect(t:wait(HINT_ZONE) and t:answer(t:request().options[1]))
    else
      t:expect(t:answer())
    end
    t:expect(t:wait(HINT_MAIN))
    t:expect((t:at(j) ~= "main_deck") == yes and t:coins(0) == 0)
  end
end)

case("レイラ 레벨 1~3", "WDK01-002~004 FAQ", function(t)
  -- {카드, 지금, 그로우 코스트, 【出】 에나, 시작 코인, 버리기, 끝 코인, 끝 패}
  for _, c in ipairs{{2, 3, 2, 1, 0, 0, 1, 0}, {3, 4, 1, 0, 1, 0, 0, 1}, {4, 5, 0, 0, 0, 1, 1, 0}} do
    wd(t, c[2])
    local g = t:put(N[c[1]], 0, "lrig_deck")
    t:add_coin(0, c[5])
    ena(t, c[3] + c[4])
    local h = c[6] > 0 and t:put(RED, 0, "hand")
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

-- ── 아츠 ──

case("焚骨砕身: 2체가 아니면 대상으로 하지 않는다", "WDK01-006(１体のシグニだけに使用することはできない)", function(t)
  for _, n in ipairs{2, 1} do
    wd(t)
    local a, x = t:put(N[6], 0, "lrig_deck"), t:put(BIG, 1, "signi_left")
    local y = n == 2 and t:put(OPP, 1, "signi_center")
    ena(t, 6)
    t:begin(0, PHASE_ATTACK)
    t:expect(t:wait(HINT_PRE_ATTACK))
    use(t, a)
    pay(t, 6)
    if n == 2 then pick(t, HINT_TARGET, x, y) end
    t:expect(t:wait(HINT_ATTACK_LRIG))
    t:expect(t:is_in(x, 1, n == 2 and "ena" or "signi_left"))
  end
end)

case("質実轟健: ドライブ状態면 더블, 레벨 3 이상이면 트리플. 그 뒤 잃지 않는다. 베트하면 에나 없이", "WDK01-007 FAQ 1~3", function(t)
  for _, c in ipairs{{JO, EFFECT_DOUBLE_CRUSH}, {JO3, EFFECT_TRIPLE_CRUSH}} do
    local lc = wd(t)
    local j, k = t:put(c[1], 0, "signi_left"), t:put(JO, 0, "signi_center")
    local a, sw = t:put(N[7], 0, "lrig_deck"), switch(t, k)
    t:add_coin(0, 1)
    ena(t, 1)
    main(t)
    ride(t, lc, j)
    t:expect(t:wait(HINT_MAIN))
    use(t, a)
    pick(t, HINT_TARGET, j)
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:keyword(j, c[2]) and t:coins(0) == 0)
    sw()
    t:expect(t:wait(HINT_MAIN))
    t:expect(not t:drive(j) and t:drive(k) and t:keyword(j, c[2]))
  end
end)

case("火旗相当: ② 5장 보고 ＜乗機＞를 3장까지. 덱이 모자라도 리프레시하지 않는다", "WDK01-008 FAQ 2·3", function(t)
  wd(t)
  for _, c in ipairs(t:cards(0, "main_deck")) do t:move(c, 0, "exclude") end
  local a, b = t:put(JO, 0, "main_deck"), t:put(JO3, 0, "main_deck")
  t:put(RED, 0, "main_deck")
  local arts = t:put(N[8], 0, "lrig_deck")
  ena(t, 1)
  main(t)
  use(t, arts)
  pick(t, HINT_MODE, 1)
  pay(t, 1)
  t:expect(t:wait(HINT_SELECT))
  t:expect(t:request().min == 0 and #t:request().options == 2)
  t:expect(t:answer(a, b))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "hand") == 2 and t:count(0, "main_deck") == 1 and t:refreshes(0) == 0)
end)

case("剣抜弩焼: 센터가 빨강일 때만. 바니시하고 2장 버린다(모자라면 있는 만큼)", "WDK01-009 FAQ 1·2", function(t)
  for _, n in ipairs{3, 1} do
    wd(t)
    local a, x = t:put(N[9], 0, "lrig_deck"), t:put(BIG, 1, "signi_left")
    t:fill(RED, 0, "hand", n)
    main(t)
    use(t, a)
    pick(t, HINT_TARGET, x)
    pick(t, HINT_DISCARD, table.unpack(t:cards(0, "hand"), 1, math.min(2, n)))
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(x, 1, "ena") and t:count(0, "hand") == math.max(0, n - 2))
  end
  wd(t)
  t:lrig(300000, 4, 11, {"レイラ"}, COLOR_BLUE)
  t:move(t:cards(0, "lrig_center")[1], 0, "exclude")
  t:put(300000, 0, "lrig_center")
  local a = t:put(N[9], 0, "lrig_deck")
  main(t)
  t:expect(t:action(ACT_USE, a) == nil)
end)

-- ── 시그니 ──

case("ヤマテ: ドライブ状態면 ＋3000, 어택하면 자기 파워 이하를 바니시", "WDK01-011 FAQ 1", function(t)
  for _, on in ipairs{true, false} do
    local lc = wd(t)
    local j, x = t:put(N[11], 0, "signi_left"), t:put(BIG, 1, "signi_left")
    main(t)
    if on then
      ride(t, lc, j)
      t:expect(t:wait(HINT_MAIN))
    end
    t:expect(t:power(j) == (on and 15000 or 12000))
    pick(t, HINT_ATTACK_SIGNI, j)
    if on then pick(t, HINT_TARGET, x) end
    t:wait(HINT_MAIN)
    t:expect(t:is_in(x, 1, on and "ena" or "signi_left"))
  end
end)

case("ロメン·シンカン·ゴーカート: ドライブ状態가 되면 바니시. 이미 그 상태면 아니다", "WDK01-012 FAQ 1·2, WDK01-014, WDK01-017 FAQ 1", function(t)
  for _, c in ipairs{{12, BIG, true}, {14, BIG, false}, {14, OPP, true}, {17, OPP, true}} do
    wd(t)
    local j, x, y = t:put(N[c[1]], 0, "signi_left"), t:put(c[2], 1, "signi_left"), t:put(OPP, 1, "signi_center")
    if c[2] == BIG and not c[3] then t:move(y, 1, "exclude") end
    local s1, s2 = switch(t, j), switch(t, j)
    ena(t, 2)
    main(t)
    s1()
    if c[3] then pick(t, HINT_TARGET, x) end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(x, 1, c[3] and "ena" or "signi_left"), c[1])
    if c[3] then
      s2()
      t:expect(t:wait(HINT_MAIN))
      t:expect(t:is_in(y, 1, "signi_center"), "이미 ドライブ状態")
    end
  end
end)

case("ゴーカート: 갈아타면 새로 탄 쪽도 발동", "WDK01-017 FAQ 2", function(t)
  local lc = wd(t)
  local a, b = t:put(N[17], 0, "signi_left"), t:put(N[17], 0, "signi_center")
  local x, y = t:put(OPP, 1, "signi_left"), t:put(OPP, 1, "signi_center")
  local sw = switch(t, b)
  ena(t, 1)
  main(t)
  ride(t, lc, a)
  pick(t, HINT_TARGET, x)
  t:expect(t:wait(HINT_MAIN))
  sw()
  pick(t, HINT_TARGET, y)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(x, 1, "ena") and t:is_in(y, 1, "ena") and not t:drive(a) and t:drive(b))
end)

case("トッキュウ·ワゴン: ドライブ状態의 시그니가 있으면 ＋4000(자신이어도), 자신이면 ＋7000", "WDK01-013 FAQ 1, WDK01-015 FAQ 1", function(t)
  local lc = wd(t)
  local k, w = t:put(N[13], 0, "signi_left"), t:put(N[15], 0, "signi_center")
  main(t)
  t:expect(t:power(k) == 8000 and t:power(w) == 5000)
  ride(t, lc, w)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:power(k) == 12000 and t:power(w) == 12000)
  lc = wd(t)
  k = t:put(N[13], 0, "signi_left")
  main(t)
  ride(t, lc, k)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:power(k) == 12000)
end)

case("光明の流星: ＜乗機＞가 없으면 바니시하지 않는다. ②는 에나 차지", "WDK01-020 FAQ 2", function(t)
  wd(t)
  local sp, x = t:put(N[20], 0, "hand"), t:put(OPP, 1, "signi_left")
  t:put(RED, 0, "signi_left")
  main(t)
  use(t, sp)
  pick(t, HINT_MODE, 0)
  pick(t, HINT_TARGET, x)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(x, 1, "signi_left"))
  wd(t)
  sp = t:put(N[20], 0, "hand")
  main(t)
  use(t, sp)
  pick(t, HINT_MODE, 1)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "ena") == 1)
end)
