-- WD23 エルドラ·あや 구축덱 카드 스크립트 케이스 + 【トラップ】 룰. 근거는 카드별 FAQ(cards.json)·용어집: トラップ

local N = {}
local SUI, SUI3, TRI, BLUE, LB, OPP, BIG = 200000, 201000, 202000, 203000, 204000, 101000, 102000
local KIND = {}
for i = 1, 44 do
  KIND[i] = (i <= 7 or (i >= 18 and i <= 30)) and "E" or (i <= 14 or (i >= 31 and i <= 40)) and "A" or "EA"
end

local function wd(t, center)
  t:start{db = true, seed = 1}
  for i = 1, 44 do N[i] = t:no(("WD23-%03d-%s"):format(i, KIND[i])) end
  t:card{cid = SUI, power = 4000, level = 2, classes = {"精生：水獣"}, color = COLOR_BLUE}
  t:card{cid = SUI3, power = 5000, level = 3, classes = {"精生：水獣"}, color = COLOR_BLUE}
  t:card{cid = TRI, power = 4000, level = 2, classes = {"精武：トリック"}, color = COLOR_BLUE}
  t:signi(BLUE, 1000, COLOR_BLUE, 1)
  t:card{cid = LB, power = 1000, level = 1, color = COLOR_BLUE, burst = 1}
  t:signi(OPP, 5000, COLOR_RED, 2)
  t:signi(BIG, 15000, COLOR_RED, 4)
  t:fill(BLUE, 0, "main_deck", 15)
  t:fill(OPP, 1, "main_deck", 15)
  t:fill(BLUE, 0, "life_cloth", 5)
  t:fill(OPP, 1, "life_cloth", 5)
  t:put(N[1], 1, "lrig_center")
  return t:put(N[center or 1], 0, "lrig_center")
end

local E, A = 1, 8  -- 레벨 4 루리그

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

local function use(t, c, n) t:expect(t:answer(t:action(ACT_USE, c, n or 0))) end
local function play(t, c, z) t:expect(t:answer(t:action(ACT_PLAY, c, z or "signi_left"))) end
local function ability(t, c, n) return t:action(ACT_ABILITY, c, n or 0) end

local function zone(t, i)
  t:expect(t:wait(HINT_ZONE), "존")
  t:expect(t:answer(t:request().options[i or 1]))
end

local function set(t, cid, z)
  local c = t:put(cid, 0, "hand")
  t:set_trap(c, 0, z)
  return c
end

-- 상대가 signi_right로 어택한다(정면 = 내 signi_left)
local function attacked(t, cid)
  local a = t:put(cid or BIG, 1, "signi_right")
  t:begin(1, PHASE_ATTACK)
  pick(t, HINT_ATTACK_SIGNI, a)
  return a
end

-- 어택을 받아 라이프의 c로 라이프 버스트
local function burst(t, c)
  t:move(c, 0, "life_cloth")
  local a = attacked(t)
  pick(t, HINT_LIFEBURST, 1)
  return a
end

-- ── 【トラップ】 룰 ──

case("トラップ: 주인만 볼 수 있고 시그니가 아니다. 다시 놓으면 있던 것은 트래시", "용어집: トラップ", function(t)
  wd(t, A)
  local a = set(t, N[31], "signi_left")
  t:expect(t:trap(0, "signi_left") == a and t:can_see(0, a) and not t:can_see(1, a))
  t:expect(t:count(0, "signi_left") == 0)
  local b = set(t, N[37], "signi_left")
  t:expect(t:trap(0, "signi_left") == b and t:is_in(a, 0, "trash") and t:can_see(1, a))
end)

case("トラップ: 정면에 시그니가 없으면 어택받을 때 표면으로. 발동하고 트래시로", "용어집: トラップ, WD23-031", function(t)
  for _, yes in ipairs{1, 0} do
    wd(t, A)
    local tr, x = set(t, N[31], "signi_left"), t:put(OPP, 1, "signi_center")
    attacked(t)
    pick(t, HINT_TRAP, yes)
    if yes == 1 then pick(t, HINT_TARGET, x) end
    t:wait(HINT_ATTACK_LRIG)
    t:expect((t:flags(x) & CF_DOWN ~= 0) == (yes == 1))
    t:expect(t:is_in(tr, 0, "trash") == (yes == 1) and t:can_see(1, tr) == (yes == 1))
    t:expect(t:count(0, "life_cloth") == 4, "데미지는 그대로")
  end
end)

case("トラップ: 정면에 시그니가 있으면 트리거해도 열 수 없다", "용어집: トラップ", function(t)
  wd(t, A)
  local tr = set(t, N[31], "signi_left")
  t:put(BLUE, 0, "signi_left")
  attacked(t)
  t:wait(HINT_ATTACK_LRIG)
  t:expect(not t:saw(HINT_TRAP) and t:trap(0, "signi_left") == tr, "시그니가 없어져도 남는다")
end)

case("トラップ: 「アタックしたとき」로 시그니가 떠나면 열 수 있다", "용어집: トラップ", function(t)
  wd(t, A)
  t:script(300000, [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp) Duel.Banish(Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil)) end)
  c:RegisterEffect(e1)
end]])
  t:signi(300000, 1000, COLOR_RED, 1)
  local tr = set(t, N[37], "signi_left")
  t:put(BLUE, 0, "signi_left")
  local a = attacked(t, 300000)
  pick(t, HINT_TRAP, 1)
  t:wait(HINT_ATTACK_LRIG)
  t:expect(t:flags(a) & CF_FROZEN ~= 0 and t:is_in(tr, 0, "trash"))
end)

case("トラップ: 아이콘이 없는 카드도 설치하고 열 수 있다. 아무 일 없이 트래시", "WD23-034 FAQ 2", function(t)
  wd(t, A)
  local tr = set(t, BLUE, "signi_left")
  attacked(t)
  pick(t, HINT_TRAP, 1)
  t:wait(HINT_ATTACK_LRIG)
  t:expect(t:is_in(tr, 0, "trash") and t:count(0, "life_cloth") == 4)
end)

case("トラップ: 루리그 레벨·한정 조건과 관계없다. 존이 지워지면 트래시", "용어집: トラップ", function(t)
  wd(t, 11)
  local tr = set(t, N[32], "signi_left")
  local x = t:put(OPP, 1, "signi_center")
  attacked(t)
  pick(t, HINT_TRAP, 1)
  pick(t, HINT_TARGET, x)
  t:wait(HINT_ATTACK_LRIG)
  t:expect(t:flags(x) & CF_DOWN ~= 0 and t:count(0, "hand") == 1)
  local b = set(t, N[31], "signi_center")
  t:remove_zone(0, "signi_center")
  t:expect(t:is_in(b, 0, "trash"))
end)

case("トラップ: 열린 카드는 시그니로서 장을 떠난 것이 아니다", "용어집: 付けられているカード(【トラップ】)", function(t)
  wd(t, A)
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
end]])
  t:signi(300000, 1000, COLOR_BLUE, 1)
  set(t, 300000, "signi_left")
  local x = t:put(BLUE, 0, "signi_center")
  t:expect(t:power(x) == 1000)
  attacked(t)
  pick(t, HINT_TRAP, 1)
  t:wait(HINT_ATTACK_LRIG)
  t:expect(t:count(0, "hand") == 0)
end)

-- ── エルドラ＆あや ──

case("エルドラ＆あや: あや를 고르면 코인 4개", "WD23-015", function(t)
  for i, c in ipairs{{4, 0}, {11, 4}} do
    wd(t)
    for p = 0, 1 do
      for _, z in ipairs{"lrig_center", "main_deck", "life_cloth"} do
        for _, x in ipairs(t:cards(p, z)) do t:move(x, p, "exclude") end
      end
      t:fill(BLUE, p, "main_deck", 40)
      t:put(N[15], p, "lrig_deck")
    end
    t:put(N[4], 0, "lrig_deck")
    t:put(N[11], 0, "lrig_deck")
    t:start_game()
    for _ = 1, 2 do pick(t, HINT_MODE, i - 1) end
    t:expect(t:wait(HINT_GROW))
    local o = t:request().options
    t:expect(#o == 1 and t:cid(o[1]) == N[c[1]] and t:coins(0) == c[2])
  end
end)

-- ── エルドラ ──

case("エルドラ×マークⅣ: 패 상한 7, 【出】 레조나를 조건 없이. 내지 않아도 된다", "WD23-001 FAQ 1·2", function(t)
  for _, yes in ipairs{true, false} do
    wd(t, 2)
    local g, r = t:put(N[1], 0, "lrig_deck"), t:put(N[7], 0, "lrig_deck")
    ena(t, 3)
    t:begin(0, PHASE_GROW)
    pick(t, HINT_GROW, g)
    pay(t, 3)
    t:expect(t:wait(HINT_SELECT))
    if yes then
      t:expect(t:answer(r))
      zone(t)
    else
      t:expect(t:answer())
    end
    t:expect(t:wait(HINT_MAIN))
    t:expect((t:at(r) ~= "lrig_deck") == yes and t:hand_limit(0) == 7)
  end
end)

case("エルドラ×マークⅣ: 레벨이 다른 ＜水獣＞ 2장을 다 낼 수 있을 때만", "WD23-001 FAQ 3·4", function(t)
  for _, n in ipairs{0, 2} do
    local lc = wd(t)
    t:put_under(t:put(N[2], 0, "lrig_deck"), lc)
    for i, z in ipairs{"signi_left", "signi_center"} do if i <= n then t:put(BLUE, 0, z) end end
    local a, b, c = t:put(SUI, 0, "main_deck"), t:put(SUI3, 0, "main_deck"), t:put(SUI, 0, "main_deck")
    main(t)
    t:expect(t:answer(ability(t, lc)))
    if t:wait(HINT_SELECT) == false then t:expect(false) end
    t:expect(not t:answer(a), "1장만은 안 된다")
    t:expect(not t:answer(a, c), "같은 레벨")
    t:expect(t:answer(a, b) == (n == 0))
    if n == 0 then
      zone(t)
      zone(t)
    else
      t:expect(t:answer())
    end
    t:expect(t:wait(HINT_MAIN))
    t:expect((t:at(a) ~= "main_deck") == (n == 0) and (t:at(b) ~= "main_deck") == (n == 0))
  end
end)

case("エルドラ·あや 레벨 1~3: 코인", "WD23-002~004, WD23-009~011", function(t)
  for _, c in ipairs{{2, 3, 2, 0, 2}, {3, 4, 1, 0, 1}, {9, 10, 2, 1, 1}, {10, 11, 1, 0, 1}} do  -- {카드, 지금, 그로우, 【出】 에나, 코인}
    wd(t, c[2])
    local g = t:put(N[c[1]], 0, "lrig_deck")
    ena(t, c[3] + c[4])
    t:begin(0, PHASE_GROW)
    pick(t, HINT_GROW, g)
    pay(t, c[3])
    if c[4] > 0 then
      pick(t, HINT_USE_TRIGGER, 1)
      pay(t, c[4])
    end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:coins(0) == c[5], c[1])
  end
end)

case("アロワナ・パニック: 대상이 없어도 크러시하고 라이프를 더한다", "WD23-005 FAQ 1", function(t)
  for _, c in ipairs{{E, true}, {A, false}} do
    wd(t, c[1])
    local a = t:put(N[5], 0, "lrig_deck")
    ena(t, 4)
    main(t)
    use(t, a)
    pay(t, 4)
    if c[2] then pick(t, HINT_SCRIPT, 1) end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:count(0, "life_cloth") == 5 and t:count(0, "ena") == (c[2] and 1 or 0))
  end
end)

case("バースト・ラッシュ: 라이프 버스트가 두 번 발동. グレホザメ도 두 번 뽑는다. 그 턴에는 다시 쓸 수 없다", "WD23-006, WD23-020 FAQ 8", function(t)
  wd(t)
  local a, b = t:put(N[6], 0, "lrig_deck"), t:put(N[6], 0, "lrig_deck")
  t:put(N[20], 0, "signi_center")
  local c = t:put(N[26], 0, "life_cloth")  -- LB: 1장 뽑는다
  ena(t, 4)
  local x = t:put(BIG, 1, "signi_right")
  t:begin(1, PHASE_ATTACK)
  t:expect(t:wait(HINT_DEFENSE))
  use(t, a)
  pay(t, 2)
  t:expect(t:wait(HINT_DEFENSE))
  t:expect(t:action(ACT_USE, b) == nil)
  pick(t, HINT_ATTACK_SIGNI, x)
  pick(t, HINT_LIFEBURST, 1)
  for _ = 1, 30 do
    t:step()
    local q = t:request()
    if not q or q.hint == HINT_ATTACK_SIGNI or q.hint == HINT_ATTACK_LRIG or q.hint == HINT_MAIN then break end
    t:answer(table.unpack(q.options, 1, q.min))
  end
  t:expect(t:count(0, "hand") == 4, t:count(0, "hand"))
  t:expect(t:is_in(c, 0, "ena"))
end)

case("バースト・ラッシュ: ナマコズ는 두 번째에 라이프를 더하지 않는다", "WD23-022 FAQ 5", function(t)
  wd(t)
  for _, x in ipairs(t:cards(0, "life_cloth")) do t:move(x, 0, "exclude") end
  local a, c = t:put(N[6], 0, "lrig_deck"), t:put(N[22], 0, "life_cloth")
  ena(t, 2)
  local x = t:put(BIG, 1, "signi_right")
  t:begin(1, PHASE_ATTACK)
  t:expect(t:wait(HINT_DEFENSE))
  use(t, a)
  pay(t, 2)
  pick(t, HINT_ATTACK_SIGNI, x)
  pick(t, HINT_LIFEBURST, 1)
  pick(t, HINT_TRIGGER_ORDER, 0)
  t:expect(t:wait(HINT_ATTACK_LRIG))
  t:expect(t:count(0, "life_cloth") == 1 and t:count(0, "hand") == 2)
end)

case("リヴァイア: 어택하면 7장까지 뽑는다", "WD23-007 FAQ 1", function(t)
  for _, n in ipairs{2, 7} do
    wd(t)
    local h = t:put(N[7], 0, "signi_left")
    t:fill(BLUE, 0, "hand", n)
    t:begin(0, PHASE_ATTACK)
    pick(t, HINT_ATTACK_SIGNI, h)
    t:expect(t:wait(HINT_ATTACK_LRIG))
    t:expect(t:count(0, "hand") == 7)
  end
end)

-- ── シロナクジ ──

-- 상대(1)가 아츠 대신 시그니의 【出】로 옮긴다
local function opp_effect(t, code)
  t:script(300000, ([[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil)
    %s
  end)
  c:RegisterEffect(e1)
end]]):format(code))
  t:signi(300000, 1000, COLOR_RED, 1)
  return t:put(300000, 1, "hand")
end

case("シロナクジ: 다른 ＜水獣＞ 2체를 지키고 자신은 떠난다. 효과의 종류를 가리지 않는다", "WD23-018 FAQ 2·5", function(t)
  for _, code in ipairs{"Duel.Banish(g)", "Duel.SendToHand(g)", "Duel.SendToTrash(g,REASON_EFFECT)", "Duel.SendToDeckBottom(g,false)", "Duel.SendToEna(g)"} do
    wd(t)
    local w, a, b = t:put(N[18], 0, "signi_center"), t:put(SUI, 0, "signi_left"), t:put(SUI3, 0, "signi_right")
    local x = opp_effect(t, code)
    main(t, 1)
    t:expect(t:answer(t:action(ACT_PLAY, x, "signi_left")))
    for _ = 1, 2 do
      t:expect(t:wait(HINT_SCRIPT), code)
      t:expect(t:request().player == 0)
      t:expect(t:answer(1))
    end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(a, 0, "signi_left") and t:is_in(b, 0, "signi_right") and not t:is_in(w, 0, "signi_center"), code)
  end
end)

case("シロナクジ: 2체가 서로 지킨다", "WD23-018 FAQ 7", function(t)
  wd(t)
  local a, b = t:put(N[18], 0, "signi_center"), t:put(N[18], 0, "signi_left")
  local x = opp_effect(t, "Duel.Banish(g)")
  main(t, 1)
  t:expect(t:answer(t:action(ACT_PLAY, x, "signi_left")))
  for _ = 1, 2 do pick(t, HINT_SCRIPT, 1) end
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:power(a) == 6000 and t:power(b) == 6000 and t:is_in(a, 0, "signi_center") and t:is_in(b, 0, "signi_left"))
end)

case("シロナクジ: 배틀·파워 0·자기 효과는 대신할 수 없다", "WD23-018 FAQ 3·4", function(t)
  wd(t)
  t:put(N[18], 0, "signi_center")
  local a = t:put(SUI, 0, "signi_left")
  attacked(t)
  t:wait(HINT_ATTACK_LRIG)
  t:expect(t:is_in(a, 0, "ena") and not t:saw(HINT_SCRIPT))
  wd(t)
  local w = t:put(N[18], 0, "signi_center")
  a = t:put(SUI, 0, "signi_left")
  local sp = t:put(N[30], 0, "hand")
  main(t)
  use(t, sp)
  pick(t, HINT_TARGET, a)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(a, 0, "ena") and t:power(w) == 12000)
end)

case("シロナクジ: LB 공개한 ＜水獣＞ 1장당 −3000", "WD23-018 FAQ 6", function(t)
  wd(t)
  local a, b = t:put(SUI, 0, "hand"), t:put(SUI3, 0, "hand")
  t:put(BLUE, 0, "hand")
  local x = burst(t, t:put(N[18], 0, "hand"))
  pick(t, HINT_TARGET, x)
  t:expect(t:wait(HINT_SELECT))
  t:expect(#t:request().options == 2)
  t:expect(t:answer(a, b))
  t:wait(HINT_ATTACK_LRIG)
  t:expect(t:power(x) == 9000)
end)

-- ── エルドラ 시그니 ──

case("アロワナ: 패 7장 이상이면 덱 위로. 【起】 상대 덱 위 공개", "WD23-019", function(t)
  for _, n in ipairs{7, 6} do
    wd(t)
    local h, x = t:put(N[19], 0, "signi_left"), t:put(BIG, 1, "signi_left")
    t:fill(BLUE, 0, "hand", n)
    main(t)
    t:expect(t:answer(ability(t, h)))
    t:expect(t:wait(HINT_MAIN))
    local top = t:cards(1, "main_deck")
    t:expect(t:can_see(0, top[#top]) and t:can_see(1, top[#top]))
    pick(t, HINT_ATTACK_SIGNI, h)
    pick(t, HINT_TARGET, x)
    t:wait(HINT_ATTACK_LRIG)
    t:expect(t:is_in(x, 1, n == 7 and "main_deck" or "signi_left"))
  end
end)

case("グレホザメ: 어택 페이즈에 뽑은 장수까지 모두 다운하거나 모두 업. 강제", "WD23-020 FAQ 3·4·6", function(t)
  wd(t)
  t:put(N[20], 0, "signi_left")
  t:put(N[21], 0, "signi_center")  -- 어택 페이즈 개시 시 2장 뽑는다
  local x, y = t:put(OPP, 1, "signi_left"), t:put(OPP, 1, "signi_center")
  t:put(OPP, 1, "signi_right")
  t:begin(0, PHASE_ATTACK)
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:request().max == 2 and t:request().min == 0)
  t:expect(t:answer(x, y))
  pick(t, HINT_MODE, 1)
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:flags(x) & CF_DOWN ~= 0 and t:flags(y) & CF_DOWN ~= 0)
end)

case("グレホザメ: 라이프 버스트로 바니시돼도 1장 뽑는다", "WD23-020 FAQ 2", function(t)
  wd(t)
  local h = t:put(N[20], 0, "signi_left")
  t:script(300000, [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_LIFEBURST)
  e1:SetOperation(function(e,tp) Duel.Banish(Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil)) end)
  c:RegisterEffect(e1)
end]])
  t:card{cid = 300000, power = 1000, level = 1, burst = 1}
  t:put(300000, 1, "life_cloth")
  t:begin(0, PHASE_ATTACK)
  pick(t, HINT_ATTACK_SIGNI, h)
  pick(t, HINT_LIFEBURST, 1)
  t:step()
  t:wait(HINT_ATTACK_LRIG)
  t:expect(t:is_in(h, 0, "ena") and t:count(0, "hand") == 1)
end)

case("ダイホウイカ: 버린 1장당 −6000, 턴 종료 시 1장 버린다", "WD23-021 FAQ 1~3", function(t)
  wd(t)
  local h, x = t:put(N[21], 0, "signi_left"), t:put(BIG, 1, "signi_left")
  t:begin(0, PHASE_ATTACK)
  pick(t, HINT_ATTACK_SIGNI, h)
  t:expect(t:count(0, "hand") == 2)
  pick(t, HINT_TARGET, x)
  pick(t, HINT_DISCARD, t:cards(0, "hand")[1])
  t:expect(t:wait(HINT_DISCARD))
  t:expect(t:power(x) == 9000)
  t:expect(t:answer(t:cards(0, "hand")[1]))
  t:wait(HINT_MAIN)
  t:expect(t:count(0, "hand") == 0)
end)

case("ナマコズ: 라이프 1장당 −2000, 0장이면 파워 0이어도 남는다. 【出】 보고 크러시", "WD23-022 FAQ 1~3", function(t)
  wd(t)
  local h = t:put(N[22], 0, "hand")
  main(t)
  play(t, h)
  pick(t, HINT_SCRIPT, 1)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "life_cloth") == 4 and t:power(h) == 10000)
  for _, x in ipairs(t:cards(0, "life_cloth")) do t:move(x, 0, "exclude") end
  t:expect(t:power(h) == 18000 and t:keyword(h, EFFECT_CANNOT_BANISH))
end)

case("キス: 효과로 나오면 상대 라이프를 트래시에. LB 아이콘이면 더한 뒤에 【自】", "WD23-023 FAQ 1", function(t)
  for _, lb in ipairs{true, false} do
    local lc = wd(t)
    t:put_under(t:put(N[2], 0, "lrig_deck"), lc)
    local k, s = t:put(N[23], 0, "main_deck"), t:put(SUI, 0, "main_deck")
    if lb then t:put(LB, 1, "life_cloth") end
    main(t)
    t:expect(t:answer(ability(t, lc)))
    pick(t, HINT_SELECT, k, s)
    zone(t)
    zone(t)
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:count(1, "life_cloth") == (lb and 6 or 4) and t:count(0, "hand") == 1)
  end
end)

case("キス: 리프레시로 라이프가 놓여도 1장 뽑는다", "WD23-023 FAQ 2", function(t)
  wd(t)
  t:put(N[23], 0, "signi_left")
  local e = t:put(N[26], 0, "signi_center")
  local d = t:cards(1, "main_deck")
  for i, c in ipairs(d) do if i > 1 then t:move(c, 1, "trash") end end
  for _, x in ipairs(t:cards(1, "life_cloth")) do t:move(x, 1, "exclude") end
  t:put(OPP, 1, "life_cloth")
  t:put(OPP, 1, "life_cloth")
  main(t)
  t:expect(t:answer(ability(t, e)))  -- 라이프 1장을 놓고 덱의 마지막 1장을 라이프에 → 리프레시
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:refreshes(1) == 1 and t:count(1, "life_cloth") == 1 and t:count(0, "hand") == 1, "턴 1회라 한 번만")
end)

case("キス: 라이프가 놓이면 1장 뽑는다. 턴 1회", "WD23-023", function(t)
  wd(t)
  t:put(N[23], 0, "signi_left")
  local e, f = t:put(N[26], 0, "signi_center"), t:put(N[29], 0, "signi_right")
  main(t)
  t:expect(t:answer(ability(t, e)))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "hand") == 1 and t:count(1, "life_cloth") == 5)
  t:expect(t:answer(ability(t, f)))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "hand") == 1, "턴 1회")
end)

case("キス: LB 라이프 1장을 놓고 덱에서 찾아 라이프에", "WD23-023", function(t)
  wd(t)
  local x = t:put(N[19], 0, "main_deck")
  burst(t, t:put(N[23], 0, "hand"))
  pick(t, HINT_SELECT, x)
  t:wait(HINT_ATTACK_LRIG)
  t:expect(t:is_in(x, 0, "life_cloth") and t:count(0, "life_cloth") == 5 and t:count(0, "trash") == 1)
end)

case("ハイギョ: LB 카드를 버리고 찾아 덱 맨 위에. 상대에게 보이지 않는다", "WD23-024 FAQ 1", function(t)
  wd(t)
  local h, l, x = t:put(N[24], 0, "hand"), t:put(LB, 0, "hand"), t:put(N[19], 0, "main_deck")
  main(t)
  play(t, h)
  pick(t, HINT_USE_TRIGGER, 1)
  pick(t, HINT_DISCARD, l)
  pick(t, HINT_SELECT, x)
  t:expect(t:wait(HINT_MAIN))
  local d = t:cards(0, "main_deck")
  t:expect(d[#d] == x and not t:can_see(1, x) and t:can_see(0, x))
end)

case("ジュゴン: 가운데 존에서 어택하면 카드명을 선언하고 맞으면 2장", "WD23-025", function(t)
  for _, c in ipairs{{OPP, 2}, {BIG, 0}} do
    wd(t)
    local h = t:put(N[25], 0, "signi_center")
    t:begin(0, PHASE_ATTACK)
    pick(t, HINT_ATTACK_SIGNI, h)
    t:expect(t:wait(HINT_ANNOUNCE))
    t:expect(not t:answer(987654321), "없는 카드")
    t:expect(t:answer(c[1]))
    t:wait(HINT_ATTACK_LRIG)
    t:expect(t:count(0, "hand") == c[2])
  end
end)

case("ベルーガ·イルカ: 상대 덱 위나 라이프 위를 본다", "WD23-027, WD23-028", function(t)
  for _, c in ipairs{{27, 0}, {27, 1}, {28}} do
    wd(t)
    local h = t:put(N[c[1]], 0, "signi_left")
    local d, l = t:cards(1, "main_deck"), t:cards(1, "life_cloth")
    t:begin(0, PHASE_ATTACK)
    pick(t, HINT_ATTACK_SIGNI, h)
    if c[2] then pick(t, HINT_MODE, c[2]) end
    t:step()
    t:expect(t:can_see(0, d[#d]) == (c[2] ~= 1))
    if c[2] == 1 then t:expect(t:can_see(0, l[#l])) end
  end
end)

case("SPADE WORK: 바니시하면 무색이 아닌 LB 카드를 찾는다. 컷인으로 없어지면 하지 않는다", "WD23-030 FAQ 1", function(t)
  for _, cut in ipairs{false, true} do
    wd(t)
    local sp, h, x = t:put(N[30], 0, "hand"), t:put(BLUE, 0, "signi_left"), t:put(LB, 0, "main_deck")
    main(t)
    use(t, sp)
    pick(t, HINT_TARGET, h)
    if cut then
      t:expect(t:wait(HINT_CUTIN))
      t:move(h, 0, "ena")
    else
      pick(t, HINT_SELECT, x)
    end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(x, 0, cut and "main_deck" or "hand"))
  end
end)

-- ── あや ──

case("ぷりてぃあーや！Ⅳ: 【出】 2장 설치, 같은 존이면 있던 것은 트래시. 트랩이 발동하면 【自】", "WD23-008 FAQ 1·2", function(t)
  wd(t, 9)
  local g, a, b = t:put(N[8], 0, "lrig_deck"), t:put(N[37], 0, "main_deck"), t:put(N[31], 0, "main_deck")
  t:add_coin(0, 1)
  ena(t, 3)
  t:begin(0, PHASE_GROW)
  pick(t, HINT_GROW, g)
  pay(t, 3)
  pick(t, HINT_USE_TRIGGER, 1)
  pick(t, HINT_SELECT, a, b)
  zone(t, 1)
  zone(t, 1)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(a, 0, "trash") and t:trap(0, "signi_left") == b or t:trap(0, "signi_right") == b)
end)

case("ぷりてぃあーや！Ⅳ: 트랩 처리 뒤 《青》3으로 바니시. 턴 1회", "WD23-008 FAQ 1", function(t)
  wd(t, A)
  local tr, a = set(t, N[37], "signi_left"), t:put(N[14], 0, "lrig_deck")
  local x = t:put(BIG, 1, "signi_left")
  ena(t, 3)
  main(t)
  use(t, a)
  pick(t, HINT_TARGET, tr)
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:flags(x) & CF_FROZEN ~= 0, "트랩이 먼저")
  t:expect(t:answer(x))
  pick(t, HINT_SCRIPT, 1)
  pay(t, 3)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(x, 1, "ena") and t:is_in(tr, 0, "trash"))
end)

case("トリップ・トラップ: 시그니가 있는 존의 트랩도 발동할 수 있다", "WD23-014 FAQ 2", function(t)
  wd(t, A)
  local tr, a, x = set(t, N[37], "signi_left"), t:put(N[14], 0, "lrig_deck"), t:put(OPP, 1, "signi_left")
  t:put(BLUE, 0, "signi_left")
  main(t)
  use(t, a)
  pick(t, HINT_TARGET, tr)
  t:wait(HINT_MAIN)
  t:expect(t:flags(x) & CF_FROZEN ~= 0 and t:is_in(tr, 0, "trash"))
end)

-- 스펠을 쓰는 상대(1)에게 컷인한다. cost = 스펠의 에나 코스트
local function suggest(t, center, spell_cost, modes)
  wd(t, center)
  t:script(300000, [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetOperation(function(e,tp) Duel.Draw(tp,3) end)
  c:RegisterEffect(e1)
end]])
  t:card{cid = 300000, type = TYPE_SPELL, cost = spell_cost, color = COLOR_RED}
  local sp, a = t:put(300000, 1, "hand"), t:put(N[12], 0, "lrig_deck")
  for _ = 1, 8 do t:put(OPP, 1, "ena") end
  ena(t, 2)
  main(t, 1)
  t:expect(t:answer(t:action(ACT_USE, sp)))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(table.unpack(t:cards(1, "ena"), 1, t:request().min)))
  t:expect(t:wait(HINT_CUTIN))
  use(t, a)
  t:expect(t:wait(HINT_MODE))
  return sp
end

case("ブルー・サジェスト: 적힌 코스트 5 이하의 스펠을 打ち消す", "WD23-012 FAQ 2", function(t)
  for _, c in ipairs{{"{R}{R}{R}{C}{C}", 0}, {"{R}{R}{R}{C}{C}{C}", 3}} do
    local sp = suggest(t, E, c[1])
    t:expect(t:request().max == 1, "あや가 아니면 1개")
    t:expect(t:answer(1))
    pay(t, 2)
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:count(1, "hand") == c[2] and t:is_in(sp, 1, "trash"))
  end
end)

case("ブルー・サジェスト: あや면 2개까지. ③은 쓴 플레이어가 고른다", "WD23-012 FAQ 1", function(t)
  wd(t, A)
  local a, x = t:put(N[12], 0, "lrig_deck"), t:put(OPP, 1, "signi_left")
  local lc = t:cards(1, "lrig_center")[1]
  t:put_under(t:put(N[2], 1, "lrig_deck"), lc)
  t:put_under(t:put(N[3], 1, "lrig_deck"), lc)
  ena(t, 2)
  main(t)
  use(t, a)
  t:expect(t:wait(HINT_MODE))
  t:expect(t:request().max == 2)
  t:expect(t:answer(0, 2))
  pay(t, 2)
  pick(t, HINT_TARGET, x)
  t:expect(t:wait(HINT_SELECT))
  t:expect(t:request().player == 0 and t:request().max == 2)
  t:expect(t:answer(table.unpack(t:under(lc))))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:flags(x) & CF_DOWN ~= 0 and t:flags(x) & CF_FROZEN ~= 0 and t:count(1, "lrig_trash") == 2)
end)

case("ワンモア・コール: 찾은 카드를 덱 맨 위에, 앙코르", "WD23-013", function(t)
  wd(t, A)
  local a, x = t:put(N[13], 0, "lrig_deck"), t:put(N[31], 0, "main_deck")
  ena(t, 2)
  main(t)
  use(t, a)
  pick(t, HINT_ENCORE, 1)
  pay(t, 2)
  pick(t, HINT_SELECT, x)
  t:expect(t:wait(HINT_MAIN))
  local d = t:cards(0, "main_deck")
  t:expect(d[#d] == x and t:is_in(a, 0, "lrig_deck"))
end)

case("クリティカル・ショット: 덱이 1장이면 뽑고 되돌려 리프레시하지 않는다. 베트하면 라이프로", "WD23-017 FAQ 1", function(t)
  for _, yes in ipairs{0, 1} do
    wd(t, A)
    for i, c in ipairs(t:cards(0, "main_deck")) do if i > 1 then t:move(c, 0, "trash") end end
    t:add_coin(0, 3)
    local a = t:put(N[17], 0, "lrig_deck")
    main(t)
    use(t, a)
    pick(t, HINT_BET, yes)
    t:expect(t:wait(HINT_SELECT))
    t:expect(t:answer(t:request().options[1]))
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:refreshes(0) == yes, "리프레시")
  end
end)

case("バナナン: 어택 중인 시그니를 다운해도 어택은 막지 못한다", "WD23-031 FAQ 2", function(t)
  wd(t, A)
  set(t, N[31], "signi_left")
  local a = attacked(t)
  pick(t, HINT_TRAP, 1)
  pick(t, HINT_TARGET, a)
  t:wait(HINT_ATTACK_LRIG)
  t:expect(t:count(0, "life_cloth") == 4)
end)

case("タコツボ: 트랩이 발동하면 업·다운, 내 시그니가 어택하면 2장 보고 설치", "WD23-032 FAQ 1", function(t)
  wd(t, A)
  local h, x = t:put(N[32], 0, "signi_left"), t:put(BIG, 1, "signi_center")
  main(t)
  local d = t:cards(0, "main_deck")
  local p, q = d[#d], d[#d - 1]
  pick(t, HINT_ATTACK_SIGNI, h)
  pick(t, HINT_SELECT, q)
  zone(t, 2)
  t:wait(HINT_ATTACK_LRIG)
  local n = 0
  for _, z in ipairs{"signi_left", "signi_center", "signi_right"} do if t:trap(0, z) == q then n = n + 1 end end
  t:expect(n == 1)
  wd(t, A)
  h, x = t:put(N[32], 0, "signi_center"), t:put(BIG, 1, "signi_center")
  local tr, a = set(t, N[37], "signi_left"), t:put(N[14], 0, "lrig_deck")
  main(t)
  use(t, a)
  pick(t, HINT_TARGET, tr)
  t:expect(t:wait(HINT_TARGET) or t:wait(HINT_TRIGGER_ORDER))
  if t:request().hint == HINT_TRIGGER_ORDER then
    t:answer(1)
    t:expect(t:wait(HINT_TARGET))
  end
  t:expect(t:answer(x))
  for _ = 1, 6 do
    t:step()
    local r = t:request()
    if not r or r.hint == HINT_MAIN then break end
    if r.hint == HINT_MODE then t:answer(1)
    elseif r.hint == HINT_TARGET then t:answer(x)
    else t:answer(table.unpack(r.options, 1, r.min)) end
  end
  t:expect(t:flags(x) & CF_DOWN ~= 0)
end)

case("ボーウケアミ: 【起】 어택 페이즈에 ＜トリック＞를 놓고 1장. 트랩은 2장 버려 바니시", "WD23-033", function(t)
  wd(t, A)
  local h, x = t:put(N[33], 0, "signi_left"), t:put(TRI, 0, "signi_center")
  main(t)
  t:expect(ability(t, h) == nil)
  t:expect(t:answer(t:action(ACT_END)))
  t:expect(t:wait(HINT_PRE_ATTACK))
  t:expect(t:answer(ability(t, h)))
  pick(t, HINT_SELECT, x)
  t:expect(t:wait(HINT_PRE_ATTACK))
  t:expect(t:count(0, "hand") == 1 and t:is_in(x, 0, "trash"))
  wd(t, A)
  set(t, N[33], "signi_left")
  local p, q = t:put(TRI, 0, "hand"), t:put(TRI, 0, "hand")
  local a = attacked(t)
  pick(t, HINT_TRAP, 1)
  pick(t, HINT_TARGET, a)
  pick(t, HINT_SCRIPT, 1)
  pick(t, HINT_DISCARD, p, q)
  t:wait(HINT_ATTACK_LRIG)
  t:expect(t:is_in(a, 1, "ena") and t:count(0, "life_cloth") == 5, "어택한 시그니가 없어져 데미지도 없다")
end)

case("スライチェア: 트랩 2장 보고 하나를 설치, 나머지를 패에", "WD23-034", function(t)
  wd(t, A)
  local tr = set(t, N[34], "signi_left")
  local d = t:cards(0, "main_deck")
  local p, q = d[#d], d[#d - 1]
  attacked(t)
  pick(t, HINT_TRAP, 1)
  pick(t, HINT_SELECT, p)
  zone(t, 2)
  t:wait(HINT_ATTACK_LRIG)
  t:expect(t:is_in(q, 0, "hand") and t:is_in(tr, 0, "trash") and t:at(p) ~= "main_deck" and not t:can_see(1, p))
end)

case("ワンクリック: 1장 뽑거나 패를 설치", "WD23-035", function(t)
  for _, m in ipairs{0, 1} do
    wd(t, A)
    local h, x = t:put(N[35], 0, "signi_left"), t:put(BLUE, 0, "hand")
    main(t)
    t:expect(t:answer(ability(t, h)))
    pick(t, HINT_MODE, m)
    if m == 1 then
      pick(t, HINT_SELECT, x)
      zone(t)
    end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:count(0, "hand") == (m == 0 and 2 or 0))
  end
end)

case("コンルス·ブラクラ: 트랩이 있으면 뽑고, 없으면 2장 보고 설치", "WD23-036, WD23-038", function(t)
  for _, on in ipairs{true, false} do
    wd(t, A)
    if on then set(t, BLUE, "signi_right") end
    local h, b = t:put(N[36], 0, "hand"), t:put(N[38], 0, "hand")
    main(t)
    play(t, h)
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:count(0, "hand") == (on and 2 or 1))
    play(t, b, "signi_center")
    if not on then
      local d = t:cards(0, "main_deck")
      pick(t, HINT_SELECT, d[#d])
      zone(t, 3)
    end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:trap(0, "signi_right") ~= nil)
  end
end)

case("テイチアミ: 같은 존에 트랩이 있으면 기본 파워 5000. ±는 그 위에", "WD23-039 FAQ 1", function(t)
  wd(t, A)
  local h = t:put(N[39], 0, "signi_left")
  t:single(h, EFFECT_UPDATE_POWER, 1000, 0)
  t:expect(t:power(h) == 3000)
  set(t, BLUE, "signi_center")
  t:expect(t:power(h) == 3000, "다른 존")
  set(t, BLUE, "signi_left")
  t:expect(t:power(h) == 6000)
end)

case("テイチアミ: 트랩으로 나온 시그니와 배틀한다", "WD23-039 FAQ 2", function(t)
  wd(t, A)
  set(t, N[39], "signi_left")
  local x = t:put(TRI, 0, "main_deck")
  ena(t, 2)
  attacked(t)
  pick(t, HINT_TRAP, 1)
  pick(t, HINT_SCRIPT, 1)
  pay(t, 2)
  pick(t, HINT_SELECT, x)
  t:expect(t:wait(HINT_ZONE))
  -- 어택한 시그니(상대 오른쪽)의 정면은 내 왼쪽 존
  t:expect(t:answer(t:request().options[1]))
  t:wait(HINT_ATTACK_LRIG)
  t:expect(t:is_in(x, 0, "ena") and t:count(0, "life_cloth") == 5)
end)

case("PRANK: ② 트랩을 패에. 상대에게 보이지 않는다", "WD23-040 FAQ 1·4", function(t)
  wd(t, A)
  local sp, h, tr = t:put(N[40], 0, "hand"), t:put(TRI, 0, "signi_center"), set(t, N[31], "signi_left")
  main(t)
  use(t, sp)
  pick(t, HINT_MODE, 1)
  pick(t, HINT_TARGET, h)
  pick(t, HINT_TARGET, tr)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(h, 0, "ena") and t:is_in(tr, 0, "hand") and not t:can_see(1, tr))
end)

case("PRANK: ① 3장 보고 하나를 설치, 나머지는 덱 아래에", "WD23-040", function(t)
  wd(t, A)
  local sp, h = t:put(N[40], 0, "hand"), t:put(TRI, 0, "signi_center")
  main(t)
  local d = t:cards(0, "main_deck")
  use(t, sp)
  pick(t, HINT_MODE, 0)
  pick(t, HINT_TARGET, h)
  pick(t, HINT_SELECT, d[#d])
  zone(t)
  t:expect(t:wait(HINT_ORDER))
  t:expect(t:answer(table.unpack(t:request().options)))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "main_deck") == #d - 1 and t:at(d[#d]) ~= "main_deck")
end)

-- ── 공용 ──

case("ルアー: 레벨이 다른 청 시그니 4장이 있으면 반드시 돌린다. 없으면 아무 일도 없다", "WD23-041 FAQ 1", function(t)
  for _, on in ipairs{true, false} do
    wd(t)
    local h = t:put(N[41], 0, "hand")
    local l = {t:put(BLUE, 0, "trash"), t:put(SUI, 0, "trash"), t:put(SUI3, 0, "trash"), t:put(on and N[19] or N[41], 0, "trash")}
    main(t)
    play(t, h)
    if on then
      t:expect(t:wait(HINT_SELECT))
      t:expect(t:request().min == 4)
      t:expect(t:answer(table.unpack(l)))
      t:expect(t:wait(HINT_SELECT))
      t:expect(#t:request().options == 2)
      t:expect(t:answer(t:request().options[1]))
    end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:count(0, "hand") == (on and 1 or 0) and t:count(0, "trash") == (on and 0 or 4))
  end
end)

case("FISHING: 추가로 버리면 둘 다. 버린 카드도 ①로 되돌릴 수 있다", "WD23-044 FAQ 1", function(t)
  for _, add in ipairs{true, false} do
    wd(t)
    local sp, l, x = t:put(N[44], 0, "hand"), t:put(LB, 0, "hand"), t:put(N[19], 0, "main_deck")
    ena(t, 1)
    main(t)
    use(t, sp)
    t:expect(t:wait(HINT_SELECT))
    t:expect(#t:request().options == 1, "이 스펠은 버릴 수 없다")
    if add then
      t:expect(t:answer(l))
    else
      t:expect(t:answer())
      pick(t, HINT_MODE, 1)
    end
    pay(t, 1)
    if add then pick(t, HINT_TARGET, l) end
    pick(t, HINT_SELECT, x)
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(l, 0, "hand") and t:is_in(x, 0, "hand"))
  end
end)
