-- WD14 ウリス 구축덱 카드 스크립트 케이스. 근거는 카드별 FAQ(cards.json)

local N = {}

-- 200: 흑 ＜悪魔＞ 레벨 1(능력 없음), 201: 흑 ＜古代兵器＞ 레벨 1, 202: 흑 ＜悪魔＞ 레벨 3
-- 101: 상대 레벨 1 파워 1000, 102: 상대 레벨 3 파워 20000, 103: 상대 ＜天使＞
local function wd(t, center)
  t:start{db = true, seed = 1}
  for i = 1, 24 do
    local no = ("%03d"):format(i)
    N[no] = t:no("WD14-" .. no)
  end
  t:card{cid = 200, power = 1000, level = 1, classes = {"精像：悪魔"}, color = COLOR_BLACK}
  t:card{cid = 201, power = 1000, level = 1, classes = {"精械：古代兵器"}, color = COLOR_BLACK}
  t:card{cid = 202, power = 3000, level = 3, classes = {"精像：悪魔"}, color = COLOR_BLACK}
  t:signi(101, 1000, COLOR_GREEN, 1)
  t:signi(102, 20000, COLOR_GREEN, 3)
  t:card{cid = 103, power = 5000, level = 1, classes = {"精像：天使"}, color = COLOR_WHITE}
  t:fill(201, 0, "main_deck", 10)
  t:fill(101, 1, "main_deck", 10)
  t:fill(201, 0, "life_cloth", 5)
  t:fill(101, 1, "life_cloth", 5)
  t:put(N["002"], 1, "lrig_center")
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
  for _ = 1, n do t:put(201, 0, "ena") end
end

local function zone(t)
  t:expect(t:wait(HINT_ZONE))
  t:expect(t:answer(t:request().options[1]))
end

local function pay(t, n)
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:request().min == n, "코스트 " .. n)
  local e = t:cards(t:request().player, "ena")
  t:expect(t:answer(table.unpack(e, 1, n)))
end

local function use(t, card, n)
  t:expect(t:answer(t:action(ACT_USE, card)))
  if n and n > 0 then pay(t, n) end
end

local function play(t, c, z) t:expect(t:answer(t:action(ACT_PLAY, c, z or "signi_left"))) end

-- 라이프 클로스 맨 위의 카드를 크러시해서 라이프 버스트
local function burst(t, no, setup)
  wd(t, "002")
  local c = t:put(N[no] or no, 0, "life_cloth")
  if setup then setup() end
  local a = t:put(102, 1, "signi_left")
  t:begin(1, PHASE_ATTACK)
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:answer(a))
  t:expect(t:wait(HINT_LIFEBURST))
  t:expect(t:answer(1))
  return c, a
end

-- ── 루리그 ──

case("虚幸: 트래시의 ＜悪魔＞ 6장마다 그로우 코스트가 줄어든다", "WD14-001 FAQ 1", function(t)
  for _, c in ipairs{{5, 3}, {6, 2}, {12, 1}, {18, 0}, {30, 0}} do
    wd(t, "002")
    local g = t:put(N["001"], 0, "lrig_deck")
    t:fill(200, 0, "trash", c[1])
    ena(t, c[2])
    t:begin(0, PHASE_GROW)
    t:expect(t:wait(HINT_GROW))
    t:expect(t:answer(g))
    if c[2] > 0 then pay(t, c[2]) end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:center(0) == g)
  end
  -- 코스트로 트래시에 가는 ＜悪魔＞는 세지 않는다
  wd(t, "002")
  t:put(N["001"], 0, "lrig_deck")
  t:fill(200, 0, "trash", 5)
  t:fill(200, 0, "ena", 2)
  t:begin(0, PHASE_GROW)
  t:expect(t:wait(HINT_MAIN))
  t:expect(not t:saw(HINT_GROW))
end)

case("虚幸: 트래시에 ＜悪魔＞가 18장 이상이면 상대는 가드할 수 없다", "WD14-001", function(t)
  for _, n in ipairs{17, 18} do
    local c = wd(t)
    t:fill(200, 0, "trash", n)
    t:put(N["022"], 1, "hand")
    t:begin(0, PHASE_ATTACK)
    t:expect(t:wait(HINT_ATTACK_LRIG))
    t:expect(t:answer(c))
    t:wait(HINT_MAIN)
    t:expect(t:saw(HINT_GUARD) == (n == 17))
    t:expect(t:count(1, "life_cloth") == 4)
  end
end)

case("虚幸: 라이프 버스트가 없는 카드도 상대 시그니를 바니시하는 라이프 버스트를 얻는다", "WD14-001", function(t)
  wd(t)
  local a, b = t:put(102, 1, "signi_left"), t:put(102, 1, "signi_center")
  t:put(200, 0, "signi_center")
  t:begin(1, PHASE_ATTACK)
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:answer(a))
  t:expect(t:wait(HINT_LIFEBURST))
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_TARGET))
  t:expect(#t:request().options == 2)
  t:expect(t:answer(b))
  t:wait(HINT_MAIN)
  t:expect(t:is_in(b, 1, "ena") and t:count(0, "ena") == 1)
  -- 다른 루리그면 없다
  wd(t, "002")
  a = t:put(102, 1, "signi_left")
  t:begin(1, PHASE_ATTACK)
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:answer(a))
  t:wait(HINT_MAIN)
  t:expect(not t:saw(HINT_LIFEBURST))
end)

case("虚幸: 얻은 라이프 버스트는 루리그의 효과가 아니라 アークゲイン에 막힌다", "WD14-001, WD13-013 FAQ 1", function(t)
  wd(t)
  t:move(t:center(1), 1, "exclude")
  t:put(t:no("WD13-003"), 1, "lrig_center")
  local g = t:put(t:no("WD13-013"), 1, "signi_left")
  t:begin(1, PHASE_ATTACK)
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:answer(g))
  t:expect(t:wait(HINT_LIFEBURST))
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(g))
  t:wait(HINT_MAIN)
  t:expect(t:is_in(g, 1, "signi_left"))
end)

case("無道: ＜悪魔＞ ＋1000, エクシード２로 4장 중 1장은 반드시 패에", "WD14-002 FAQ 1·2", function(t)
  local c = wd(t, "002")
  t:put_under(t:put(N["004"], 0, "lrig_deck"), c)
  t:put_under(t:put(N["005"], 0, "lrig_deck"), c)
  local a, b = t:put(200, 0, "signi_left"), t:put(201, 0, "signi_center")
  main(t)
  t:expect(t:power(a) == 2000 and t:power(b) == 1000)
  t:expect(t:answer(t:action(ACT_ABILITY, c)))
  t:expect(t:wait(HINT_EXCEED))
  t:expect(t:answer(table.unpack(t:under(c))))
  t:expect(t:wait(HINT_SELECT))
  t:expect(t:request().min == 1 and #t:request().options == 4)
  t:expect(t:answer(t:request().options[2]))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "hand") == 1 and t:count(0, "trash") == 3)
end)

case("煉獄: 코스트로 낸 ＜悪魔＞도 패에 넣을 수 있다", "WD14-003 FAQ 1", function(t)
  wd(t, "004")
  local g = t:put(N["003"], 0, "lrig_deck")
  t:put(201, 0, "ena")
  t:put(201, 0, "ena")
  local d = t:put(200, 0, "ena")
  t:begin(0, PHASE_GROW)
  t:expect(t:wait(HINT_GROW))
  t:expect(t:answer(g))
  t:expect(t:wait(HINT_PAY_ENA))
  local e = t:cards(0, "ena")
  t:expect(t:answer(e[1], e[2]))
  t:expect(t:wait(HINT_USE_TRIGGER))
  t:expect(t:answer(1))
  pay(t, 1)
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(d))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(d, 0, "hand"))
end)

-- ── 아츠 ──

case("デモン・トゥーム: 바니시하면 라이프 1장, 「バニッシュされない」면 더하지 않는다", "WD14-007 FAQ 2", function(t)
  for _, guard in ipairs{false, true} do
    wd(t, "002")
    local arts = t:put(N["007"], 0, "lrig_deck")
    local a = t:put(200, 0, "signi_left")
    t:put(201, 0, "signi_center")
    if guard then t:grant(a, EFFECT_CANNOT_BANISH, 0, 0) end
    ena(t, 3)
    main(t)
    use(t, arts, 3)
    t:expect(t:wait(HINT_SELECT))
    t:expect(#t:request().options == 1)
    t:expect(t:answer(a))
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:count(0, "life_cloth") == (guard and 5 or 6) and t:is_in(a, 0, "ena") == not guard)
  end
end)

case("グレイブ・ガット: ①2장까지 패로 ②패를 다 버리고 2장까지 장에", "WD14-008 FAQ 1·2", function(t)
  for mode = 0, 1 do
    wd(t, "002")
    local arts = t:put(N["008"], 0, "lrig_deck")
    local d = t:put(200, 0, "trash")
    local h = t:put(200, 0, "hand")
    t:put(201, 0, "trash")
    ena(t, 2)
    main(t)
    t:expect(t:answer(t:action(ACT_USE, arts)))
    t:expect(t:wait(HINT_MODE))
    t:expect(t:answer(mode))
    pay(t, 2)
    t:expect(t:wait(HINT_TARGET))
    t:expect(#t:request().options == 1 + mode, "②는 방금 버린 카드도")
    if mode == 0 then
      t:expect(t:answer(d))
      t:expect(t:wait(HINT_MAIN))
      t:expect(t:is_in(d, 0, "hand") and t:is_in(h, 0, "hand"))
    else
      t:expect(t:answer(d, h))
      zone(t)
      zone(t)
      t:expect(t:wait(HINT_MAIN))
      t:expect(t:count(0, "hand") == 0 and t:count(0, "trash") == 3)
    end
  end
end)

case("デビル・トゥ・デビル: 효과로 트래시한 수만큼. 원래 트래시에 있던 카드도 된다", "WD14-009 FAQ 1·2", function(t)
  wd(t, "002")
  local arts = t:put(N["009"], 0, "lrig_deck")
  ena(t, 2)
  local e1 = t:put(200, 0, "ena")
  local d = t:put(202, 0, "trash")
  main(t)
  use(t, arts, 2)
  t:expect(t:wait(HINT_TARGET))
  t:expect(#t:request().options == 1 and t:request().min == 0)
  t:expect(t:answer(e1))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:request().min == 1 and t:request().max == 1)
  t:expect(t:answer(d))
  zone(t)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(e1, 0, "trash") and not t:is_in(d, 0, "trash"))
end)

case("サイレント・クラップ: 【出】은 발동하지 않는다. 앙코르는 카드 코스트와 같이 낸다", "WD14-010 FAQ 1·3", function(t)
  for _, enc in ipairs{0, 1} do
    wd(t, "002")
    local arts = t:put(N["010"], 0, "lrig_deck")
    local m = t:put(N["017"], 0, "hand")
    local x = t:put(200, 0, "signi_center")
    ena(t, 1)
    main(t)
    t:expect(t:answer(t:action(ACT_USE, arts)))
    t:expect(t:wait(HINT_ENCORE))
    t:expect(t:answer(enc))
    if enc == 1 then pay(t, 1) end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(arts, 0, enc == 1 and "lrig_deck" or "lrig_trash"))
    play(t, m)
    t:expect(t:wait(HINT_MAIN))
    t:expect(not t:saw(HINT_TARGET) and t:is_in(x, 0, "signi_center"))
  end
end)

case("サイレント・クラップ: 「場に出たとき」의 【自】는 발동한다", "WD14-010 FAQ 5", function(t)
  wd(t, "002")
  t:script(300, [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetRange(LOCATION_SZONE)
  e1:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e1)
end]])
  t:card{cid = 300, power = 1000, level = 1, color = COLOR_BLACK}
  t:put(300, 0, "signi_center")
  local arts = t:put(N["010"], 0, "lrig_deck")
  local h = t:put(200, 0, "hand")
  main(t)
  use(t, arts)
  t:expect(t:wait(HINT_MAIN))
  play(t, h)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "hand") == 1)
end)

-- ── 시그니 ──

case("アモノウル: ＜悪魔＞가 바니시되면 더 낮은 레벨의 시그니를 트래시에서. 자신도", "WD14-011 FAQ 1", function(t)
  wd(t)
  local am = t:put(N["011"], 0, "signi_left")
  local a = t:put(202, 0, "signi_center")
  local lo, same, four = t:put(201, 0, "trash"), t:put(202, 0, "trash"), t:put(N["012"], 0, "trash")
  main(t)
  t:single(a, EFFECT_UPDATE_POWER, -9000, 1)
  t:expect(t:answer(t:action(ACT_END)))
  t:expect(t:wait(HINT_TARGET))
  t:expect(has(t:request().options, lo) and not has(t:request().options, same))
  wd(t)
  am = t:put(N["011"], 0, "signi_left")
  lo, four = t:put(201, 0, "trash"), t:put(N["012"], 0, "trash")
  main(t)
  t:single(am, EFFECT_UPDATE_POWER, -19000, 1)
  t:expect(t:answer(t:action(ACT_END)))
  t:expect(t:wait(HINT_TARGET))
  t:expect(has(t:request().options, lo) and has(t:request().options, four))
  t:expect(t:answer(lo))
  zone(t)
  t:wait(HINT_ATTACK_LRIG)
  t:expect(not t:is_in(lo, 0, "trash"))
end)

case("アモノウル: 【出】은 강제. 트래시한 수만큼 상대 시그니를 바니시", "WD14-011 FAQ 2", function(t)
  for _, opp in ipairs{true, false} do
    wd(t)
    local am = t:put(N["011"], 0, "hand")
    local a, b = t:put(200, 0, "signi_center"), t:put(200, 0, "signi_right")
    local x, y, z
    if opp then x, y, z = t:put(101, 1, "signi_left"), t:put(102, 1, "signi_center"), t:put(102, 1, "signi_right") end
    main(t)
    play(t, am)
    if opp then
      t:expect(t:wait(HINT_TARGET))
      t:expect(t:request().min == 2)
      t:expect(t:answer(x, y))
    end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(a, 0, "trash") and t:is_in(b, 0, "trash"))
    if opp then t:expect(t:is_in(x, 1, "ena") and t:is_in(y, 1, "ena") and t:is_in(z, 1, "signi_right")) end
  end
end)

case("アモノウル: 라이프 버스트 ①은 2장을 버려야 라이프가 는다", "WD14-011 FAQ 3", function(t)
  for n = 1, 2 do
    burst(t, "011", function() t:fill(200, 0, "hand", n) end)
    t:expect(t:wait(HINT_MODE))
    t:expect(t:answer(0))
    t:expect(t:wait(HINT_DISCARD))
    t:expect(t:answer(table.unpack(t:cards(0, "hand"))))
    t:wait(HINT_ATTACK_LRIG)
    t:expect(t:count(0, "hand") == 0 and t:count(0, "life_cloth") == (n == 2 and 6 or 5))
  end
end)

case("アシュタルス: 바니시되면 에나에서 장에. 패가 없으면 트래시로", "WD14-012 FAQ 1", function(t)
  for n = 0, 1 do
    wd(t, "002")
    local a = t:put(N["012"], 0, "signi_left")
    t:fill(200, 0, "hand", n)
    main(t, 1)
    t:single(a, EFFECT_UPDATE_POWER, -20000, 1)
    t:expect(t:answer(t:action(ACT_END)))
    t:expect(t:wait(HINT_USE_TRIGGER))
    t:expect(t:answer(1))
    zone(t)
    if n == 1 then
      t:expect(t:wait(HINT_DISCARD))
      t:expect(t:request().min == 1)
      t:expect(t:answer(t:cards(0, "hand")[1]))
    end
    t:wait(HINT_ATTACK_LRIG)
    t:expect(t:is_in(a, 0, "trash") == (n == 0))
    t:expect(t:count(0, "hand") == 0 and not t:is_in(a, 0, "ena"))
  end
end)

case("アシュタルス: 트래시로 바니시되면 낼 수 없다", "WD14-012 FAQ 2", function(t)
  wd(t, "002")
  local a = t:put(N["012"], 0, "signi_left")
  t:field(812, 0, 1, 0, LOCATION_SZONE, 0)
  main(t, 1)
  t:single(a, EFFECT_UPDATE_POWER, -20000, 1)
  t:expect(t:answer(t:action(ACT_END)))
  t:expect(t:wait(HINT_USE_TRIGGER))
  t:expect(t:answer(1))
  t:wait(HINT_ATTACK_LRIG)
  t:expect(t:is_in(a, 0, "trash"))
end)

case("アンナ: 다른 시그니가 없으면 자신을 트래시. 트래시라 【自】는 발동하지 않는다", "WD14-013 FAQ 1", function(t)
  wd(t, "002")
  local a = t:put(N["013"], 0, "hand")
  local x = t:put(101, 1, "signi_left")
  main(t)
  play(t, a)
  t:expect(t:wait(HINT_TARGET))
  t:expect(#t:request().options == 1)
  t:expect(t:answer(a))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(a, 0, "trash") and t:is_in(x, 1, "signi_left"))
end)

case("アンナ: ＜悪魔＞가 바니시되면 상대가 자기 시그니를 골라 바니시(자신도)", "WD14-013", function(t)
  wd(t, "002")
  local a = t:put(N["013"], 0, "signi_left")
  local x, y = t:put(101, 1, "signi_left"), t:put(102, 1, "signi_center")
  main(t)
  t:single(a, EFFECT_UPDATE_POWER, -20000, 1)
  t:expect(t:answer(t:action(ACT_END)))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:request().player == 1 and #t:request().options == 2)
  t:expect(t:answer(x))
  t:wait(HINT_ATTACK_LRIG)
  t:expect(t:is_in(x, 1, "ena") and t:is_in(y, 1, "signi_center"))
end)

case("アンナ: アークゲイン을 고르면 바니시되지 않는다", "WD14-013 FAQ 4·5", function(t)
  wd(t, "002")
  t:move(t:center(1), 1, "exclude")
  t:put(t:no("WD13-003"), 1, "lrig_center")
  local a = t:put(N["013"], 0, "signi_left")
  local g = t:put(t:no("WD13-013"), 1, "signi_left")
  main(t)
  t:single(a, EFFECT_UPDATE_POWER, -20000, 1)
  t:expect(t:answer(t:action(ACT_END)))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(g))
  t:wait(HINT_ATTACK_LRIG)
  t:expect(t:is_in(g, 1, "signi_left"))
end)

case("アンナ: 라이프 버스트 5장 공개, ＜悪魔＞ 1장은 패에 나머지는 트래시", "WD14-013 FAQ 2", function(t)
  local d
  burst(t, "013", function() d = t:put(200, 0, "main_deck") end)
  t:expect(t:wait(HINT_SELECT))
  t:expect(#t:request().options == 1)
  t:expect(t:answer(d))
  t:wait(HINT_ATTACK_LRIG)
  t:expect(t:is_in(d, 0, "hand") and t:count(0, "trash") == 4)
end)

case("ルシファル: 이 시그니가 크러시했을 때만 －10000", "WD14-014 FAQ 1", function(t)
  wd(t, "002")
  local l = t:put(N["014"], 0, "signi_left")
  local o = t:put(202, 0, "signi_center")
  local x = t:put(102, 1, "signi_left")
  t:begin(0, PHASE_ATTACK)
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:answer(o))
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(not t:saw(HINT_TARGET))
  t:expect(t:answer(l))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(x))
  t:expect(t:wait(HINT_ATTACK_LRIG))
  t:expect(t:power(x) == 10000 and t:count(1, "life_cloth") == 3)
end)

case("ルシファル: 【出】 레벨 3 이하 ＜悪魔＞ 2장까지", "WD14-014 FAQ 2", function(t)
  wd(t, "002")
  local l = t:put(N["014"], 0, "hand")
  local d, big = t:put(202, 0, "trash"), t:put(N["012"], 0, "trash")
  ena(t, 3)
  main(t)
  play(t, l)
  t:expect(t:wait(HINT_USE_TRIGGER))
  t:expect(t:answer(1))
  pay(t, 3)
  t:expect(t:wait(HINT_TARGET))
  t:expect(not has(t:request().options, big))
  t:expect(t:answer(d))
  zone(t)
  t:expect(t:wait(HINT_MAIN))
  t:expect(not t:is_in(d, 0, "trash"))
end)

case("ルシファル: 라이프 버스트 ①모든 ＜天使＞ ②패에 넣거나 장에", "WD14-014", function(t)
  local x, mine
  burst(t, "014", function()
    x = t:put(103, 1, "signi_center")
    mine = t:put(103, 0, "signi_left")
  end)
  t:expect(t:wait(HINT_MODE))
  t:expect(t:answer(0))
  t:wait(HINT_ATTACK_LRIG)
  t:expect(t:is_in(x, 1, "ena") and t:is_in(mine, 0, "ena"))
  for k = 0, 1 do
    local d
    burst(t, "014", function() d = t:put(200, 0, "trash") end)
    t:expect(t:wait(HINT_MODE))
    t:expect(t:answer(1))
    t:expect(t:wait(HINT_TARGET))
    t:expect(t:answer(d))
    t:expect(t:wait(HINT_MODE))
    t:expect(t:answer(k))
    if k == 1 then zone(t) end
    t:wait(HINT_ATTACK_LRIG)
    t:expect(t:is_in(d, 0, "hand") == (k == 0) and not t:is_in(d, 0, "trash"))
  end
end)

case("アザゼラ: 효과로 장에서 트래시에 놓였을 때만 뽑는다", "WD14-015 FAQ 1", function(t)
  wd(t, "002")
  local z = t:put(N["015"], 0, "signi_center")
  local m = t:put(N["017"], 0, "hand")
  main(t)
  play(t, m)
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(z))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "hand") == 1)
  wd(t, "002")
  z = t:put(N["015"], 0, "signi_center")
  main(t)
  t:expect(t:answer(t:action(ACT_REMOVE)))
  t:expect(t:wait(HINT_REMOVE))
  t:expect(t:answer(z))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(z, 0, "trash") and t:count(0, "hand") == 0, "리무브는 효과가 아니다")
end)

case("モリガ: ＜悪魔＞를 버리고 －5000", "WD14-016", function(t)
  wd(t, "002")
  local m = t:put(N["016"], 0, "hand")
  local d, o = t:put(200, 0, "hand"), t:put(201, 0, "hand")
  local x = t:put(102, 1, "signi_left")
  main(t)
  play(t, m)
  t:expect(t:wait(HINT_USE_TRIGGER))
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_DISCARD))
  t:expect(not has(t:request().options, o))
  t:expect(t:answer(d))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(x))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:power(x) == 15000)
end)

case("メドギラ·ホッケーマスク: 다른 시그니를 반드시. 없으면 그대로", "WD14-017 FAQ 1·2, WD14-019", function(t)
  for _, no in ipairs{"017", "019"} do
    for n = 0, 1 do
      wd(t, "002")
      local m = t:put(N[no], 0, "hand")
      local x = n == 1 and t:put(201, 0, "signi_center")
      main(t)
      play(t, m)
      if x then
        t:expect(t:wait(HINT_TARGET))
        t:expect(#t:request().options == 1 and t:request().min == 1)
        t:expect(t:answer(x))
      end
      t:expect(t:wait(HINT_MAIN))
      t:expect(t:is_in(m, 0, "signi_left") and (not x or t:is_in(x, 0, "trash")))
    end
  end
end)

case("サロス: 다른 ＜悪魔＞가 있으면 기본 파워 8000", "WD14-018", function(t)
  wd(t)
  local s = t:put(N["018"], 0, "signi_left")
  t:expect(t:power(s) == 5000)
  t:put(200, 0, "signi_center")
  t:expect(t:power(s) == 8000)
end)

case("バアル: 맨 위가 ＜悪魔＞면 패에, 아니면 덱 위에 그대로", "WD14-020 FAQ 1", function(t)
  for _, demon in ipairs{true, false} do
    wd(t, "002")
    local b = t:put(N["020"], 0, "signi_left")
    local top = t:put(demon and 200 or 201, 0, "main_deck")
    main(t)
    t:expect(t:answer(t:action(ACT_ABILITY, b)))
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(top, 0, demon and "hand" or "main_deck") and t:can_see(1, top))
  end
end)

-- ── 스펠 ──

case("エニグマ・オーラ: 어택할 때 트래시한 시그니 수만큼 라이프. 덱이 모자라면 있는 만큼", "WD14-023 FAQ 1", function(t)
  for _, deck in ipairs{10, 1} do
    local c = wd(t, "002")
    for i, x in ipairs(t:cards(0, "main_deck")) do if i > deck then t:move(x, 0, "exclude") end end
    local sp = t:put(N["023"], 0, "hand")
    local a, b = t:put(200, 0, "signi_left"), t:put(200, 0, "signi_center")
    ena(t, 2)
    main(t)
    use(t, sp, 2)
    t:expect(t:wait(HINT_ATTACK_LRIG))
    t:expect(t:answer(c))
    t:expect(t:wait(HINT_TARGET))
    t:expect(t:request().min == 0)
    t:expect(t:answer(a, b))
    t:wait(HINT_MAIN)
    if deck == 10 then
      t:expect(t:is_in(a, 0, "trash") and t:count(0, "life_cloth") == 7)
    else
      t:expect(t:count(0, "life_cloth") == 5, "1장만 더하고(6) 리프레시로 1장 트래시")
    end
  end
end)

case("エニグマ・オーラ: 라이프 버스트로 낸 시그니의 【出】은 발동하지 않는다", "WD14-023 FAQ 2", function(t)
  local d, big, x
  burst(t, "023", function()
    d, big = t:put(N["017"], 0, "trash"), t:put(N["011"], 0, "trash")
    x = t:put(201, 0, "signi_left")
  end)
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(d))
  zone(t)
  t:wait(HINT_ATTACK_LRIG)
  t:expect(not t:is_in(d, 0, "trash") and t:is_in(x, 0, "signi_left") and not t:saw(HINT_TARGET))
end)

case("デス・バイ・デス: 자기 시그니를 바니시하면 －8000", "WD14-024", function(t)
  for _, guard in ipairs{false, true} do
    wd(t, "002")
    local sp = t:put(N["024"], 0, "hand")
    local a, x = t:put(200, 0, "signi_left"), t:put(102, 1, "signi_left")
    if guard then t:grant(a, EFFECT_CANNOT_BANISH, 0, 0) end
    main(t)
    use(t, sp)
    t:expect(t:wait(HINT_TARGET))
    t:expect(t:answer(a))
    t:expect(t:wait(HINT_TARGET))
    t:expect(t:answer(x))
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:power(x) == (guard and 20000 or 12000) and t:is_in(a, 0, "ena") == not guard)
  end
end)
