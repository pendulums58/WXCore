-- WD17 リル 구축덱 카드 스크립트 케이스 + 라이즈 룰. 근거는 카드별 FAQ(cards.json)·용어집: ライズ

local N = {}
local BUYU, RED, OPP, BIG = 200000, 201000, 101000, 102000

local function wd(t, center)
  t:start{db = true, seed = 1}
  for i = 1, 18 do
    local no = ("%03d"):format(i)
    N[no] = t:no("WD17-" .. no)
  end
  t:card{cid = BUYU, power = 2000, level = 2, classes = {"精像：武勇"}, color = COLOR_RED}
  t:card{cid = RED, power = 1000, level = 1, classes = {"精羅：鉱石"}, color = COLOR_RED}
  t:signi(OPP, 1000, COLOR_GREEN, 1)
  t:signi(BIG, 15000, COLOR_GREEN, 3)
  t:fill(RED, 0, "main_deck", 10)
  t:fill(OPP, 1, "main_deck", 10)
  t:fill(RED, 0, "life_cloth", 5)
  t:fill(OPP, 1, "life_cloth", 5)
  t:put(N["001"], 1, "lrig_center")
  return t:put(N[center or "001"], 0, "lrig_center")
end

local function main(t, p)
  t:begin(p or 0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
end

local function has(list, x)
  for _, v in ipairs(list) do if v == x then return true end end
  return false
end

local function ena(t, n)
  for _ = 1, n do t:put(RED, 0, "ena") end
end

local function pay(t, n)
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:request().min == n, "코스트 " .. n)
  t:expect(t:answer(table.unpack(t:cards(0, "ena"), 1, n)))
end

local function play(t, c, z) t:expect(t:answer(t:action(ACT_PLAY, c, z))) end

-- ── 라이즈 룰 ──

case("라이즈: 조건에 맞는 자기 시그니 위에만 낸다. 빈 존에는 낼 수 없다", "용어집: ライズ", function(t)
  wd(t)
  local g = t:put(N["009"], 0, "hand")
  local b = t:put(BUYU, 0, "signi_left")
  t:put(RED, 0, "signi_center")
  main(t)
  t:expect(t:action(ACT_PLAY, g, "signi_center") == nil and t:action(ACT_PLAY, g, "signi_right") == nil)
  play(t, g, "signi_left")
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(g, 0, "signi_left") and t:count(0, "signi_left") == 1)
  t:expect(has(t:under(g), b) and #t:under(g) == 1)
end)

case("라이즈: 밑의 시그니는 리미트에 들지 않는다", "WX15-043 FAQ, 용어집: ライズ", function(t)
  local c = wd(t)
  t:single(c, EFFECT_UPDATE_LIMIT, -6, 0)  -- 리미트 5
  local g = t:put(N["009"], 0, "hand")
  t:put(BUYU, 0, "signi_left")
  t:put(RED, 0, "signi_center")
  main(t)
  t:expect(t:action(ACT_PLAY, g, "signi_left") ~= nil, "4 + 1 = 5")
  c = wd(t)
  t:single(c, EFFECT_UPDATE_LIMIT, -6, 0)
  g = t:put(N["009"], 0, "hand")
  t:put(BUYU, 0, "signi_left")
  t:put(BUYU, 0, "signi_center")
  main(t)
  t:expect(t:action(ACT_PLAY, g, "signi_left") == nil, "4 + 2 = 6")
end)

case("라이즈: 다운·동결·파워 수정·부여를 이어받지 않는다", "용어집: ライズ, PR-308 FAQ", function(t)
  wd(t)
  local g = t:put(N["009"], 0, "hand")
  local b = t:put(BUYU, 0, "signi_left")
  t:set_flags(b, CF_DOWN | CF_FROZEN)
  t:single(b, EFFECT_UPDATE_POWER, 3000, 0)
  t:grant(b, EFFECT_LANCER, 0, 0)
  main(t)
  play(t, g, "signi_left")
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:flags(g) == 0 and t:power(g) == 12000 and not t:keyword(g, EFFECT_LANCER))
end)

case("라이즈: 밑이 된 시그니의 「場を離れたとき」는 트리거하지 않고, 【常】도 없다", "용어집: ライズ", function(t)
  wd(t)
  t:script(300000, [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetCode(EVENT_LEAVE_FIELD)
  e1:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetCode(EFFECT_UPDATE_POWER)
  e2:SetRange(LOCATION_SZONE)
  e2:SetTargetRange(LOCATION_SZONE,0)
  e2:SetValue(1000)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e3:SetCode(EVENT_ON_PLAY)
  e3:SetRange(LOCATION_SZONE)
  e3:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e3)
end]])
  t:card{cid = 300000, power = 1000, level = 1, classes = {"精像：武勇"}, color = COLOR_RED}
  local g = t:put(N["009"], 0, "hand")
  t:put(300000, 0, "signi_left")
  main(t)
  play(t, g, "signi_left")
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "hand") == 0 and t:power(g) == 12000)
end)

case("라이즈: 장을 떠나면 밑의 카드는 룰 처리로 트래시", "용어집: ライズ, ルール処理 3", function(t)
  wd(t)
  local g = t:put(N["009"], 0, "hand")
  local b = t:put(BUYU, 0, "signi_left")
  main(t)
  play(t, g, "signi_left")
  t:expect(t:wait(HINT_MAIN))
  t:single(g, EFFECT_UPDATE_POWER, -20000, 1)
  t:expect(t:answer(t:action(ACT_END)))
  t:wait(HINT_ATTACK_LRIG)
  t:expect(t:is_in(g, 0, "ena") and t:is_in(b, 0, "trash"))
end)

case("라이즈: 라이즈 시그니 위에 또 라이즈하면 밑의 카드가 모두 밑에", "용어집: ライズ, WDK15-011 FAQ", function(t)
  wd(t)
  local g1, g2 = t:put(N["009"], 0, "hand"), t:put(N["009"], 0, "hand")
  local b = t:put(BUYU, 0, "signi_left")
  main(t)
  play(t, g1, "signi_left")
  t:expect(t:wait(HINT_MAIN))
  play(t, g2, "signi_left")
  t:expect(t:wait(HINT_MAIN))
  local u = t:under(g2)
  t:expect(#u == 2 and has(u, b) and has(u, g1))
end)

case("라이즈: 효과로 낼 때도 조건을 채워야 한다", "용어집: ライズ, WX15-001 FAQ", function(t)
  for _, ok in ipairs{true, false} do
    wd(t)
    t:script(301000, [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetRange(LOCATION_SZONE)
  e1:SetOperation(function(e,tp)
    Duel.PutOnField(Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_TRASH,0,nil):GetFirst(),tp)
  end)
  c:RegisterEffect(e1)
end]])
    t:card{cid = 301000, power = 1000, level = 1, color = COLOR_RED}
    local s = t:put(301000, 0, "signi_center")
    local g = t:put(N["009"], 0, "trash")
    local b = ok and t:put(BUYU, 0, "signi_left")
    main(t)
    t:expect(t:answer(t:action(ACT_ABILITY, s)))
    if ok then
      t:expect(t:wait(HINT_ZONE))
      t:expect(#t:request().options == 1)
      t:expect(t:answer(t:request().options[1]))
    end
    t:expect(t:wait(HINT_MAIN))
    t:expect(ok and has(t:under(g), b) or not ok and t:is_in(g, 0, "trash"))
  end
end)

case("라이즈: 「可能ならば正面に」는 라이즈할 수 있는 정면 존이 있을 때만", "WD07-009 FAQ 1, 용어집: ライズ", function(t)
  wd(t)
  t:move(t:center(1), 1, "exclude")
  t:put(t:no("WD07-001"), 1, "lrig_center")
  t:put(t:no("WD07-009"), 1, "signi_left")  -- 정면 = 내 오른쪽
  local g = t:put(N["009"], 0, "hand")
  t:put(BUYU, 0, "signi_left")
  main(t)
  t:expect(t:action(ACT_PLAY, g, "signi_left") ~= nil)
  wd(t)
  t:move(t:center(1), 1, "exclude")
  t:put(t:no("WD07-001"), 1, "lrig_center")
  t:put(t:no("WD07-009"), 1, "signi_left")
  g = t:put(N["009"], 0, "hand")
  t:put(BUYU, 0, "signi_left")
  t:put(BUYU, 0, "signi_right")
  main(t)
  t:expect(t:action(ACT_PLAY, g, "signi_left") == nil and t:action(ACT_PLAY, g, "signi_right") ~= nil)
end)

-- ── 카드 ──

case("リル: 【出】《コイン》으로 12000 이하를 바니시", "WD17-001 FAQ 1", function(t)
  for n = 0, 1 do
    wd(t, "002")
    local g = t:put(N["001"], 0, "lrig_deck")
    local x = t:put(OPP, 1, "signi_left")
    t:add_coin(0, n)
    ena(t, 3)
    t:begin(0, PHASE_GROW)
    t:expect(t:wait(HINT_GROW))
    t:expect(t:answer(g))
    pay(t, 3)
    if n == 1 then
      t:expect(t:wait(HINT_USE_TRIGGER))
      t:expect(t:answer(1))
      t:expect(t:wait(HINT_TARGET))
      t:expect(t:answer(x))
    end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(x, 1, n == 1 and "ena" or "signi_left") and t:coins(0) == 0)
  end
end)

case("リル: ゴクウ가 정면을 바니시하면 업해 다시 어택한다", "WD17-009 FAQ 3·4", function(t)
  local c = wd(t)
  local g = t:put(N["009"], 0, "signi_left")
  t:single(g, EFFECT_UPDATE_POWER, 3000, 0)
  local x = t:put(BIG, 1, "signi_right")
  ena(t, 3)
  main(t)
  t:expect(t:answer(t:action(ACT_ABILITY, c)))
  pay(t, 3)
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(g))
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:answer(g))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(x))
  t:expect(t:wait(HINT_ATTACK_SIGNI), "업했다")
  t:expect(t:is_in(x, 1, "ena") and t:count(1, "life_cloth") == 4)
  t:expect(t:answer(g))
  t:expect(t:wait(HINT_ATTACK_LRIG))
  t:expect(t:count(1, "life_cloth") == 3)
end)

case("リル: 정면이 아닌 시그니를 바니시하면 업하지 않는다", "WD17-001", function(t)
  wd(t)
  t:script(302000, [[
local s,id=GetID()
function s.initial_effect(c)
  aux.AddRise(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp) Duel.Banish(Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil)) end)
  c:RegisterEffect(e1)
end]])
  t:card{cid = 302000, power = 1000, level = 1, color = COLOR_RED}
  local c = t:center(0)
  local g = t:put(302000, 0, "signi_left")
  local x = t:put(BIG, 1, "signi_left")
  ena(t, 3)
  main(t)
  t:expect(t:answer(t:action(ACT_ABILITY, c)))
  pay(t, 3)
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(g))
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:answer(g))
  t:wait(HINT_ATTACK_LRIG)
  t:expect(t:is_in(x, 1, "ena") and t:flags(g) & CF_DOWN ~= 0)
end)

case("リル 레벨 1~3: 코인을 내고 얻는다", "WD17-002~004 FAQ", function(t)
  for _, c in ipairs{{"003", "002", 2, 1, 0, 2}, {"004", "003", 1, 0, 0, 1}, {"005", "004", 0, 0, 1, 0}} do
    wd(t, c[1])
    local g = t:put(N[c[2]], 0, "lrig_deck")
    t:add_coin(0, c[5])
    ena(t, c[3] + c[4])
    t:begin(0, PHASE_GROW)
    t:expect(t:wait(HINT_GROW))
    t:expect(t:answer(g))
    if c[3] > 0 then pay(t, c[3]) end
    if c[4] + c[5] > 0 then
      t:expect(t:wait(HINT_USE_TRIGGER))
      t:expect(t:answer(1))
      if c[4] > 0 then pay(t, c[4]) end
    end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:coins(0) == c[6] and t:count(0, "hand") == c[5])
  end
end)

case("孤立無炎: ベット하면 에나 없이 전부 바니시", "WD17-006 FAQ 1", function(t)
  wd(t)
  local a = t:put(N["006"], 0, "lrig_deck")
  local x, y = t:put(BIG, 1, "signi_left"), t:put(OPP, 1, "signi_center")
  main(t)
  t:expect(t:action(ACT_USE, a) == nil)
  wd(t)
  a = t:put(N["006"], 0, "lrig_deck")
  x, y = t:put(BIG, 1, "signi_left"), t:put(OPP, 1, "signi_center")
  t:add_coin(0, 2)
  main(t)
  t:expect(t:answer(t:action(ACT_USE, a)))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(x, 1, "ena") and t:is_in(y, 1, "ena") and t:coins(0) == 0)
end)

case("一騎当閃: ベット하면 20000 이하", "WD17-007", function(t)
  for bet = 0, 1 do
    wd(t)
    local a = t:put(N["007"], 0, "lrig_deck")
    local x, y = t:put(BIG, 1, "signi_left"), t:put(OPP, 1, "signi_center")
    t:add_coin(0, 1)
    ena(t, 2)
    main(t)
    t:expect(t:answer(t:action(ACT_USE, a)))
    t:expect(t:wait(HINT_BET))
    t:expect(t:answer(bet))
    pay(t, 2)
    t:expect(t:wait(HINT_TARGET))
    t:expect(has(t:request().options, x) == (bet == 1))
    t:expect(t:answer(bet == 1 and x or y))
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(bet == 1 and x or y, 1, "ena"))
  end
end)

case("瞬息爆変: 다운으로 나와 턴 종료 시 트래시. 라이즈하면 아무 일도 없다", "WD17-008 FAQ 1", function(t)
  for _, rise in ipairs{false, true} do
    wd(t)
    local a = t:put(N["008"], 0, "lrig_deck")
    local d = t:put(BUYU, 0, "main_deck")
    local g = t:put(N["009"], 0, "hand")
    main(t)
    t:expect(t:answer(t:action(ACT_USE, a)))
    t:expect(t:wait(HINT_SELECT))
    t:expect(t:answer(d))
    t:expect(t:wait(HINT_ZONE))
    t:expect(t:answer(t:request().options[1]))
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:flags(d) & CF_DOWN ~= 0)
    if rise then
      play(t, g, (t:at(d)))
      t:expect(t:wait(HINT_MAIN))
    end
    t:expect(t:answer(t:action(ACT_END)))
    while t:wait(HINT_MAIN) and t:turn_player() == 0 do t:answer(t:action(ACT_END)) end
    if rise then
      t:expect(has(t:under(g), d) and not t:is_in(g, 0, "trash"))
    else
      t:expect(t:is_in(d, 0, "trash"))
    end
  end
end)

case("ゴクウ: 파워가 15000 미만이면 어택해도 바니시하지 않는다. 【起】로 ＋3000", "WD17-009", function(t)
  for n = 0, 1 do
    wd(t)
    local g = t:put(N["009"], 0, "signi_left")
    local x = t:put(BIG, 1, "signi_right")
    local y = t:put(OPP, 1, "signi_center")
    ena(t, n)
    main(t)
    if n == 1 then
      t:expect(t:answer(t:action(ACT_ABILITY, g)))
      pay(t, 1)
      t:expect(t:wait(HINT_MAIN))
    end
    t:expect(t:power(g) == 12000 + 3000 * n)
    t:expect(t:wait(HINT_ATTACK_SIGNI))
    t:expect(t:answer(g))
    t:expect(t:wait(HINT_TARGET))
    t:expect(#t:request().options == 1 and t:request().options[1] == x, "정면만")
    t:expect(t:answer(x))
    t:expect(t:wait(HINT_ATTACK_LRIG))
    t:expect(t:is_in(x, 1, n == 1 and "ena" or "signi_right"))
    t:expect(t:count(1, "life_cloth") == 5 - n)
  end
end)

case("ゴクウ: 라이프 버스트. 장에 ＜武勇＞가 있으면 15000 이하", "WD17-009", function(t)
  for _, buyu in ipairs{false, true} do
    wd(t)
    t:put(N["009"], 0, "life_cloth")
    if buyu then t:put(BUYU, 0, "signi_center") end
    local a = t:put(BIG, 1, "signi_left")
    t:begin(1, PHASE_ATTACK)
    t:expect(t:wait(HINT_ATTACK_SIGNI))
    t:expect(t:answer(a))
    t:expect(t:wait(HINT_LIFEBURST))
    t:expect(t:answer(1))
    if buyu then
      t:expect(t:wait(HINT_TARGET))
      t:expect(t:answer(a))
    end
    t:wait(HINT_ATTACK_LRIG)
    t:expect(t:is_in(a, 1, buyu and "ena" or "signi_left"))
  end
end)

case("サンゾウ: 라이즈되면 위의 시그니 ＋3000. 밑에 있는 동안은 다시 트리거하지 않는다", "WD17-011, WX15-043 FAQ", function(t)
  wd(t)
  local g1, g2 = t:put(N["009"], 0, "hand"), t:put(N["009"], 0, "hand")
  t:put(N["011"], 0, "signi_left")
  main(t)
  play(t, g1, "signi_left")
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:power(g1) == 15000)
  play(t, g2, "signi_left")
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:power(g2) == 12000)
end)

case("サンゾウ: 【出】《赤》로 《ライズアイコン》을 가진 시그니를 찾는다", "WD17-011", function(t)
  wd(t)
  local s = t:put(N["011"], 0, "hand")
  local g, b = t:put(N["009"], 0, "main_deck"), t:put(BUYU, 0, "main_deck")
  ena(t, 1)
  main(t)
  play(t, s, "signi_left")
  t:expect(t:wait(HINT_USE_TRIGGER))
  t:expect(t:answer(1))
  pay(t, 1)
  t:expect(t:wait(HINT_SELECT))
  t:expect(has(t:request().options, g) and not has(t:request().options, b))
end)

case("ハッカイ·サゴジョ: 어택하면 ＋3000, ＜武勇＞ 3체면 ＋5000", "WD17-013, WD17-015", function(t)
  for _, c in ipairs{{"013", 5000}, {"015", 2000}} do
    for n = 1, 2 do
      wd(t)
      local h = t:put(N[c[1]], 0, "signi_left")
      t:put(BUYU, 0, "signi_center")
      if n == 2 then t:put(BUYU, 0, "signi_right") end
      t:begin(0, PHASE_ATTACK)
      t:expect(t:wait(HINT_ATTACK_SIGNI))
      t:expect(t:answer(h))
      t:wait(HINT_ATTACK_LRIG)
      t:expect(t:power(h) == c[2] + (n == 2 and 5000 or 3000))
    end
  end
end)

case("神流の一振: ① 라이즈가 아닌 ＜武勇＞를 바니시하고 라이즈 ＜武勇＞를 찾는다", "WD17-018", function(t)
  wd(t)
  local sp = t:put(N["018"], 0, "hand")
  local b, r = t:put(BUYU, 0, "signi_left"), t:put(N["009"], 0, "signi_center")
  local g = t:put(N["009"], 0, "main_deck")
  main(t)
  t:expect(t:answer(t:action(ACT_USE, sp)))
  t:expect(t:wait(HINT_MODE))
  t:expect(t:answer(0))
  t:expect(t:wait(HINT_TARGET))
  t:expect(#t:request().options == 1)
  t:expect(t:answer(b))
  t:expect(t:wait(HINT_SELECT))
  t:expect(t:answer(g))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(b, 0, "ena") and t:is_in(g, 0, "hand"))
end)

case("神流の一振: ② 컷인으로 내 시그니가 바니시되면 상대 시그니도 바니시하지 않는다", "WD17-018 FAQ 1", function(t)
  for _, cut in ipairs{false, true} do
    wd(t)
    local sp = t:put(N["018"], 0, "hand")
    local r, x = t:put(N["009"], 0, "signi_center"), t:put(OPP, 1, "signi_left")
    t:put(BIG, 1, "signi_center")
    main(t)
    t:expect(t:answer(t:action(ACT_USE, sp)))
    t:expect(t:wait(HINT_MODE))
    t:expect(t:answer(1))
    t:expect(t:wait(HINT_TARGET))
    t:expect(t:answer(r))
    t:expect(t:wait(HINT_TARGET))
    t:expect(#t:request().options == 1, "12000 이하")
    t:expect(t:answer(x))
    if cut then
      t:expect(t:wait(HINT_CUTIN))
      t:move(r, 0, "ena")
    end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(x, 1, cut and "signi_left" or "ena"))
  end
end)
