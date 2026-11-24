-- WDK06 カーニバル·リル 구축덱 카드 스크립트 케이스. 근거는 카드별 FAQ(cards.json)

local C, R = {}, {}
local BU, BU4, BLK, ARM, RED, OPP, MID, BIG, SPELL = 200000, 200004, 203000, 205000, 206000, 101000, 101500, 102000, 204000

-- center: C의 번호
local function wd(t, center)
  t:start{db = true, seed = 1}
  for i = 1, 20 do
    C[i] = t:no(("WDK06-C%02d"):format(i))
    R[i] = t:no(("WDK06-R%02d"):format(i))
  end
  t:card{cid = BU, power = 4000, level = 1, classes = {"精像：武勇"}, color = COLOR_BLACK}
  t:card{cid = BU4, power = 4000, level = 4, classes = {"精像：武勇"}, color = COLOR_BLACK}
  t:card{cid = ARM, power = 4000, level = 1, classes = {"精武：アーム"}, color = COLOR_RED}
  t:signi(BLK, 1000, COLOR_BLACK, 1)
  t:signi(RED, 1000, COLOR_RED, 1)
  t:signi(OPP, 3000, COLOR_GREEN, 1)
  t:signi(MID, 9000, COLOR_GREEN, 1)
  t:signi(BIG, 15000, COLOR_GREEN, 4)
  t:card{cid = SPELL, type = TYPE_SPELL, color = COLOR_BLACK}
  t:fill(BLK, 0, "main_deck", 15)
  t:fill(OPP, 1, "main_deck", 15)
  t:fill(BLK, 0, "life_cloth", 5)
  t:fill(OPP, 1, "life_cloth", 5)
  t:put(C[1], 1, "lrig_center")
  return t:put(C[center or 1], 0, "lrig_center")
end

local function ril(t, n)
  wd(t)
  t:move(t:cards(0, "lrig_center")[1], 0, "exclude")
  return t:put(R[n or 1], 0, "lrig_center")
end

local function main(t, p)
  t:begin(p or 0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
end

local function ena(t, n, cid)
  for _ = 1, n do t:put(cid or BLK, 0, "ena") end
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
local function trash(t, cid, n) for _ = 1, n do t:put(cid, 0, "trash") end end

-- 덱을 아래부터 이 카드들로
local function deck(t, ...)
  for _, c in ipairs(t:cards(0, "main_deck")) do t:move(c, 0, "exclude") end
  local out = {}
  for i, cid in ipairs{...} do out[i] = t:put(cid, 0, "main_deck") end
  return out
end

-- ── カーニバル ──

case("カーニバル †QA†: 트래시의 ＜武勇＞가 10장이면 트래시에 둔다", "WDK06-C01", function(t)
  for _, n in ipairs{10, 9} do
    wd(t, 2)
    local g, x = t:put(C[1], 0, "lrig_deck"), t:put(BIG, 1, "signi_left")
    trash(t, BU, n)
    t:begin(0, PHASE_GROW)
    pick(t, HINT_GROW, g)
    pick(t, HINT_TARGET, x)
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(x, 1, n == 10 and "trash" or "signi_left"))
  end
end)

case("カーニバル †QA†: 덱 3장을 코스트로 −5000. 2장이면 쓸 수 없고, 3장이면 처리한 뒤 리프레시", "WDK06-C01 FAQ 1·2", function(t)
  for _, n in ipairs{3, 2} do
    local lc = wd(t)
    local x = t:put(BIG, 1, "signi_left")
    for i, c in ipairs(t:cards(0, "main_deck")) do if i > n then t:move(c, 0, "exclude") end end
    main(t)
    if n == 2 then
      t:expect(t:action(ACT_ABILITY, lc) == nil)
    else
      t:expect(t:answer(t:action(ACT_ABILITY, lc)))
      t:expect(t:wait(HINT_TARGET))
      t:expect(t:refreshes(0) == 0 and t:answer(x))
      t:expect(t:wait(HINT_MAIN))
      t:expect(t:power(x) == 10000 and t:refreshes(0) == 1 and t:action(ACT_ABILITY, lc) == nil)
    end
  end
end)

case("カーニバル 레벨 1~3", "WDK06-C02~C04 FAQ", function(t)
  for _, yes in ipairs{1, 0} do
    for _, c in ipairs{{2, 3, 2, 1, 0}, {3, 4, 1, 0, 1}, {4, 5, 0, 0, 0}} do  -- {카드, 밑, 그로우, 【出】 에나, 코인}
      wd(t, c[2])
      local g, h = t:put(C[c[1]], 0, "lrig_deck"), c[1] == 4 and t:put(BLK, 0, "hand")
      t:add_coin(0, c[5])
      ena(t, c[3] + c[4])
      t:begin(0, PHASE_GROW)
      pick(t, HINT_GROW, g)
      if c[3] > 0 then pay(t, c[3]) end
      pick(t, HINT_USE_TRIGGER, yes)
      if yes == 1 and c[4] > 0 then pay(t, 1) end
      if yes == 1 and h then pick(t, HINT_DISCARD, h) end
      t:expect(t:wait(HINT_MAIN))
      t:expect(t:coins(0) == (c[1] == 3 and 1 - yes or yes))
      t:expect(t:count(0, "hand") == (c[1] == 3 and yes or (h and 1 - yes or 0)))
    end
  end
end)

case("フェイト・ストラグル: 쓸 때 트래시가 20장 이상. 코스트로 채울 수는 없다. 2체까지", "WDK06-C06 FAQ 1·2", function(t)
  for _, n in ipairs{20, 16} do
    wd(t)
    local a, x, y = t:put(C[6], 0, "lrig_deck"), t:put(BIG, 1, "signi_left"), t:put(OPP, 1, "signi_center")
    trash(t, BLK, n)
    ena(t, 4)
    main(t)
    if n == 16 then
      t:expect(t:action(ACT_USE, a) == nil)
    else
      use(t, a)
      pay(t, 4)
      t:expect(t:wait(HINT_TARGET))
      t:expect(t:request().min == 0)
      t:expect(t:answer(x, y))
      t:expect(t:wait(HINT_MAIN))
      t:expect(t:is_in(x, 1, "ena") and t:is_in(y, 1, "ena"))
    end
  end
end)

case("バッド・エンド: 5장이 모두 흑이면 흑 시그니를 패에. アンコール로 루리그 덱에", "WDK06-C07 FAQ 1·2", function(t)
  for _, c in ipairs{{5, BLK, true, 1}, {5, RED, false, 0}, {4, BLK, false, 0}} do  -- {덱 장수, 맨 위, 회수, 앙코르}
    wd(t)
    local a = t:put(C[7], 0, "lrig_deck")
    local l = {}
    for i = 1, c[1] - 1 do l[i] = BLK end
    l[c[1]] = c[2]
    local d = deck(t, table.unpack(l))
    t:add_coin(0, 1)
    main(t)
    use(t, a)
    pick(t, HINT_ENCORE, c[4])
    if c[3] then
      t:expect(t:wait(HINT_TARGET))
      t:expect(t:refreshes(0) == 0 and t:answer(d[1]))
    end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:count(0, "hand") == (c[3] and 1 or 0) and t:refreshes(0) == 1)
    t:expect(t:is_in(a, 0, c[4] == 1 and "lrig_deck" or "lrig_trash") and t:coins(0) == 1 - c[4])
  end
end)

case("タクティカル・パニッシュ: 트래시 15장이면 −8000, 나중에 줄어도 그대로", "WDK06-C08 FAQ 1", function(t)
  for _, n in ipairs{15, 14} do
    wd(t)
    local a, x = t:put(C[8], 0, "lrig_deck"), t:put(BIG, 1, "signi_left")
    trash(t, BLK, n)
    main(t)
    use(t, a)
    pick(t, HINT_TARGET, x)
    t:expect(t:wait(HINT_MAIN))
    t:move(t:cards(0, "trash")[1], 0, "exclude")
    t:expect(t:power(x) == (n == 15 and 7000 or 12000))
  end
end)

case("ナナシ 其の鉤: 【出】 서로 5장. 코스트로 낸 시그니도 되찾는다. 턴 1회", "WDK06-C09 FAQ 2", function(t)
  wd(t)
  local k = t:put(C[9], 0, "lrig_deck")
  t:put(SPELL, 0, "trash")
  t:put(RED, 0, "trash")
  t:add_coin(0, 2)
  ena(t, 4)
  main(t)
  t:expect(t:answer(t:action(ACT_KEY, k)))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "trash") == 7 and t:count(1, "trash") == 5 and t:coins(0) == 0)
  local e = t:cards(0, "ena")[1]
  t:expect(t:answer(t:action(ACT_ABILITY, k)))
  pay(t, 2)
  t:expect(t:wait(HINT_TARGET))
  t:expect(#t:request().options == 7, "흑 시그니만")
  t:expect(t:answer(e))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(e, 0, "hand") and t:action(ACT_ABILITY, k) == nil)
end)

case("ナナシ 其の鉤: 센터가 무색이면 무색 시그니도 고를 수 없다", "WDK06-C09 FAQ 3", function(t)
  wd(t)
  t:lrig(300000, 4, 11, {"ウリス"}, 0)
  t:move(t:cards(0, "lrig_center")[1], 0, "exclude")
  t:put(300000, 0, "lrig_center")
  local k, x = t:put(C[9], 0, "key"), t:put(C[19], 0, "trash")
  ena(t, 2)
  main(t)
  t:expect(t:answer(t:action(ACT_ABILITY, k)))
  pay(t, 2)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(x, 0, "trash") and not t:saw(HINT_TARGET))
end)

case("ナナシ 其の鉤: 키를 놓고 상대 시그니 모두 −2000×상대 레벨", "WDK06-C09 FAQ 4", function(t)
  wd(t)
  local k, x, y = t:put(C[9], 0, "key"), t:put(BIG, 1, "signi_left"), t:put(OPP, 1, "signi_center")
  t:begin(0, PHASE_ATTACK)
  t:expect(t:wait(HINT_PRE_ATTACK))
  t:expect(t:answer(t:action(ACT_ABILITY, k)))
  t:wait(HINT_ATTACK_LRIG)
  t:expect(t:is_in(k, 0, "lrig_trash") and t:power(x) == 7000 and t:is_in(y, 1, "ena"))
end)

case("カコウトン: 자신이 트래시에서 나온 때도 −3000. 패에서 나온 것은 아니다", "WDK06-C11 FAQ 1", function(t)
  wd(t)
  local l, k, x = t:put(C[12], 0, "signi_left"), t:put(C[11], 0, "trash"), t:put(BIG, 1, "signi_left")
  local h = t:put(BU, 0, "hand")
  ena(t, 1)
  main(t)
  t:expect(t:answer(t:action(ACT_ABILITY, l)))
  pay(t, 1)
  pick(t, HINT_TARGET, k)
  zone(t)
  pick(t, HINT_TARGET, x)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:power(x) == 12000 and t:flags(l) & CF_DOWN ~= 0)
  t:expect(t:at(k) ~= "trash")
  for _, z in ipairs{"signi_center", "signi_right"} do
    local a = t:action(ACT_PLAY, h, z)
    if a then
      t:expect(t:answer(a))
      break
    end
  end
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:at(h) ~= "hand" and t:power(x) == 12000, "패에서 나온 것")
end)

case("カコウトン: 어택 −5000, 트래시 20장이면 −8000. 정면을 바니시하면 대미지", "WDK06-C11 FAQ 2·3", function(t)
  for _, n in ipairs{20, 19} do
    wd(t)
    local h = t:put(C[11], 0, "signi_center")
    t:signi(300000, 8000, COLOR_GREEN, 1)
    local x = t:put(300000, 1, "signi_center")
    local y = t:put(BIG, 1, "signi_left")
    trash(t, BLK, n)
    t:begin(0, PHASE_ATTACK)
    pick(t, HINT_ATTACK_SIGNI, h)
    pick(t, HINT_TARGET, n == 20 and x or y)
    t:wait(HINT_ATTACK_LRIG)
    if n == 20 then
      t:expect(t:is_in(x, 1, "ena") and t:count(1, "life_cloth") == 4)
    else
      t:expect(t:power(y) == 10000)
    end
  end
end)

case("ランスロー: 코스트로 낸 시그니를 낼 수 있다. 존이 없거나 리미트를 넘으면 못 낸다", "WDK06-C12 FAQ 1~3", function(t)
  for _, c in ipairs{"cost", "full", "limit"} do
    wd(t)
    local l = t:put(C[12], 0, "signi_left")
    local e = t:put(c == "limit" and BU4 or BU, 0, "ena")
    if c ~= "cost" then t:put(BU4, 0, "signi_center") end
    if c == "full" then t:put(BLK, 0, "signi_right") end
    main(t)
    t:expect(t:answer(t:action(ACT_ABILITY, l)))
    pay(t, 1)
    pick(t, HINT_TARGET, e)
    if c == "cost" then zone(t) end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(e, 0, "trash") == (c ~= "cost"), c)
  end
end)

case("ガエイン·パルジファル: 트래시의 ＜武勇＞ 5장·3장", "WDK06-C13, WDK06-C15", function(t)
  wd(t)
  local a, b = t:put(C[13], 0, "signi_left"), t:put(C[15], 0, "signi_center")
  trash(t, BLK, 5)
  trash(t, BU, 2)
  t:expect(t:power(a) == 8000 and t:power(b) == 5000)
  trash(t, BU, 1)
  t:expect(t:power(a) == 8000 and t:power(b) == 8000)
  trash(t, BU, 2)
  t:expect(t:power(a) == 12000)
end)

case("カコウエン: 버린 시그니를 낼 수 있다. 레벨 3 이하만", "WDK06-C14 FAQ 3", function(t)
  wd(t)
  local h, d = t:put(C[14], 0, "hand"), t:put(BU, 0, "hand")
  t:put(BU4, 0, "trash")
  main(t)
  play(t, h)
  pick(t, HINT_USE_TRIGGER, 1)
  pick(t, HINT_DISCARD, d)
  t:expect(t:wait(HINT_TARGET))
  t:expect(#t:request().options == 1)
  t:expect(t:answer(d))
  zone(t)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:at(d) ~= "trash" and t:at(d) ~= "hand")
end)

case("カコウエン: 상대 턴이면 내지 않는다", "WDK06-C14", function(t)
  wd(t)
  local a, k, x = t:put(t:no("WDK04-009"), 0, "lrig_deck"), t:put(C[14], 0, "trash"), t:put(BU, 0, "trash")
  local d = t:put(BLK, 0, "hand")
  ena(t, 3)
  t:begin(1, PHASE_ATTACK)
  t:expect(t:wait(HINT_DEFENSE))
  use(t, a)
  pay(t, 3)
  pick(t, HINT_TARGET, k)
  zone(t)
  pick(t, HINT_USE_TRIGGER, 1)
  pick(t, HINT_DISCARD, d)
  pick(t, HINT_TARGET, x)
  t:wait(HINT_ATTACK_LRIG)
  t:expect(t:is_in(x, 0, "trash") and t:is_in(d, 0, "trash"))
end)

case("チョウリョウ: ＜武勇＞ 2장마다 ＋1000, 20장까지", "WDK06-C17 FAQ 1", function(t)
  for _, c in ipairs{{10, 5000}, {15, 7000}, {22, 10000}, {1, 0}} do
    wd(t)
    local h, x = t:put(C[17], 0, "hand"), t:put(BU, 0, "signi_center")
    trash(t, BU, c[1])
    main(t)
    play(t, h)
    t:expect(t:wait(HINT_TARGET))
    t:expect(#t:request().options == 1, "자신은 아니다")
    t:expect(t:answer(x))
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:power(x) == 4000 + c[2], c[1])
  end
end)

case("リサイクル・デッズ: 놓은 시그니·덱에서 놓인 시그니도 낼 수 있다. 덱이 1장이면 처리 뒤 리프레시", "WDK06-C20 FAQ 2·3", function(t)
  for _, n in ipairs{15, 1} do
    wd(t)
    local sp, h = t:put(C[20], 0, "hand"), t:put(BU, 0, "signi_left")
    local d = n == 1 and deck(t, BU)[1] or t:put(BU, 0, "main_deck")
    main(t)
    use(t, sp)
    pick(t, HINT_MODE, 0)
    pick(t, HINT_TARGET, h)
    t:expect(t:wait(HINT_TARGET))
    t:expect(#t:request().options == 2 and t:refreshes(0) == 0)
    t:expect(t:answer(d))
    zone(t)
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:at(d) ~= "trash" and t:refreshes(0) == (n == 1 and 1 or 0))
  end
end)

case("リサイクル・デッズ·剣筋の見定め: 놓을 시그니가 없으면 아무것도 하지 않는다", "WDK06-C20 FAQ 1, WDK06-R20 FAQ 1", function(t)
  wd(t)
  local sp = t:put(C[20], 0, "hand")
  t:put(BLK, 0, "signi_left")
  t:put(BU, 0, "trash")
  main(t)
  use(t, sp)
  pick(t, HINT_MODE, 0)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "trash") == 2 and t:count(0, "main_deck") == 15)
  ril(t)
  sp = t:put(R[20], 0, "hand")
  local d = t:put(RED, 0, "hand")
  t:put(RED, 0, "signi_left")
  main(t)
  use(t, sp)
  pick(t, HINT_MODE, 0)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(d, 0, "hand") and t:count(0, "hand") == 1)
end)

-- ── リル ──

-- 레벨 3에서 凛武로 그로우. 덱은 아래부터 d
local function grow(t, d, setup)
  ril(t, 2)
  local g = t:put(R[1], 0, "lrig_deck")
  local cards = deck(t, table.unpack(d))
  local x = t:put(BIG, 1, "signi_left")
  if setup then setup() end
  t:begin(0, PHASE_GROW)
  pick(t, HINT_GROW, g)
  return cards, x
end

-- 두 【出】이 순서를 물으면 첫 번째를 먼저
local function first(t)
  t:step()
  if t:request() and t:request().hint == HINT_TRIGGER_ORDER then t:expect(t:answer(0)) end
end

case("凛武の記憶: 3장 중 ＜アーム＞를 내고 그 파워(＋3000) 이하를 바니시", "WDK06-R01", function(t)
  local low
  local d = grow(t, {RED, RED, RED, SPELL, ARM}, function() low = t:put(OPP, 1, "signi_center") end)
  first(t)
  pick(t, HINT_SELECT, d[5])
  zone(t)
  t:expect(t:wait(HINT_ORDER))
  t:expect(t:answer(d[3], d[4]))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:power(d[5]) == 7000 and #t:request().options == 1)
  t:expect(t:answer(low))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(low, 1, "ena") and t:count(0, "main_deck") == 4 and t:count(0, "ena") == 0, "키가 없으면 에나 차지 없음")
end)

case("凛武の記憶: 존이 없으면 셋 다 덱 아래에, 바니시 없음", "WDK06-R01 FAQ 2", function(t)
  local low
  local d = grow(t, {RED, RED, RED, SPELL, ARM}, function()
    low = t:put(OPP, 1, "signi_center")
    for _, z in ipairs{"signi_left", "signi_center", "signi_right"} do t:put(RED, 0, z) end
  end)
  first(t)
  pick(t, HINT_SELECT, d[5])
  pick(t, HINT_ORDER, d[3], d[4], d[5])
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "main_deck") == 5 and t:is_in(low, 1, "signi_center"))
end)

case("凛武の記憶: 덱이 1장이면 내고 바니시한 뒤 리프레시", "WDK06-R01 FAQ 4·5", function(t)
  local low
  local d = grow(t, {ARM}, function()
    low = t:put(OPP, 1, "signi_center")
    t:put(RED, 0, "trash")
  end)
  first(t)
  pick(t, HINT_SELECT, d[1])
  zone(t)
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:refreshes(0) == 0 and t:answer(low))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(low, 1, "ena") and t:refreshes(0) == 1)
end)

case("凛武の記憶: 《メル＝マドラー》가 있으면 에나 차지 2. ＋3000은 내 턴만", "WDK06-R01 FAQ 1", function(t)
  grow(t, {RED, RED, RED, RED, RED, RED}, function() t:put(R[9], 0, "key") end)
  pick(t, HINT_TRIGGER_ORDER, 0)
  pick(t, HINT_ORDER, table.unpack(t:cards(0, "main_deck"), 4, 6))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "ena") == 2)
  ril(t)
  local a = t:put(ARM, 0, "signi_left")
  main(t, 1)
  t:expect(t:power(a) == 4000)
end)

case("リル 레벨 1·2", "WDK06-R03, WDK06-R04", function(t)
  ril(t, 4)
  local g = t:put(R[3], 0, "lrig_deck")
  t:add_coin(0, 1)
  ena(t, 1, RED)
  t:begin(0, PHASE_GROW)
  pick(t, HINT_GROW, g)
  pay(t, 1)
  pick(t, HINT_USE_TRIGGER, 1)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:coins(0) == 0 and t:count(0, "hand") == 1)
  ril(t, 5)
  g = t:put(R[4], 0, "lrig_deck")
  t:begin(0, PHASE_GROW)
  pick(t, HINT_GROW, g)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:coins(0) == 1)
end)

case("火朝月夕: 한쪽만 있어도 처리한다. ベット하면 코스트 2", "WDK06-R07 FAQ 1", function(t)
  for _, c in ipairs{{0, true, false}, {1, false, true}, {1, true, true}} do  -- {베트, 상대 시그니, 트래시의 적}
    ril(t)
    local a = t:put(R[7], 0, "lrig_deck")
    local x = c[2] and t:put(BIG, 1, "signi_left")
    local y = c[3] and t:put(RED, 0, "trash")
    t:put(BLK, 0, "trash")
    t:add_coin(0, 1)
    ena(t, 4, RED)
    main(t)
    use(t, a)
    pick(t, HINT_BET, c[1])
    pay(t, c[1] == 1 and 2 or 4)
    -- 코스트로 낸 적 시그니도 트래시의 후보가 된다
    if x then pick(t, HINT_TARGET, x) end
    t:expect(t:wait(HINT_TARGET))
    t:expect(t:answer(y or t:request().options[1]))
    t:expect(t:wait(HINT_MAIN))
    t:expect((not x or t:is_in(x, 1, "ena")) and t:count(0, "hand") == 1)
  end
end)

case("火中取栗: ① 라이즈 시그니보다 파워가 낮은 것. 라이즈가 없으면 아무것도", "WDK06-R08 FAQ 1", function(t)
  for _, on in ipairs{true, false} do
    ril(t)
    local a, h = t:put(R[8], 0, "lrig_deck"), t:put(on and R[11] or ARM, 0, "signi_left")
    local x, y = t:put(MID, 1, "signi_left"), t:put(OPP, 1, "signi_center")
    t:signi(300000, 16000, COLOR_GREEN, 1)
    t:put(300000, 1, "signi_right")
    main(t)
    use(t, a)
    pick(t, HINT_MODE, 0)
    if on then
      pick(t, HINT_TARGET, h)
      t:expect(t:wait(HINT_TARGET))
      t:expect(#t:request().options == 2, "16000은 16000보다 낮지 않다")
      t:expect(t:answer(x))
    end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(x, 1, on and "ena" or "signi_left") and t:is_in(y, 1, "signi_center"))
  end
end)

case("火中取栗: ② 라이즈 1장과 ＜アーム＞ 1장. ＜アーム＞만 2장은 안 된다. ベット하면 둘 다", "WDK06-R08", function(t)
  ril(t)
  local a, h, x = t:put(R[8], 0, "lrig_deck"), t:put(R[11], 0, "signi_left"), t:put(OPP, 1, "signi_center")
  local p, q, r = t:put(ARM, 0, "main_deck"), t:put(ARM, 0, "main_deck"), t:put(R[11], 0, "main_deck")
  t:add_coin(0, 1)
  main(t)
  use(t, a)
  pick(t, HINT_BET, 1)
  pick(t, HINT_TARGET, h)
  pick(t, HINT_TARGET, x)
  t:expect(t:wait(HINT_SELECT))
  t:expect(not t:answer(p, q))
  t:expect(t:answer(p, r))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(p, 0, "hand") and t:is_in(r, 0, "hand") and t:is_in(q, 0, "main_deck") and t:is_in(x, 1, "ena"))
end)

case("メル＝マドラー: 상대 턴 종료 시 어택한 시그니를 바니시", "WDK06-R09", function(t)
  for _, yes in ipairs{1, 0} do
    ril(t)
    local k = t:put(R[9], 0, "key")
    local x, y = t:put(BIG, 1, "signi_left"), t:put(OPP, 1, "signi_center")
    t:begin(1, PHASE_ATTACK)
    pick(t, HINT_ATTACK_SIGNI, x)
    t:expect(t:wait(HINT_ATTACK_LRIG))
    t:expect(t:answer())
    t:expect(t:wait(HINT_TARGET))
    t:expect(t:request().player == 0 and #t:request().options == 1 and t:request().min == 0)
    t:expect(t:answer(x))
    pick(t, HINT_SCRIPT, yes)
    t:wait(HINT_MAIN)
    t:expect(t:is_in(x, 1, yes == 1 and "ena" or "signi_left") and t:is_in(k, 0, yes == 1 and "lrig_trash" or "key") and t:is_in(y, 1, "signi_center"))
  end
end)

case("メル＝マドラー: 【出】 에나 차지 2, 【起】 어택 페이즈에 턴 1회 ＋2000(상대 시그니도)", "WDK06-R09", function(t)
  ril(t)
  local k, x = t:put(R[9], 0, "lrig_deck"), t:put(BIG, 1, "signi_left")
  t:add_coin(0, 1)
  main(t)
  t:expect(t:answer(t:action(ACT_KEY, k)))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "ena") == 2)
  t:expect(t:wait(HINT_PRE_ATTACK))
  t:expect(t:answer(t:action(ACT_ABILITY, k)))
  pick(t, HINT_TARGET, x)
  t:expect(t:wait(HINT_PRE_ATTACK))
  t:expect(t:power(x) == 17000 and t:action(ACT_ABILITY, k) == nil)
end)

case("ハイメイル: 이 턴에 2장 이상 버렸으면 바니시. 적 시그니 위에 라이즈", "WDK06-R11", function(t)
  for n = 1, 2 do
    ril(t)
    local h, b, x = t:put(R[11], 0, "hand"), t:put(RED, 0, "signi_left"), t:put(BIG, 1, "signi_center")
    t:put(BLK, 0, "signi_center")
    local z, g = t:put(R[17], 0, "hand"), t:put(ARM, 0, "hand")
    local d = t:put(RED, 0, "hand")
    main(t)
    t:expect(t:action(ACT_PLAY, h, "signi_center") == nil and t:action(ACT_PLAY, h, "signi_right") == nil)
    play(t, h)
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:under(h)[1] == b)
    t:expect(t:answer(t:action(ACT_ABILITY, h)))
    pick(t, HINT_DISCARD, d)
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:action(ACT_ABILITY, h) == nil)
    if n == 2 then
      play(t, z, "signi_right")
      pick(t, HINT_USE_TRIGGER, 1)
      pick(t, HINT_DISCARD, g)
      t:expect(t:wait(HINT_MAIN))
    end
    pick(t, HINT_ATTACK_SIGNI, h)
    pick(t, HINT_TARGET, x)
    t:wait(HINT_ATTACK_SIGNI)
    t:expect(t:is_in(x, 1, n == 2 and "ena" or "signi_center"), n)
  end
end)

case("トンファー: 이 턴에 버렸으면 2장", "WDK06-R12", function(t)
  for n = 0, 1 do
    ril(t)
    local h, z, g = t:put(R[12], 0, "hand"), t:put(R[17], 0, "hand"), t:put(ARM, 0, "hand")
    ena(t, 2, RED)
    main(t)
    if n == 1 then
      play(t, z, "signi_center")
      pick(t, HINT_USE_TRIGGER, 1)
      pick(t, HINT_DISCARD, g)
      t:expect(t:wait(HINT_MAIN))
    end
    play(t, h)
    pick(t, HINT_USE_TRIGGER, 1)
    pay(t, 2)
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:count(0, "hand") == 2, n)
  end
end)

case("サンセツコン·フラムベ: 이 턴에 버렸으면 ＋7000·＋5000(나오기 전에 버린 것도)", "WDK06-R13 FAQ 1, WDK06-R15 FAQ 1", function(t)
  ril(t)
  local a, b = t:put(R[13], 0, "signi_left"), t:put(R[15], 0, "hand")
  local z, g = t:put(R[17], 0, "hand"), t:put(ARM, 0, "hand")
  main(t)
  t:expect(t:power(a) == 11000)
  play(t, z, "signi_center")
  pick(t, HINT_USE_TRIGGER, 1)
  pick(t, HINT_DISCARD, g)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:power(a) == 18000)
  play(t, b, "signi_right")
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:power(b) == 13000)
end)

case("トレット·ヌンチャ: ＜アーム＞를 버려 라이즈를 찾는다·2000 이하 바니시", "WDK06-R14, WDK06-R17", function(t)
  ril(t)
  local h, g, r = t:put(R[14], 0, "hand"), t:put(ARM, 0, "hand"), t:put(R[11], 0, "main_deck")
  local o = t:put(RED, 0, "hand")
  main(t)
  play(t, h)
  pick(t, HINT_USE_TRIGGER, 1)
  t:expect(t:wait(HINT_DISCARD))
  t:expect(#t:request().options == 1, "＜アーム＞만")
  t:expect(t:answer(g))
  pick(t, HINT_SELECT, r)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(r, 0, "hand") and t:is_in(o, 0, "hand"))
  ril(t)
  h, g = t:put(R[17], 0, "hand"), t:put(ARM, 0, "hand")
  local x = t:put(RED, 1, "signi_left")
  t:put(OPP, 1, "signi_center")
  main(t)
  play(t, h)
  pick(t, HINT_USE_TRIGGER, 1)
  pick(t, HINT_DISCARD, g)
  t:expect(t:wait(HINT_TARGET))
  t:expect(#t:request().options == 1)
  t:expect(t:answer(x))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(x, 1, "ena"))
end)

case("剣筋の見定め: 버릴 패가 없어도 2장 뽑는다", "WDK06-R20", function(t)
  for n = 0, 1 do
    ril(t)
    local sp, h = t:put(R[20], 0, "hand"), t:put(ARM, 0, "signi_left")
    local d = n == 1 and t:put(RED, 0, "hand")
    main(t)
    use(t, sp)
    pick(t, HINT_MODE, 0)
    pick(t, HINT_TARGET, h)
    if d then pick(t, HINT_DISCARD, d) end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(h, 0, "trash") and t:count(0, "hand") == 2)
  end
end)
