-- WD20 ママ 구축덱 카드 스크립트 케이스. 근거는 카드별 FAQ(cards.json)

local N = {}
local E = {}  -- ＜英知＞ 레벨별
local GREEN, OPP, BIG = 201000, 101000, 102000

local function wd(t, center)
  t:start{db = true, seed = 1}
  for i = 1, 18 do
    local no = ("%03d"):format(i)
    N[no] = t:no("WD20-" .. no)
  end
  for lv = 1, 5 do
    E[lv] = 200000 + lv
    t:card{cid = E[lv], power = 4000, level = lv, classes = {"精像：英知"}, color = COLOR_GREEN}
  end
  t:signi(GREEN, 1000, COLOR_GREEN, 1)
  t:signi(OPP, 1000, COLOR_RED, 1)
  t:signi(BIG, 15000, COLOR_RED, 3)
  t:fill(GREEN, 0, "main_deck", 12)
  t:fill(OPP, 1, "main_deck", 12)
  t:fill(GREEN, 0, "life_cloth", 5)
  t:fill(OPP, 1, "life_cloth", 5)
  t:put(N["001"], 1, "lrig_center")
  return t:put(N[center or "001"], 0, "lrig_center")
end

local function main(t, p)
  t:begin(p or 0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
end

local function ena(t, n)
  for _ = 1, n do t:put(GREEN, 0, "ena") end
end

local function pay(t, n)
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:request().min == n, "코스트 " .. n)
  t:expect(t:answer(table.unpack(t:cards(0, "ena"), 1, n)))
end

local function use(t, c) t:expect(t:answer(t:action(ACT_USE, c))) end

local function bet(t, yes)
  t:expect(t:wait(HINT_BET))
  t:expect(t:answer(yes))
end

local function attack(t, c)
  t:begin(0, PHASE_ATTACK)
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:answer(c))
end

-- ── 루리그 ──

case("ママ♥４: 【出】으로 라이프를 더하면 【自】도 발동. 《緑》은 한 번만", "WD20-001 FAQ 1·2", function(t)
  wd(t, "002")
  local g = t:put(N["001"], 0, "lrig_deck")
  local x, y = t:put(BIG, 1, "signi_left"), t:put(BIG, 1, "signi_center")
  t:add_coin(0, 3)
  ena(t, 5)
  t:begin(0, PHASE_GROW)
  t:expect(t:wait(HINT_GROW))
  t:expect(t:answer(g))
  pay(t, 3)
  t:expect(t:wait(HINT_USE_TRIGGER))
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(x))
  t:expect(t:wait(HINT_SCRIPT))
  t:expect(t:answer(1))
  pay(t, 1)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "life_cloth") == 6 and t:coins(0) == 0)
  t:expect(t:is_in(x, 1, "ena") and t:is_in(y, 1, "signi_center"))
end)

case("ママ♥４: 상대 턴에는 발동하지 않는다", "WD20-001(あなたのターンの間)", function(t)
  wd(t)
  t:put(OPP, 1, "signi_left")
  t:add_coin(0, 2)
  local a = t:put(N["007"], 0, "lrig_deck")
  t:begin(1, PHASE_ATTACK)
  t:expect(t:wait(HINT_DEFENSE))
  use(t, a)
  t:wait(HINT_ATTACK_SIGNI)
  t:expect(t:count(0, "life_cloth") == 6 and not t:saw(HINT_TARGET))
end)

case("ママ 레벨 1~3: 코인을 얻고 쓴다", "WD20-002~004 FAQ", function(t)
  -- {그로우할 카드, 지금 루리그, 그로우 코스트, 【出】 에나, 【出】 코인, 남는 코인}
  for _, c in ipairs{{"002", "003", 2, 2, 0, 2}, {"003", "004", 1, 0, 0, 1}, {"004", "005", 0, 0, 2, 0}} do
    wd(t, c[2])
    local g = t:put(N[c[1]], 0, "lrig_deck")
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
    if c[5] > 0 then
      t:expect(t:wait(HINT_SELECT))
      t:expect(t:answer(t:cards(0, "hand")[1]))
    end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:coins(0) == c[6] and t:count(0, "hand") == 0 and t:count(0, "ena") == c[5] // 2, c[1])
  end
end)

-- ── 아츠 ──

case("全知全能: 2체·2장 대상, 상대는 2장 버리고(모자라면 있는 만큼) 라이프를 더한다", "WD20-006 FAQ 3", function(t)
  for _, n in ipairs{2, 1} do
    wd(t)
    local a = t:put(N["006"], 0, "lrig_deck")
    ena(t, 8)
    local x = t:put(OPP, 1, "signi_left")
    local y = n == 2 and t:put(BIG, 1, "signi_center")
    local e1, e2 = t:put(OPP, 1, "ena"), t:put(OPP, 1, "ena")
    t:fill(OPP, 1, "hand", n)
    main(t)
    use(t, a)
    pay(t, 8)
    if n == 2 then
      t:expect(t:wait(HINT_TARGET))
      t:expect(t:request().min == 2)
      t:expect(t:answer(x, y))
    end
    t:expect(t:wait(HINT_TARGET))
    t:expect(t:answer(e1, e2))
    if n == 2 then
      t:expect(t:wait(HINT_DISCARD))
      t:expect(t:request().player == 1 and t:request().min == 2)
      t:expect(t:answer(table.unpack(t:cards(1, "hand"))))
    else
      t:expect(t:wait(HINT_DISCARD))
      t:expect(t:answer(t:cards(1, "hand")[1]))
    end
    -- 라이프가 더해져 ママ♥４가 트리거한다
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(x, 1, n == 2 and "trash" or "signi_left"), "1체뿐이면 대상이 아니다")
    t:expect(t:is_in(e1, 1, "trash") and t:count(1, "hand") == 0 and t:count(0, "life_cloth") == 6)
  end
end)

case("全知全能: 상대 턴에 베트하지 않고 쓰면 다음 내 턴을 건너뛴다", "WD20-006 FAQ 1·2", function(t)
  for _, c in ipairs{{1, 0, 1}, {1, 1, 0}, {0, 0, 1}} do  -- {쓰는 턴, 베트, 그 턴 다음 턴의 플레이어}
    wd(t)
    local a = t:put(N["006"], 0, "lrig_deck")
    t:add_coin(0, 2)
    ena(t, 8)
    t:begin(c[1], PHASE_ATTACK)
    t:expect(t:wait(c[1] == 1 and HINT_DEFENSE or HINT_PRE_ATTACK))
    use(t, a)
    bet(t, c[2])
    pay(t, 8)
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:turn_player() == c[3], "턴 " .. c[1] .. " 베트 " .. c[2])
  end
end)

case("全知全能: 건너뛰는 것은 한 번뿐이다", "WD20-006(次のあなたのターン)", function(t)
  wd(t)
  local a = t:put(N["006"], 0, "lrig_deck")
  ena(t, 8)
  t:begin(1, PHASE_ATTACK)
  t:expect(t:wait(HINT_DEFENSE))
  use(t, a)
  pay(t, 8)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:turn_player() == 1)
  t:expect(t:answer(t:action(ACT_END)))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:turn_player() == 0)
end)

case("生生流転: 베트하면 에나 없이 라이프를 더한다", "WD20-007 FAQ 1", function(t)
  for _, yes in ipairs{0, 1} do
    wd(t, "002")
    local a = t:put(N["007"], 0, "lrig_deck")
    t:add_coin(0, 2)
    ena(t, 4)
    main(t)
    use(t, a)
    bet(t, yes)
    if yes == 0 then pay(t, 4) end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:count(0, "life_cloth") == 6 and t:coins(0) == 2 - 2 * yes and t:count(0, "ena") == 4 * yes)
  end
end)

case("母性本能: 각자 장수를 정한다. 아츠를 쓴 턴에는 쓸 수 없다", "WD20-008 FAQ 1·2", function(t)
  wd(t)
  local a, b = t:put(N["008"], 0, "lrig_deck"), t:put(N["008"], 0, "lrig_deck")
  ena(t, 2)
  main(t)
  use(t, a)
  pay(t, 1)
  t:expect(t:wait(HINT_DECLARE))
  t:expect(t:request().player == 0)
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_DECLARE))
  t:expect(t:request().player == 1)
  t:expect(t:answer(3))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "ena") == 2 and t:count(1, "ena") == 3)
  t:expect(t:action(ACT_USE, b) == nil)
end)

-- ── 시그니 ──

case("コンパス: 英知=7일 때만 어택하면 에나 2장", "WD20-009 FAQ 1", function(t)
  for _, c in ipairs{{3, 2}, {2, 0}} do
    wd(t)
    local h = t:put(N["009"], 0, "signi_left")
    t:put(E[c[1]], 0, "signi_center")
    attack(t, h)
    t:wait(HINT_ATTACK_LRIG)
    t:expect(t:count(0, "ena") == c[2])
  end
end)

case("コンパス: 英知=10이면 정면과 옆 존에 같이 어택한다(패턴 A~D)", "WD20-009 FAQ 2", function(t)
  for _, c in ipairs{{true, true, 0}, {true, false, 0}, {false, true, 1}, {false, false, 1}} do
    wd(t)
    local h = t:put(N["009"], 0, "signi_left")
    t:put(E[3], 0, "signi_center")
    t:put(E[3], 0, "signi_right")
    t:begin(0, PHASE_ATTACK)
    t:expect(t:wait(HINT_ATTACK_SIGNI))
    -- 왼쪽 시그니의 정면은 상대 오른쪽 존이고, 옆은 가운데 존 하나뿐이다
    local f = c[1] and t:put(OPP, 1, "signi_right")
    local s = c[2] and t:put(OPP, 1, "signi_center")
    t:expect(t:answer(h))
    t:expect(t:wait(HINT_SCRIPT))
    t:expect(t:answer(1))
    t:expect(t:wait(HINT_ATTACK_SIGNI))
    if f then t:expect(t:is_in(f, 1, "ena"), "정면") end
    if s then t:expect(t:is_in(s, 1, "ena"), "옆") end
    t:expect(t:count(1, "life_cloth") == 5 - c[3], "데미지")
  end
end)

case("コンパス: 어택하지 않기로 하거나 英知=10이 아니면 정면만", "WD20-009", function(t)
  for _, on in ipairs{true, false} do
    wd(t)
    local h = t:put(N["009"], 0, "signi_left")
    t:put(E[3], 0, "signi_center")
    t:put(E[on and 3 or 2], 0, "signi_right")
    local f, s = t:put(OPP, 1, "signi_right"), t:put(OPP, 1, "signi_center")
    attack(t, h)
    if on then
      t:expect(t:wait(HINT_SCRIPT))
      t:expect(t:answer(0))
    end
    t:expect(t:wait(HINT_ATTACK_SIGNI))
    t:expect(not (not on and t:saw(HINT_SCRIPT)))
    t:expect(t:is_in(f, 1, "ena") and t:is_in(s, 1, "signi_center"))
  end
end)

case("コンパス: 【ランサー】로 2체를 바니시하면 2장 크러시", "WD20-009 FAQ 3", function(t)
  wd(t)
  local h = t:put(N["009"], 0, "signi_left")
  t:grant(h, EFFECT_LANCER, 0, 0)
  t:put(E[3], 0, "signi_center")
  t:put(E[3], 0, "signi_right")
  t:put(OPP, 1, "signi_right")
  t:put(OPP, 1, "signi_center")
  attack(t, h)
  t:expect(t:wait(HINT_SCRIPT))
  t:expect(t:answer(1))
  if t:wait(HINT_TRIGGER_ORDER) then t:answer(table.unpack(t:request().options)) end
  t:wait(HINT_ATTACK_SIGNI)
  t:expect(t:count(1, "life_cloth") == 3)
end)

case("コンパス: 가운데에 있으면 옆 존을 고른다", "WD20-009(その隣のシグニゾーン１つ)", function(t)
  wd(t)
  local h = t:put(N["009"], 0, "signi_center")
  t:put(E[3], 0, "signi_left")
  t:put(E[3], 0, "signi_right")
  local l, r = t:put(OPP, 1, "signi_left"), t:put(OPP, 1, "signi_right")
  attack(t, h)
  t:expect(t:wait(HINT_SCRIPT))
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_ZONE))
  t:expect(#t:request().options == 2)
  t:expect(t:answer(t:request().options[1]))
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:is_in(l, 1, "ena") ~= t:is_in(r, 1, "ena"), "한쪽만")
  t:expect(t:count(1, "life_cloth") == 4, "정면이 비어 데미지")
end)

case("コンパス: 【起】 12000 이상 바니시", "WD20-009", function(t)
  wd(t)
  local h = t:put(N["009"], 0, "signi_left")
  t:put(OPP, 1, "signi_left")
  local x = t:put(BIG, 1, "signi_center")
  ena(t, 3)
  main(t)
  t:expect(t:answer(t:action(ACT_ABILITY, h)))
  pay(t, 3)
  t:expect(t:wait(HINT_TARGET))
  t:expect(#t:request().options == 1)
  t:expect(t:answer(x))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(x, 1, "ena"))
end)

case("サンジョウ: 英知=10이면 ＋2000과 【ランサー】, 英知=7이면 둘 다 없다", "WD20-011 FAQ 1", function(t)
  for _, c in ipairs{{4, 3, true}, {3, 1, false}} do
    wd(t)
    local h = t:put(N["011"], 0, "signi_left")
    t:put(E[c[1]], 0, "signi_center")
    t:put(E[c[2]], 0, "signi_right")
    t:expect(t:power(h) == (c[3] and 10000 or 8000))
    t:expect(t:keyword(h, EFFECT_LANCER) == c[3] and t:keyword(h, EFFECT_CANNOT_BANISH) == not c[3])
  end
end)

case("サンジョウ: 함께 바니시돼도 처음에 英知=7이면 남는다", "WD20-011 FAQ 3", function(t)
  for _, first in ipairs{true, false} do
    wd(t)
    t:script(300000, [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetOperation(function(e,tp) Duel.Banish(Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil)) end)
  c:RegisterEffect(e1)
end]])
    t:card{cid = 300000, type = TYPE_SPELL}
    local sp = t:put(300000, 0, "hand")
    local h = t:put(N["011"], 0, first and "signi_left" or "signi_right")
    local x = t:put(E[4], 0, "signi_center")
    main(t)
    use(t, sp)
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(h, 0, first and "signi_left" or "signi_right") and t:is_in(x, 0, "ena"))
  end
end)

case("サンジョウ: 파워 0이어도 英知=7이면 남고, 조건이 풀리면 바니시", "WD20-011 FAQ 4", function(t)
  for _, gone in ipairs{false, true} do
    wd(t)
    local h, x = t:put(N["011"], 0, "signi_left"), t:put(E[4], 0, "signi_center")
    t:single(h, EFFECT_UPDATE_POWER, -8000, 0)
    if gone then t:single(x, EFFECT_UPDATE_POWER, -8000, 0) end
    ena(t, 1)  -- 룰 처리가 돌도록 아츠를 하나 쓴다
    t:put(N["008"], 0, "lrig_deck")
    main(t)
    use(t, t:cards(0, "lrig_deck")[1])
    pay(t, 1)
    for _ = 1, 2 do
      t:expect(t:wait(HINT_DECLARE))
      t:expect(t:answer(0))
    end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(h, 0, gone and "ena" or "signi_left"))
  end
end)

case("ブンドキ: 英知=4면 1장 뽑고, 6이면 에나 1장", "WD20-013 FAQ 1", function(t)
  for _, c in ipairs{{2, 1, 0}, {4, 0, 1}, {3, 0, 0}} do
    wd(t)
    local h = t:put(N["013"], 0, "signi_left")
    t:put(E[c[1]], 0, "signi_center")
    attack(t, h)
    t:expect(t:wait(HINT_ATTACK_SIGNI))
    t:expect(t:count(0, "hand") == c[2] and t:count(0, "ena") == c[3])
  end
end)

case("ジョウギ: 英知=2면 ＋3000. 자신도 센다", "WD20-015 FAQ 1", function(t)
  wd(t)
  local h = t:put(N["015"], 0, "signi_left")
  t:expect(t:power(h) == 2000)
  local x = t:put(E[1], 0, "signi_center")
  t:expect(t:power(h) == 5000)
  t:put(E[1], 0, "signi_right")
  t:expect(t:power(h) == 2000)
end)

-- ── 창조 ──

case("創造: ① 바니시하고 덱 위 4장에서 ＜英知＞ 1장", "WD20-018", function(t)
  wd(t)
  local sp, h, x = t:put(N["018"], 0, "hand"), t:put(E[2], 0, "signi_left"), t:put(E[1], 0, "main_deck")
  main(t)
  local deck = t:count(0, "main_deck")
  use(t, sp)
  t:expect(t:wait(HINT_MODE))
  t:expect(t:answer(0))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(h))
  t:expect(t:wait(HINT_SELECT))
  t:expect(#t:request().options == 1)
  t:expect(t:answer(x))
  t:expect(t:wait(HINT_ORDER))
  t:expect(t:answer(table.unpack(t:request().options)))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(x, 0, "hand") and t:is_in(h, 0, "ena") and t:count(0, "main_deck") == deck - 1)
end)

case("創造: ① 바니시되지 않으면 뒷부분도 하지 않는다", "WD20-018 FAQ 1", function(t)
  wd(t)
  local sp, h = t:put(N["018"], 0, "hand"), t:put(N["011"], 0, "signi_left")
  t:put(E[4], 0, "signi_center")
  t:put(E[1], 0, "main_deck")
  main(t)
  use(t, sp)
  t:expect(t:wait(HINT_MODE))
  t:expect(t:answer(0))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(h))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(h, 0, "signi_left") and not t:saw(HINT_SELECT) and t:count(0, "hand") == 0)
end)

case("創造: ② 라이프 0장일 때 ＜英知＞ 3체를 트래시하면 라이프 1장", "WD20-018", function(t)
  for _, c in ipairs{{true, 3, 1}, {true, 2, 0}, {false, 3, 1}} do  -- {라이프 0, ＜英知＞ 수, 라이프}
    wd(t)
    if c[1] then for _, x in ipairs(t:cards(0, "life_cloth")) do t:move(x, 0, "ena") end
    else for i, x in ipairs(t:cards(0, "life_cloth")) do if i > 1 then t:move(x, 0, "ena") end end end
    local sp = t:put(N["018"], 0, "hand")
    for i, z in ipairs{"signi_left", "signi_center", "signi_right"} do t:put(i <= c[2] and E[1] or GREEN, 0, z) end
    main(t)
    use(t, sp)
    t:expect(t:wait(HINT_MODE))
    t:expect(t:answer(1))
    if c[1] then
      t:expect(t:wait(HINT_SCRIPT))
      t:expect(t:answer(1))
    end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:count(0, "life_cloth") == c[3] and t:count(0, "signi_left") == (c[1] and 0 or 1))
  end
end)
