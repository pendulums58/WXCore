-- 키 셀렉션: 코인, 키, 엑시드, 앙코르, 게이트, 「…を得る」(동적 부여), 《ゲーム1回》

local function base(t, opts)
  opts = opts or {}
  t:lrig(1, opts.level or 3, 9, {"ウムル"}, COLOR_BLUE)
  t:signi(100, 1000)
  t:start(opts.start)
  t:fill(100, 0, "main_deck", 10)
  t:fill(100, 1, "main_deck", 10)
  local c = t:put(1, 0, "lrig_center")
  t:put(1, 1, "lrig_center")
  return c
end

local function main(t)
  t:begin(0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
end

-- ── 코인 ──

case("coin: 센터 루리그 오픈 때 코인 아이콘만큼, 어시스트 오픈은 0", "용어집: コイン, PR-322 FAQ", function(t)
  t:card{cid = 2, type = TYPE_LRIG, level = 0, classes = {"ウムル"}, coin = 2}
  t:card{cid = 3, type = TYPE_LRIG, level = 0, classes = {"タウィル"}, coin = 3}
  t:card{cid = 4, type = TYPE_LRIG, level = 0, classes = {"アト"}, coin = 1}
  t:signi(100, 1000)
  t:start{first = 0}
  local d = {}
  for i = 1, 40 do d[i] = 100 end
  t:deck(0, d, {2, 3, 4})
  t:deck(1, d, {2})
  t:start_game()
  t:expect(t:wait(HINT_START_LRIG))
  local o = t:request().options
  t:expect(t:answer(o[1], o[2], o[3]))
  t:expect(t:wait(HINT_CENTER_LRIG))
  t:expect(t:answer(t:request().options[1]))  -- cid 2(코인 2)가 센터
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:coins(0) == 2, "센터 것만")
  t:expect(t:coins(1) == 2)
end)

case("coin: 센터로 그로우하면 코인 아이콘만큼, 상한 5장", "PR-322 FAQ, 용어집: コイン(上限5枚)", function(t)
  base(t, {level = 2})
  t:card{cid = 5, type = TYPE_LRIG, level = 3, limit = 9, classes = {"ウムル"}, coin = 3}
  local next = t:put(5, 0, "lrig_deck")
  t:add_coin(0, 4)
  t:begin(0, PHASE_GROW)
  t:expect(t:wait(HINT_GROW))
  t:expect(t:answer(next))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:coins(0) == 5, "4 + 3 → 상한 5")
end)

-- ── 키 ──

local function key_card(t, cid, cost_coin, script)
  t:card{cid = cid, type = TYPE_KEY, color = COLOR_WHITE, cost_coin = cost_coin}
  if script then t:script(cid, script) end
end

case("key: 코인을 내고 루리그 덱에서 키 존에", "용어집: キー, WDK09-009 (《コイン》×１)", function(t)
  base(t)
  key_card(t, 50, 1)
  local key = t:put(50, 0, "lrig_deck")
  main(t)
  t:expect(t:action(ACT_KEY, key) == nil, "코인이 없다")
  t:add_coin(0, 1)
  t:expect(t:answer(t:action(ACT_END)) and true)
  -- 다음 내 메인까지
  for _ = 1, 4 do
    t:expect(t:wait(HINT_MAIN))
    if t:request().player == 0 then break end
    t:expect(t:answer(t:action(ACT_END)))
  end
  local act = t:action(ACT_KEY, key)
  t:expect(act ~= nil)
  t:expect(t:answer(act))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(key, 0, "key") and t:coins(0) == 0)
end)

case("key: 2장째를 내면 먼저 키는 루리그 트래시에", "용어집: キー", function(t)
  base(t)
  key_card(t, 50, 0)
  key_card(t, 51, 0)
  local k1 = t:put(50, 0, "key")
  local k2 = t:put(51, 0, "lrig_deck")
  main(t)
  t:expect(t:answer(t:action(ACT_KEY, k2)))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(k2, 0, "key") and t:is_in(k1, 0, "lrig_trash"))
end)

-- 「あなたのセンタールリグは以下の能力を得る」
local GRANT_KEY = [[
local s,id=GetID()
function s.initial_effect(c)
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_IGNITION)
  g:SetRange(LOCATION_LRIG)
  g:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_GRANT)
  e1:SetRange(LOCATION_KEY)
  e1:SetTargetRange(LOCATION_LRIG,0)
  e1:SetLabelObject(g)
  c:RegisterEffect(e1)
end
]]

case("grant: 키가 있는 동안 센터 루리그가 【起】를 얻고, 키가 떠나면 잃는다", "WDK09-009 (センタールリグは以下の能力を得る), 설계: 레이어 3", function(t)
  local center = base(t)
  key_card(t, 50, 0, GRANT_KEY)
  local key = t:put(50, 0, "key")
  t:put(100, 0, "hand")
  main(t)
  local act = t:action(ACT_ABILITY, center)
  t:expect(act ~= nil, "센터의 능력으로 나온다")
  t:expect(t:answer(act))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "hand") == 2)
  t:move(key, 0, "lrig_trash")
  t:expect(t:answer(t:action(ACT_PLAY, t:cards(0, "hand")[1], "signi_left")))  -- 행동 목록 다시 만들기
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:action(ACT_ABILITY, center) == nil, "키가 없으면 없다")
end)

case("grant: 그로우해 새 객체가 된 센터도 동적으로 얻는다", "설계: 고정/동적 대상(【常】은 동적)", function(t)
  base(t, {level = 2})
  key_card(t, 50, 0, GRANT_KEY)
  t:put(50, 0, "key")
  t:lrig(5, 3, 9, {"ウムル"}, COLOR_BLUE)
  local next = t:put(5, 0, "lrig_deck")
  t:begin(0, PHASE_GROW)
  t:expect(t:wait(HINT_GROW))
  t:expect(t:answer(next))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:action(ACT_ABILITY, next) ~= nil)
end)

-- ── 엑시드 ──

local EXCEED = [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetRange(LOCATION_LRIG)
  e1:SetExceedCost(2)
  e1:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e1)
end
]]

case("exceed: 루리그 아래 카드 2장을 루리그 트래시에 놓고 쓴다. 모자라면 못 쓴다", "용어집: エクシード", function(t)
  t:script(1, EXCEED)  -- 스크립트는 카드를 만들기 전에
  local center = base(t)
  t:lrig(6, 1, 0, {"ウムル"})
  local u1 = t:put(6, 0, "lrig_trash")
  t:put_under(u1, center)
  main(t)
  t:expect(t:action(ACT_ABILITY, center) == nil, "아래 카드 1장")
  t:start()
  t:fill(100, 0, "main_deck", 10)
  t:fill(100, 1, "main_deck", 10)
  center = t:put(1, 0, "lrig_center")
  t:put(1, 1, "lrig_center")
  local a, b, c = t:put(6, 0, "lrig_trash"), t:put(6, 0, "lrig_trash"), t:put(6, 0, "lrig_trash")
  t:put_under(a, center)
  t:put_under(b, center)
  t:put_under(c, center)
  main(t)
  t:expect(t:answer(t:action(ACT_ABILITY, center)))
  t:expect(t:wait(HINT_EXCEED))
  t:expect(#t:request().options == 3 and t:request().cancelable)
  t:expect(t:answer(a, b))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(a, 0, "lrig_trash") and t:is_in(b, 0, "lrig_trash") and #t:under(center) == 1)
  t:expect(t:count(0, "hand") == 1)
end)

-- ── 앙코르 ──

local ENCORE_ARTS = [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetEncore(2)
  e1:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e1)
end
]]

local function encore_case(t, coins, yes)
  base(t)
  t:card{cid = 60, type = TYPE_ARTS, timing = TIMING_MAIN}
  t:script(60, ENCORE_ARTS)
  local arts = t:put(60, 0, "lrig_deck")
  t:add_coin(0, coins)
  main(t)
  t:expect(t:answer(t:action(ACT_USE, arts)))
  if yes ~= nil then
    t:expect(t:wait(HINT_ENCORE))
    t:expect(t:request().cancelable)
    t:expect(t:answer(yes and 1 or 0))
  end
  t:expect(t:wait(HINT_MAIN))
  return arts
end

case("encore: 코인을 더 내면 사용 뒤 루리그 덱으로", "용어집: アンコール, WDK09-006 FAQ 2", function(t)
  local arts = encore_case(t, 2, true)
  t:expect(t:is_in(arts, 0, "lrig_deck") and t:coins(0) == 0 and t:count(0, "hand") == 1)
end)

case("encore: 내지 않으면 보통 아츠처럼 루리그 트래시", "용어집: アンコール", function(t)
  local arts = encore_case(t, 2, false)
  t:expect(t:is_in(arts, 0, "lrig_trash") and t:coins(0) == 2)
end)

case("encore: 코인이 모자라면 묻지 않는다", "용어집: アンコール", function(t)
  local arts = encore_case(t, 1, nil)
  t:expect(not t:saw(HINT_ENCORE) and t:is_in(arts, 0, "lrig_trash"))
end)

-- ── 게이트 ──

local GATE_ARTS = [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetOperation(function(e,tp)
    local zones={}
    for _,z in ipairs(Duel.GetSigniZones(1-tp)) do
      if not Duel.HasGate(z) then zones[#zones+1]=z end
    end
    local z=Duel.SelectZone(tp,zones)
    if z then Duel.PlaceGate(z) end
  end)
  c:RegisterEffect(e1)
end
]]

case("gate: 상대 시그니 존 하나에 【ゲート】, 존 하나에 하나까지", "WDK09-001 FAQ 1, WDK09-006", function(t)
  base(t)
  t:card{cid = 61, type = TYPE_ARTS, timing = TIMING_MAIN}
  t:script(61, GATE_ARTS)
  local arts = t:put(61, 0, "lrig_deck")
  t:place_gate(1, "signi_left")
  main(t)
  t:expect(t:answer(t:action(ACT_USE, arts)))
  t:expect(t:wait(HINT_ZONE))
  t:expect(#t:request().options == 2, "이미 있는 존은 빠진다")
  t:expect(t:answer(t:request().options[1]))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:gate(1, "signi_left") and t:gate(1, "signi_center") and not t:gate(1, "signi_right"))
end)

-- ── 《ゲーム1回》 ──

case("count: 《ゲーム1回》 코인 코스트 — 한 번 쓰면 다음 턴에도 못 쓴다", "용어집: ゲーム１回, WDK09-001 FAQ 5(プライマル)", function(t)
  t:script(1, [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetRange(LOCATION_LRIG)
  e1:SetCountLimit(1,true)
  e1:SetCoinCost(1)
  e1:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e1)
end
]])
  local center = base(t)  -- 스크립트는 카드를 만들기 전에
  t:add_coin(0, 3)
  main(t)
  t:expect(t:answer(t:action(ACT_ABILITY, center)))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:coins(0) == 2 and t:action(ACT_ABILITY, center) == nil)
  for _ = 1, 4 do
    t:expect(t:answer(t:action(ACT_END)))
    t:expect(t:wait(HINT_MAIN))
    if t:request().player == 0 then break end
  end
  t:expect(t:request().player == 0 and t:action(ACT_ABILITY, center) == nil, "다음 턴에도 없다")
end)
