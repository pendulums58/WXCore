-- WDK07 エルドラ·ユキ 구축덱 카드 스크립트 케이스와 【シード】·【デコレ】 룰. 근거는 카드별 FAQ(cards.json)

local E, Y = {}, {}
local CH, CH4, BLUE, PL, PL4, WHITE, OPP, MID, BIG, SPELL = 200000, 200004, 203000, 205000, 205004, 206000, 101000, 101500, 102000, 204000

local function wd(t, center)
  t:start{db = true, seed = 1}
  for i = 1, 20 do
    E[i] = t:no(("WDK07-E%02d"):format(i))
    Y[i] = t:no(("WDK07-Y%02d"):format(i))
  end
  t:card{cid = CH, power = 4000, level = 2, classes = {"精械：調理"}, color = COLOR_BLUE}
  t:card{cid = CH4, power = 4000, level = 5, classes = {"精械：調理"}, color = COLOR_BLUE}
  t:card{cid = PL, power = 4000, level = 2, classes = {"精羅：植物"}, color = COLOR_WHITE}
  t:card{cid = PL4, power = 4000, level = 5, classes = {"精羅：植物"}, color = COLOR_WHITE}
  t:signi(BLUE, 1000, COLOR_BLUE, 1)
  t:signi(WHITE, 1000, COLOR_WHITE, 1)
  t:signi(OPP, 3000, COLOR_RED, 1)
  t:signi(MID, 9000, COLOR_RED, 3)
  t:signi(BIG, 15000, COLOR_RED, 4)
  t:card{cid = SPELL, type = TYPE_SPELL, color = COLOR_BLUE, timing = TIMING_MAIN}
  t:fill(BLUE, 0, "main_deck", 15)
  t:fill(OPP, 1, "main_deck", 15)
  t:fill(BLUE, 0, "life_cloth", 5)
  t:fill(OPP, 1, "life_cloth", 5)
  t:put(E[1], 1, "lrig_center")
  return t:put(E[center or 1], 0, "lrig_center")
end

local function yuki(t, n)
  wd(t)
  t:move(t:cards(0, "lrig_center")[1], 0, "exclude")
  return t:put(Y[n or 1], 0, "lrig_center")
end

local function main(t, p)
  t:begin(p or 0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
end

local function ena(t, n, cid)
  for _ = 1, n do t:put(cid or BLUE, 0, "ena") end
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

-- 덱을 아래부터 이 카드들로
local function deck(t, ...)
  for _, c in ipairs(t:cards(0, "main_deck")) do t:move(c, 0, "exclude") end
  local out = {}
  for i, cid in ipairs{...} do out[i] = t:put(cid, 0, "main_deck") end
  return out
end

local function seed(t, cid, z)
  local c = t:put(cid, 0, "hand")
  t:set_seed(c, 0, z)
  return c
end

local function trap(t, cid, z)
  local c = t:put(cid, 0, "hand")
  t:set_trap(c, 0, z)
  return c
end

-- ── 【シード】 룰 ──

case("シード: 상대는 모른다. 시그니가 있는 존에도 두고, 둔 곳에 시그니를 낼 수 있다. 새로 두면 전의 것은 트래시", "용어집: シード", function(t)
  yuki(t)
  local h = t:put(WHITE, 0, "hand")
  t:put(WHITE, 0, "signi_left")
  local a, b = seed(t, PL4, "signi_left"), seed(t, PL, "signi_center")
  t:expect(t:seed(0, "signi_left") == a and t:can_see(0, a) and not t:can_see(1, a))
  main(t)
  play(t, h, "signi_center")
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:seed(0, "signi_center") == b and t:is_in(h, 0, "signi_center"))
  local n = seed(t, PL, "signi_left")
  t:expect(t:is_in(a, 0, "trash") and t:can_see(1, a) and t:seed(0, "signi_left") == n)
end)

case("シード: 시그니가 아니다. 정면의 시그니가 어택하면 대미지. 【トラップ】과 같은 존에 있을 수 있다", "용어집: シード, 설계: 세트 층", function(t)
  yuki(t)
  local x = t:put(BIG, 1, "signi_right")
  local a = seed(t, PL, "signi_left")
  local tr = trap(t, WHITE, "signi_left")
  t:expect(t:seed(0, "signi_left") == a and t:trap(0, "signi_left") == tr)
  t:begin(1, PHASE_ATTACK)
  pick(t, HINT_ATTACK_SIGNI, x)
  if t:wait(HINT_TRAP) then t:expect(t:answer(0)) end
  t:wait(HINT_ATTACK_LRIG)
  t:expect(t:seed(0, "signi_left") == a)
end)

-- 花軍로 그로우해 개화한다
local function bloom(t, setup)
  yuki(t, 2)
  local g = t:put(Y[1], 0, "lrig_deck")
  ena(t, 1, WHITE)
  local list = setup()
  t:begin(0, PHASE_GROW)
  pick(t, HINT_GROW, g)
  pick(t, HINT_USE_TRIGGER, 1)
  pay(t, 1)
  pick(t, HINT_TARGET, table.unpack(list))
  return g
end

case("花軍の巫女: 개화하면 시그니가 되고 「場に出たとき」는 나지 않는다. 시그니가 있는 존은 그대로, 시그니가 아니면 트래시", "WDK07-Y01, 용어집: 開花する", function(t)
  local a, b, c
  bloom(t, function()
    t:put(WHITE, 0, "signi_center")
    t:script(PL, [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e1)
end]])
    a, b, c = seed(t, PL, "signi_left"), seed(t, PL, "signi_center"), seed(t, SPELL, "signi_right")
    return {a, b, c}
  end)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(a, 0, "signi_left") and t:power(a) == 4000 and t:can_see(1, a) and t:seed(0, "signi_left") == nil)
  t:expect(t:seed(0, "signi_center") == b and t:is_in(c, 0, "trash") and t:count(0, "hand") == 0)
end)

case("開花: 루리그의 레벨을 넘거나 한정 조건이 안 맞으면 룰로 트래시. 「開花したとき」는 발동한다", "용어집: 開花する", function(t)
  local a, b
  bloom(t, function()
    t:script(PL4, [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetCode(EVENT_BLOOM)
  e1:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e1)
end]])
    a, b = seed(t, PL4, "signi_left"), seed(t, E[13], "signi_right")
    return {a, b}
  end)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(a, 0, "trash") and t:is_in(b, 0, "trash") and t:count(0, "hand") == 1)
end)

-- ── ユキ ──

case("花軍の巫女: 【起】 ＜植物＞를 버려 에나 차지 2", "WDK07-Y01", function(t)
  local lc = yuki(t)
  t:put(WHITE, 0, "hand")
  local h = t:put(PL, 0, "hand")
  main(t)
  t:expect(t:answer(t:action(ACT_ABILITY, lc)))
  t:expect(t:wait(HINT_DISCARD))
  t:expect(#t:request().options == 1)
  t:expect(t:answer(h))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "ena") == 2 and t:action(ACT_ABILITY, lc) == nil)
end)

case("花候の巫女: 4장 중 1장을 シード로, 나머지는 덱 아래. 덱이 3장이어도 리프레시하지 않는다", "WDK07-Y02 FAQ 2", function(t)
  for _, n in ipairs{6, 3, 1} do
    yuki(t, 3)
    local g = t:put(Y[2], 0, "lrig_deck")
    local l = {}
    for i = 1, n do l[i] = WHITE end
    local d = deck(t, table.unpack(l))
    t:put(WHITE, 0, "trash")
    ena(t, 2, WHITE)
    t:begin(0, PHASE_GROW)
    pick(t, HINT_GROW, g)
    pay(t, 2)
    t:step()
    for _ = 1, 10 do
      local q = t:request()
      if not q or q.hint == HINT_SELECT then break end
      if q.hint == HINT_TRIGGER_ORDER then t:answer(0) end
      t:step()
    end
    t:expect(t:request().hint == HINT_SELECT and #t:request().options == math.min(4, n))
    t:expect(t:answer(d[n]))
    t:expect(t:wait(HINT_ZONE))
    t:expect(t:refreshes(0) == 0)
    t:expect(t:answer(t:request().options[1]))
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:coins(0) == 2 and t:seed(0, "signi_left") == d[n])
    t:expect(t:refreshes(0) == (n == 1 and 1 or 0))
    if n > 1 then t:expect(t:count(0, "main_deck") == n - 1) end
  end
end)

case("花園·花影の巫女: 코스트가 있는 【出】은 안 써도 된다. シード를 내지 않아도 된다", "WDK07-Y03, WDK07-Y04", function(t)
  for _, c in ipairs{{3, 4, 1}, {4, 5, 0}} do
    yuki(t, c[2])
    local g, h = t:put(Y[c[1]], 0, "lrig_deck"), t:put(WHITE, 0, "hand")
    t:add_coin(0, 1)
    ena(t, c[3], WHITE)
    t:begin(0, PHASE_GROW)
    pick(t, HINT_GROW, g)
    if c[3] > 0 then pay(t, c[3]) end
    local saw = {}
    for _ = 1, 12 do
      t:step()
      local q = t:request()
      if not q or q.hint == HINT_MAIN then break end
      saw[q.hint] = true
      if q.hint == HINT_TRIGGER_ORDER then t:answer(0)
      elseif q.hint == HINT_USE_TRIGGER then t:answer(0)
      elseif q.hint == HINT_SELECT then t:answer() end
    end
    t:expect(saw[HINT_USE_TRIGGER] and saw[HINT_SELECT])
    t:expect(t:coins(0) == 1 and t:is_in(h, 0, "hand") and t:count(0, "hand") == 1 and t:count(0, "main_deck") == 15)
  end
end)

case("ハーベスト・フォース: 2체여야 한다", "WDK07-Y06 FAQ 1", function(t)
  for n = 1, 2 do
    yuki(t)
    local a, x = t:put(Y[6], 0, "lrig_deck"), t:put(BIG, 1, "signi_left")
    local y = n == 2 and t:put(OPP, 1, "signi_center")
    ena(t, 6, WHITE)
    t:begin(0, PHASE_ATTACK)
    t:expect(t:wait(HINT_PRE_ATTACK))
    use(t, a)
    pay(t, 6)
    if y then
      t:expect(t:wait(HINT_TARGET))
      t:expect(t:request().min == 2)
      t:expect(t:answer(x, y))
    end
    t:wait(HINT_ATTACK_LRIG)
    t:expect(t:is_in(x, 1, n == 2 and "hand" or "signi_left"))
  end
end)

case("ホワイト・シーディング: 시그니를 패로 되돌리고 개화한 다음 シード를 낸다. ベット하면 코스트 0", "WDK07-Y07 FAQ 1·4·5", function(t)
  for _, bet in ipairs{1, 0} do
    yuki(t)
    local a, h, s = t:put(Y[7], 0, "lrig_deck"), t:put(WHITE, 0, "signi_left"), seed(t, PL, "signi_left")
    local d = deck(t, WHITE, WHITE, SPELL)
    t:add_coin(0, 1)
    ena(t, 2, WHITE)
    main(t)
    use(t, a)
    pick(t, HINT_BET, bet)
    if bet == 0 then pay(t, 2) end
    pick(t, HINT_TARGET, s)
    t:expect(t:wait(HINT_SELECT))
    t:expect(t:is_in(h, 0, "hand") and t:is_in(s, 0, "signi_left") and t:refreshes(0) == 0)
    t:expect(t:answer(d[3]))
    zone(t)
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:seed(0, "signi_left") == d[3] and t:count(0, "main_deck") == 2 and t:count(0, "ena") == 2 * bet)
  end
end)

case("ホワイト・シーディング: シード가 없어도 덱에서 낸다", "WDK07-Y07", function(t)
  yuki(t)
  local a = t:put(Y[7], 0, "lrig_deck")
  t:add_coin(0, 1)
  main(t)
  use(t, a)
  -- 에나가 없어 ベット하는 수밖에 없으면 묻지 않는다
  t:expect(t:wait(HINT_SELECT))
  t:expect(t:answer(t:request().options[1]))
  zone(t)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:seed(0, "signi_left") ~= nil and not t:saw(HINT_TARGET))
end)

case("イクエス・ディフェンス: 같은 시그니도 된다. 능력을 잃은 뒤 「アタックできない」. ベット하면 루리그도", "WDK07-Y08 FAQ 1·2", function(t)
  for _, bet in ipairs{0, 1} do
    yuki(t)
    local a = t:put(Y[8], 0, "lrig_deck")
    local x, y = t:put(BIG, 1, "signi_left"), t:put(OPP, 1, "signi_center")
    local lc = t:cards(1, "lrig_center")[1]
    t:single(x, EFFECT_LANCER, 1, 1)
    t:add_coin(0, 1)
    ena(t, 3, WHITE)
    t:begin(1, PHASE_ATTACK)
    t:expect(t:wait(HINT_DEFENSE))
    use(t, a)
    pick(t, HINT_BET, bet)
    pay(t, 3)
    pick(t, HINT_TARGET, x)
    pick(t, HINT_TARGET, x)
    if bet == 1 then pick(t, HINT_TARGET, lc) end
    t:expect(t:wait(HINT_ATTACK_SIGNI))
    t:expect(#t:request().options == 1 and t:request().options[1] == y, "x는 어택할 수 없다")
    t:expect(t:answer())
    t:wait(HINT_ATTACK_LRIG)
    t:expect((t:request().player == 1) == (bet == 0))
  end
end)

case("月鍵の巫女: 센터와 같은 레벨·공통 색. 키를 놓고 2장까지", "WDK07-Y09 FAQ 2", function(t)
  yuki(t)
  local k = t:put(Y[9], 0, "lrig_deck")
  t:signi(300000, 1000, COLOR_WHITE, 4)
  local d = deck(t, 300000, WHITE, BIG, 300000, WHITE)
  t:add_coin(0, 1)
  main(t)
  t:expect(t:answer(t:action(ACT_KEY, k)))
  t:expect(t:wait(HINT_SELECT))
  t:expect(#t:request().options == 2 and t:request().max == 1)
  t:expect(t:answer(d[1]))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:answer(t:action(ACT_ABILITY, k)))
  pick(t, HINT_SELECT, d[4])
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(k, 0, "lrig_trash") and t:is_in(d[1], 0, "hand") and t:is_in(d[4], 0, "hand"))
end)

case("月鍵の巫女: 센터가 무색이면 무색 시그니도 찾지 못한다", "WDK07-Y09 FAQ 1", function(t)
  wd(t)
  t:lrig(300000, 1, 11, {"夢限"}, 0)
  t:move(t:cards(0, "lrig_center")[1], 0, "exclude")
  t:put(300000, 0, "lrig_center")
  local k = t:put(Y[9], 0, "lrig_deck")
  t:put(Y[19], 0, "main_deck")
  t:add_coin(0, 1)
  main(t)
  t:expect(t:answer(t:action(ACT_KEY, k)))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "hand") == 0)
end)

case("アネモネ: 개화하면 ① 1장 뽑고 에나 차지(덱 1장이면 에나는 없다) ② 상대 시그니를 패로", "WDK07-Y11 FAQ 3", function(t)
  for _, c in ipairs{{0, 15}, {0, 1}, {1, 15}} do
    local x
    local s
    bloom(t, function()
      x = t:put(BIG, 1, "signi_left")
      s = seed(t, Y[11], "signi_left")
      if c[2] == 1 then
        deck(t, WHITE)
        t:put(WHITE, 0, "trash")
      end
      return {s}
    end)
    pick(t, HINT_MODE, c[1])
    if c[1] == 1 then pick(t, HINT_TARGET, x) end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(s, 0, "signi_left") and t:is_in(x, 1, c[1] == 1 and "hand" or "signi_left"))
    if c[1] == 0 then t:expect(t:count(0, "hand") == 1 and t:count(0, "ena") == (c[2] == 1 and 0 or 1)) end
    t:expect(t:refreshes(0) == (c[2] == 1 and 1 or 0))
  end
end)

case("アネモネ: 바니시되면 ＜植物＞를 버리고 덱 위의 ＜植物＞를 낸다. 아니면 덱 위 그대로", "WDK07-Y11 FAQ 2", function(t)
  for _, top in ipairs{PL, WHITE} do
    yuki(t)
    local h, x, p = t:put(Y[11], 0, "signi_left"), t:put(BIG, 1, "signi_right"), t:put(PL, 0, "hand")
    local d = t:put(top, 0, "main_deck")
    t:begin(1, PHASE_ATTACK)
    pick(t, HINT_ATTACK_SIGNI, x)
    pick(t, HINT_DISCARD, p)
    if top == PL then zone(t) end
    t:wait(HINT_ATTACK_LRIG)
    t:expect(t:is_in(h, 0, "ena") and t:is_in(p, 0, "trash") and (t:at(d) ~= "main_deck") == (top == PL))
  end
end)

case("ウメ·クジャクソウ: 에나의 ＜植物＞ 3장·2장을 트래시에 두는 코스트", "WDK07-Y12, WDK07-Y13", function(t)
  yuki(t)
  local u, x = t:put(Y[12], 0, "signi_left"), t:put(BIG, 1, "signi_left")
  ena(t, 2, PL)
  ena(t, 1, WHITE)
  main(t)
  t:expect(t:action(ACT_ABILITY, u) == nil, "＜植物＞ 2장")
  yuki(t)
  u, x = t:put(Y[12], 0, "signi_left"), t:put(BIG, 1, "signi_left")
  ena(t, 3, PL)
  main(t)
  t:expect(t:answer(t:action(ACT_ABILITY, u)))
  if t:wait(HINT_SELECT) then t:expect(t:answer(table.unpack(t:cards(0, "ena")))) end
  pick(t, HINT_TARGET, x)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(x, 1, "trash") and t:count(0, "ena") == 0)
  yuki(t)
  local k = t:put(Y[13], 0, "hand")
  t:put(BIG, 1, "signi_left")
  local y = t:put(MID, 1, "signi_center")
  ena(t, 2, PL)
  main(t)
  play(t, k)
  pick(t, HINT_USE_TRIGGER, 1)
  pick(t, HINT_SELECT, table.unpack(t:cards(0, "ena")))
  t:expect(t:wait(HINT_TARGET))
  t:expect(#t:request().options == 1)
  t:expect(t:answer(y))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(y, 1, "hand"))
end)

case("アベリア: 중앙에서 어택하면 ＜植物＞ 3체일 때 에나 차지 2. 개화하면 1장", "WDK07-Y14", function(t)
  for _, c in ipairs{{"signi_center", 3, 2}, {"signi_center", 2, 0}, {"signi_left", 3, 0}} do
    yuki(t)
    local h = t:put(Y[14], 0, c[1])
    for _, z in ipairs{"signi_left", "signi_center", "signi_right"} do
      if z ~= c[1] and (c[2] == 3 or z ~= "signi_right") then t:put(PL, 0, z) end
    end
    t:begin(0, PHASE_ATTACK)
    pick(t, HINT_ATTACK_SIGNI, h)
    t:wait(HINT_ATTACK_SIGNI)
    t:expect(t:count(0, "ena") == c[3], c[1])
  end
  local s
  bloom(t, function()
    s = seed(t, Y[14], "signi_left")
    return {s}
  end)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "hand") == 1)
end)

case("サンザカ: 바니시되면 《白》《無》으로 에나에서 장에. 자신을 코스트로 내면 나오지 못한다", "WDK07-Y15 FAQ 1", function(t)
  for _, self in ipairs{false, true} do
    yuki(t)
    local h, x = t:put(Y[15], 0, "signi_left"), t:put(BIG, 1, "signi_right")
    ena(t, self and 1 or 2, WHITE)
    t:begin(1, PHASE_ATTACK)
    pick(t, HINT_ATTACK_SIGNI, x)
    pick(t, HINT_SCRIPT, 1)
    t:expect(t:wait(HINT_PAY_ENA))
    local l = t:cards(0, "ena")
    t:expect(t:answer(l[1], l[2]))
    if not self then zone(t) end
    t:wait(HINT_ATTACK_LRIG)
    t:expect(t:is_in(h, 0, "trash") == self and (self or t:at(h) ~= "ena"))
  end
end)

-- 상대가 시그니·아츠의 효과로 마가렛을 바니시한다
case("マーガレット: 상대 시그니의 효과로 바니시되지 않는다(ライフバースト도). 아츠와 파워 0은 된다", "WDK07-Y17, PR-388 FAQ", function(t)
  local src = [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(%s)
  e1:SetRange(LOCATION_SZONE)
  e1:SetOperation(function(e,tp)
    for tc in Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil):Iter() do %s end
  end)
  c:RegisterEffect(e1)
end]]
  for _, c in ipairs{{"signi", "Duel.Banish(tc)", "signi_center"}, {"signi", "aux.AddPower(e,tc,-1000)", "ena"}, {"arts", "Duel.Banish(tc)", "ena"}} do
    yuki(t)
    local h = t:put(Y[17], 0, "signi_center")
    if c[1] == "signi" then t:signi(300000, 1000, COLOR_RED, 1)
    else t:card{cid = 300000, type = TYPE_ARTS, timing = TIMING_MAIN} end
    t:script(300000, src:format(c[1] == "signi" and "EFFECT_TYPE_IGNITION" or "EFFECT_TYPE_ACTIVATE", c[2]))
    local x = t:put(300000, 1, c[1] == "signi" and "signi_left" or "lrig_deck")
    main(t, 1)
    t:expect(t:answer(t:action(c[1] == "signi" and ACT_ABILITY or ACT_USE, x)))
    t:wait(HINT_MAIN)
    t:expect(t:is_in(h, 0, c[3]), c[1] .. " " .. c[2])
  end
end)

case("マーガレット: 상대 시그니의 ライフバースト로도 바니시되지 않는다", "WDK07-Y17, PR-388 FAQ", function(t)
  yuki(t)
  local h = t:put(Y[17], 0, "signi_center")
  t:put(Y[13], 0, "signi_left")
  t:put(t:no("WDK06-R11"), 1, "life_cloth")
  t:begin(0, PHASE_ATTACK)
  pick(t, HINT_ATTACK_SIGNI, t:cards(0, "signi_left")[1])
  pick(t, HINT_LIFEBURST, 1)
  pick(t, HINT_TARGET, h)
  t:wait(HINT_ATTACK_SIGNI)
  t:expect(t:is_in(h, 0, "signi_center"))
end)

case("プラント・アレンジ: シード를 패에 넣고 덱 위를 シード로. シード가 없어도 덱에서 낸다", "WDK07-Y20 FAQ 1·3·4", function(t)
  for _, on in ipairs{true, false} do
    yuki(t)
    local sp, h = t:put(Y[20], 0, "hand"), t:put(PL, 0, "signi_left")
    local s = on and seed(t, SPELL, "signi_center")
    local d = t:put(WHITE, 0, "main_deck")
    main(t)
    use(t, sp)
    pick(t, HINT_MODE, 0)
    pick(t, HINT_TARGET, h)
    if s then pick(t, HINT_TARGET, s) end
    zone(t)
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:seed(0, "signi_left") == d and (not s or t:is_in(s, 0, "hand")) and t:is_in(h, 0, "trash"))
  end
end)

case("プラント・アレンジ: ＜植物＞가 없으면 아무것도 하지 않는다", "WDK07-Y20 FAQ 2", function(t)
  yuki(t)
  local sp, s = t:put(Y[20], 0, "hand"), seed(t, SPELL, "signi_center")
  main(t)
  use(t, sp)
  pick(t, HINT_MODE, 0)
  pick(t, HINT_TARGET, s)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:seed(0, "signi_center") == s and t:count(0, "main_deck") == 15)
end)

-- ── エルドラ ──

case("デコレ: 패의 ＜調理＞를 ＜調理＞ 시그니에. 턴 1회. 레벨이 높아도 붙는다", "용어집: デコレ, アクセ", function(t)
  local lc = wd(t, 2)
  local h, a = t:put(CH, 0, "signi_left"), t:put(CH4, 0, "hand")
  t:put(BLUE, 0, "signi_center")
  t:put(BLUE, 0, "hand")
  main(t)
  t:expect(t:answer(t:action(ACT_ABILITY, lc)))
  t:expect(t:wait(HINT_TARGET))
  t:expect(#t:request().options == 1)
  t:expect(t:answer(h))
  t:expect(t:wait(HINT_SELECT))
  t:expect(#t:request().options == 1 and t:request().min == 0)
  t:expect(t:answer(a))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(a, 0, "signi_left") == false and t:count(0, "hand") == 1 and t:action(ACT_ABILITY, lc) == nil)
end)

case("エルドラ TYPE×Ⅳ: 에나 차지한 것이 ＜調理＞면 1장. 덱이 1장이면 뽑지 못하고 리프레시", "WDK07-E01 FAQ 3", function(t)
  for _, c in ipairs{{CH, 15, 1}, {BLUE, 15, 0}, {CH, 1, 0}} do
    wd(t, 2)
    local g = t:put(E[1], 0, "lrig_deck")
    if c[2] == 1 then
      deck(t, c[1])
      t:put(BLUE, 0, "trash")
    else
      t:put(c[1], 0, "main_deck")
    end
    t:begin(0, PHASE_GROW)
    pick(t, HINT_GROW, g)
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:count(0, "ena") == 1 and t:count(0, "hand") == c[3] and t:refreshes(0) == (c[2] == 1 and 1 or 0))
  end
end)

case("エルドラ TYPE×Ⅳ: 코인 3으로 ＜調理＞를 버려 라이프 클로스에", "WDK07-E01", function(t)
  for _, yes in ipairs{true, false} do
    local lc = wd(t)
    local h = t:put(CH, 0, "hand")
    t:add_coin(0, 3)
    main(t)
    t:expect(t:answer(t:action(ACT_ABILITY, lc, 1) or t:action(ACT_ABILITY, lc)))
    t:expect(t:wait(HINT_DISCARD))
    if yes then t:expect(t:answer(h)) else t:expect(t:answer()) end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:coins(0) == 0 and t:count(0, "life_cloth") == (yes and 6 or 5))
  end
end)

case("エルドラ 레벨 1~3", "WDK07-E02~E04", function(t)
  for _, c in ipairs{{2, 3, 2, 0, 2, 0}, {3, 4, 1, 1, 0, 1}, {4, 5, 0, 0, 1, 0}} do  -- {카드, 밑, 그로우, 코인, 결과 코인, 결과 패}
    wd(t, c[2])
    local g, h = t:put(E[c[1]], 0, "lrig_deck"), c[1] == 4 and t:put(BLUE, 0, "hand")
    t:add_coin(0, c[4])
    ena(t, c[3])
    t:begin(0, PHASE_GROW)
    pick(t, HINT_GROW, g)
    if c[3] > 0 then pay(t, c[3]) end
    if c[1] > 2 then pick(t, HINT_USE_TRIGGER, 1) end
    if h then pick(t, HINT_DISCARD, h) end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:coins(0) == c[5] and t:count(0, "hand") == c[6], c[1])
  end
end)

case("ドント・イート: 같은 시그니를 다운하고 덱 위에 둘 수 있다. 버리지 않으면 아무것도", "WDK07-E06 FAQ 1·2", function(t)
  for _, yes in ipairs{true, false} do
    wd(t)
    local a, x, h = t:put(E[6], 0, "lrig_deck"), t:put(BIG, 1, "signi_left"), t:put(CH, 0, "hand")
    ena(t, 4)
    main(t)
    use(t, a)
    pay(t, 4)
    pick(t, HINT_TARGET, x)
    pick(t, HINT_TARGET, x)
    t:expect(t:wait(HINT_DISCARD))
    if yes then t:expect(t:answer(h)) else t:expect(t:answer()) end
    t:expect(t:wait(HINT_MAIN))
    local d = t:cards(1, "main_deck")
    t:expect((d[#d] == x) == yes)
  end
end)

case("パワー・デコレート: 덱에서 2장까지 찾아 붙인다. 1체·이미 붙은 시그니여도 쓴다", "WDK07-E07 FAQ 1·2", function(t)
  wd(t)
  local a, x, y = t:put(E[7], 0, "lrig_deck"), t:put(E[11], 0, "signi_left"), t:put(E[17], 0, "signi_center")
  local p, q = t:put(CH, 0, "main_deck"), t:put(CH4, 0, "main_deck")
  main(t)
  use(t, a)
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:request().min == 0 and t:answer(x, y))
  pick(t, HINT_SELECT, p, q)
  pick(t, HINT_SELECT, x)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:power(x) == 14000 and t:count(0, "ena") == 1, "スイカアイス에 붙었다")
end)

case("キャンディ・レイン: ① 다운 ② 2장", "WDK07-E08", function(t)
  for m = 0, 1 do
    wd(t)
    local a, x = t:put(E[8], 0, "lrig_deck"), t:put(BIG, 1, "signi_left")
    ena(t, 1)
    main(t)
    use(t, a)
    pick(t, HINT_MODE, m)
    pay(t, 1)
    if m == 0 then pick(t, HINT_TARGET, x) end
    t:expect(t:wait(HINT_MAIN))
    t:expect((t:flags(x) & CF_DOWN ~= 0) == (m == 0) and t:count(0, "hand") == 2 * m)
  end
end)

case("キャンディ・レイン: ③ 스펠을 打ち消し 상대 패로. 그 턴에는 같은 이름을 쓸 수 없다", "WDK07-E08", function(t)
  wd(t)
  t:script(SPELL, [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetOperation(function(e,tp) Duel.Draw(tp,3) end)
  c:RegisterEffect(e1)
end]])
  local a, s, o = t:put(E[8], 0, "lrig_deck"), t:put(SPELL, 1, "hand"), t:put(E[20], 1, "hand")
  ena(t, 1)
  main(t, 1)
  use(t, s)
  t:expect(t:wait(HINT_CUTIN))
  use(t, a)
  pick(t, HINT_MODE, 2)
  pay(t, 1)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(s, 1, "hand") and t:count(1, "hand") == 2, "드로는 없다")
  t:expect(t:action(ACT_USE, s) == nil and t:action(ACT_USE, o) ~= nil)
end)

case("イベリコーナII世: 트래시의 청 3장까지. 키를 놓고 레벨만큼 뽑고 뽑은 만큼 버린다", "WDK07-E09 FAQ 1·2", function(t)
  for _, n in ipairs{15, 2} do
    wd(t)
    local k, p = t:put(E[9], 0, "lrig_deck"), t:put(BLUE, 0, "trash")
    t:put(OPP, 0, "trash")
    t:add_coin(0, 1)
    main(t)
    t:expect(t:answer(t:action(ACT_KEY, k)))
    t:expect(t:wait(HINT_TARGET))
    t:expect(#t:request().options == 1 and t:request().min == 0)
    t:expect(t:answer(p))
    t:expect(t:wait(HINT_MAIN))
    for i, c in ipairs(t:cards(0, "main_deck")) do if i > n then t:move(c, 0, "exclude") end end
    t:expect(t:answer(t:action(ACT_ABILITY, k)))
    t:expect(t:wait(HINT_DISCARD))
    local m = math.min(4, n)
    t:expect(t:request().min == m and t:count(0, "hand") == 1 + m and t:refreshes(0) == 0)
    t:expect(t:answer(table.unpack(t:request().options, 1, m)))
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:count(0, "hand") == 1 and t:is_in(k, 0, "lrig_trash") and t:refreshes(0) == (n == 2 and 1 or 0))
  end
end)

case("ポッピンアイス: 트래시의 ＜調理＞를 붙이면 ＋2000", "WDK07-E11 FAQ 2", function(t)
  wd(t)
  local h, a = t:put(E[11], 0, "hand"), t:put(CH, 0, "trash")
  ena(t, 1)
  main(t)
  play(t, h)
  pick(t, HINT_USE_TRIGGER, 1)
  pay(t, 1)
  pick(t, HINT_TARGET, a)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:power(h) == 14000)
end)

case("ポッピンアイス: LB 1장 뽑고 덱 위가 ＜調理＞면 패에", "WDK07-E11", function(t)
  for _, c in ipairs{{CH, 2}, {BLUE, 1}} do
    wd(t)
    t:put(E[11], 0, "life_cloth")
    local x = t:put(BIG, 1, "signi_left")
    t:put(c[1], 0, "main_deck")
    t:put(BLUE, 0, "main_deck")
    t:begin(1, PHASE_ATTACK)
    pick(t, HINT_ATTACK_SIGNI, x)
    pick(t, HINT_LIFEBURST, 1)
    t:wait(HINT_ATTACK_LRIG)
    t:expect(t:count(0, "hand") == c[2])
  end
end)

case("ウジキントキ: 2장 뽑고 패 2장을 에나에", "WDK07-E12", function(t)
  wd(t)
  local h = t:put(E[12], 0, "hand")
  ena(t, 2)
  main(t)
  play(t, h)
  pick(t, HINT_USE_TRIGGER, 1)
  pay(t, 2)
  t:expect(t:wait(HINT_SELECT))
  t:expect(t:answer(table.unpack(t:request().options, 1, 2)))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "hand") == 0 and t:count(0, "ena") == 2)
end)

case("ポッキン: 턴 종료 시 【アクセ】가 붙어 있으면 1장", "WDK07-E13 FAQ 2", function(t)
  for _, on in ipairs{true, false} do
    wd(t)
    local h = t:put(E[13], 0, "signi_left")
    if on then t:attach(t:put(CH, 0, "hand"), h, true) end
    t:begin(0, PHASE_ATTACK)
    t:wait(HINT_MAIN)
    t:expect(t:count(0, "hand") == (on and 1 or 0))
  end
end)

case("ラムレーズン: 붙은 시그니가 어택하면 자기 레벨마다 −2000", "WDK07-E14 FAQ 2", function(t)
  wd(t)
  local h, x = t:put(E[11], 0, "signi_left"), t:put(BIG, 1, "signi_center")
  t:attach(t:put(E[14], 0, "hand"), h, true)
  t:begin(0, PHASE_ATTACK)
  pick(t, HINT_ATTACK_SIGNI, h)
  pick(t, HINT_TARGET, x)
  t:wait(HINT_ATTACK_LRIG)
  t:expect(t:power(x) == 7000)
end)

case("コロアイス: 덱 위가 ＜調理＞면 자신의 【アクセ】로, 아니면 그대로", "WDK07-E15", function(t)
  for _, c in ipairs{{CH, 14}, {BLUE, 16}} do
    wd(t)
    local h = t:put(E[15], 0, "hand")
    local d = t:put(c[1], 0, "main_deck")
    main(t)
    play(t, h)
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(d, 0, "main_deck") == (c[1] == BLUE))
  end
end)

case("SWEET CHARGE: 놓고 덱에서 찾아 붙인다. ＜調理＞가 1체뿐이면 찾은 카드는 덱으로", "WDK07-E20 FAQ 1·3", function(t)
  for n = 2, 1, -1 do
    wd(t)
    local sp, h = t:put(E[20], 0, "hand"), t:put(CH, 0, "signi_left")
    local x = n == 2 and t:put(E[11], 0, "signi_center") or h
    local d = t:put(CH, 0, "main_deck")
    main(t)
    use(t, sp)
    pick(t, HINT_MODE, 0)
    pick(t, HINT_TARGET, h)
    pick(t, HINT_TARGET, x)
    pick(t, HINT_SELECT, d)
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(h, 0, "trash") and t:is_in(d, 0, "main_deck") == (n == 1))
    if n == 2 then t:expect(t:power(x) == 14000) end
  end
end)
