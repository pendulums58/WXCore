-- WD22 ウリス·グズ子 구축덱 카드 스크립트 케이스 + 【チャーム】 룰. 근거는 카드별 FAQ(cards.json)·용어집: チャーム

local N = {}
local AK, YU, YU3, BLK, OPP, BIG = 200000, 201000, 202000, 203000, 101000, 102000
local KIND = {}
for i = 1, 41 do
  KIND[i] = (i <= 6 or (i >= 17 and i <= 28)) and "U" or (i <= 12 or (i >= 29 and i <= 36)) and "G" or "UG"
end

local function wd(t, center, opp_center)
  t:start{db = true, seed = 1}
  for i = 1, 41 do N[i] = t:no(("WD22-%03d-%s"):format(i, KIND[i])) end
  t:card{cid = AK, power = 4000, level = 2, classes = {"精像：悪魔"}, color = COLOR_BLACK}
  t:card{cid = YU, power = 3000, level = 2, classes = {"精武：遊具"}, color = COLOR_BLACK}
  t:card{cid = YU3, power = 5000, level = 3, classes = {"精武：遊具"}, color = COLOR_BLACK}
  t:signi(BLK, 1000, COLOR_BLACK, 1)
  t:signi(OPP, 5000, COLOR_RED, 2)
  t:signi(BIG, 15000, COLOR_RED, 4)
  t:fill(BLK, 0, "main_deck", 15)
  t:fill(OPP, 1, "main_deck", 15)
  t:fill(BLK, 0, "life_cloth", 5)
  t:fill(OPP, 1, "life_cloth", 5)
  t:put(N[opp_center or 1], 1, "lrig_center")
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
  t:expect(t:wait(HINT_PAY_ENA))
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

local function zone(t)
  t:expect(t:wait(HINT_ZONE))
  t:expect(t:answer(t:request().options[1]))
end

local function charm(t, host)
  local c = t:put(BLK, 0, "hand")
  t:attach(c, host, "charm")
  return c
end

-- 상대 시그니가 빈 존으로 어택해 라이프의 c를 크러시하고 라이프 버스트를 쓴다
local function burst(t, c)
  t:move(c, 0, "life_cloth")
  local a = t:put(BIG, 1, "signi_right")
  t:begin(1, PHASE_ATTACK)
  pick(t, HINT_ATTACK_SIGNI, a)
  pick(t, HINT_LIFEBURST, 1)
end

-- ── ウリス＆グズ子 ──

case("ウリス＆グズ子: 시작할 때 루리그 타입을 고른다. グズ子면 코인 3개", "WD22-013", function(t)
  for i, c in ipairs{{4, 0}, {10, 3}} do
    wd(t)
    for p = 0, 1 do
      for _, z in ipairs{"lrig_center", "main_deck", "life_cloth"} do
        for _, x in ipairs(t:cards(p, z)) do t:move(x, p, "exclude") end
      end
      t:fill(BLK, p, "main_deck", 40)
    end
    local lr = t:put(N[13], 0, "lrig_deck")
    t:put(N[4], 0, "lrig_deck")
    t:put(N[10], 0, "lrig_deck")
    t:put(N[13], 1, "lrig_deck")
    t:start_game()
    for _ = 1, 2 do
      t:expect(t:wait(HINT_MODE))
      t:expect(t:answer(i - 1))
    end
    t:expect(t:wait(HINT_GROW))
    t:expect(t:coins(0) == c[2] and t:coins(1) == c[2])
    local o = t:request().options
    t:expect(#o == 1 and t:cid(o[1]) == N[c[1]], "고른 타입으로만 그로우")
  end
end)

-- ── 【チャーム】 ──

case("チャーム: 1체에 1장, 떠나면 트래시. 양쪽이 볼 수 있다", "용어집: チャーム", function(t)
  wd(t)
  local h = t:put(AK, 0, "signi_left")
  local c, d = charm(t, h), t:put(BLK, 0, "hand")
  t:attach(d, h, "charm")
  t:expect(t:can_see(1, c) and t:is_in(d, 0, "hand"), "두 장째는 붙지 않는다")
  local sp = t:put(N[15], 0, "lrig_deck")
  local x = t:put(OPP, 1, "signi_left")
  ena(t, 2)
  main(t)
  use(t, sp)
  pay(t, 2)
  pick(t, HINT_TARGET, x)
  pick(t, HINT_SELECT, h)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(h, 0, "trash") and t:is_in(c, 0, "trash") and t:is_in(x, 1, "ena"))
end)

case("パイモン: 효과 바니시 대신 チャーム. 대신하지 않을 수도 있다", "WD22-020 텍스트, FAQ 4", function(t)
  for _, yes in ipairs{1, 0} do
    wd(t)
    t:put(N[20], 0, "signi_center")
    local h = t:put(AK, 0, "signi_left")
    local c = charm(t, h)
    local sp, x = t:put(N[11], 0, "lrig_deck"), t:put(BLK, 0, "signi_right")
    ena(t, 4)
    main(t)
    use(t, sp)
    pick(t, HINT_MODE, 1)
    pay(t, 4)
    pick(t, HINT_SELECT, h, x)
    pick(t, HINT_SCRIPT, yes)
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(h, 0, yes == 1 and "signi_left" or "ena") and t:is_in(c, 0, "trash") and t:is_in(x, 0, "ena"))
    t:expect(t:count(0, "hand") == 2, "대신해도 「そうした場合」는 처리한다(WD22-011 FAQ 2)")
  end
end)

case("パイモン: 배틀에서도. 대신하면 【ランサー】로 크러시하지 않는다", "WD22-020 FAQ 2·6", function(t)
  for _, yes in ipairs{1, 0} do
    wd(t)
    local h = t:put(N[20], 0, "signi_left")
    charm(t, h)
    local a = t:put(BIG, 1, "signi_right")
    t:grant(a, EFFECT_LANCER, 0, 1)
    t:begin(1, PHASE_ATTACK)
    pick(t, HINT_ATTACK_SIGNI, a)
    pick(t, HINT_SCRIPT, yes)
    t:wait(HINT_ATTACK_LRIG)
    t:expect(t:is_in(h, 0, yes == 1 and "signi_left" or "ena") and t:count(0, "life_cloth") == 5 - (1 - yes))
  end
end)

case("パイモン: 파워 0이면 대신해도 곧 바니시된다", "WD22-020 FAQ 1", function(t)
  wd(t)
  local h = t:put(N[20], 0, "signi_left")
  charm(t, h)
  t:single(h, EFFECT_UPDATE_POWER, -12000, 1)
  local sp, y = t:put(N[41], 0, "hand"), t:put(BLK, 0, "trash")
  ena(t, 1)
  main(t)
  use(t, sp)
  pay(t, 1)
  pick(t, HINT_TARGET, y)
  pick(t, HINT_SCRIPT, 1)
  t:wait(HINT_MAIN)
  t:expect(t:is_in(h, 0, "ena"))
end)

case("パイモン: 【出】 덱 위를 チャーム으로. 하지 않아도 된다", "WD22-020", function(t)
  for _, yes in ipairs{1, 0} do
    wd(t)
    local h = t:put(N[20], 0, "hand")
    main(t)
    local n = t:count(0, "main_deck")
    play(t, h)
    pick(t, HINT_SCRIPT, yes)
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:count(0, "main_deck") == n - yes)
  end
end)

case("アリトン: 패·덱에서 트래시에 놓이면 チャーム으로. 한정 조건과 관계없다", "WD22-026 FAQ 2·3", function(t)
  wd(t, 7)
  local h, x = t:put(AK, 0, "signi_left"), t:put(N[26], 0, "hand")
  local s = t:put(N[38], 0, "hand")  -- 【出】 덱 위 5장을 트래시에
  t:move(x, 0, "main_deck")
  main(t)
  play(t, s, "signi_center")
  pick(t, HINT_TARGET, h)
  pick(t, HINT_SCRIPT, 1)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:at(x) ~= "trash" and t:count(0, "trash") == 4)
end)

case("バイオレンス・ジェラシー: 트래시에서 チャーム을 코스트로 패에. 스펠 컷인은 없다", "WD22-028 FAQ 1~3", function(t)
  wd(t)
  local sp, h = t:put(N[28], 0, "trash"), t:put(AK, 0, "signi_left")
  main(t)
  t:expect(ability(t, sp) == nil)
  wd(t)
  sp, h = t:put(N[28], 0, "trash"), t:put(AK, 0, "signi_left")
  local c = charm(t, h)
  main(t)
  t:expect(t:answer(ability(t, sp)))
  pick(t, HINT_SELECT, c)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(sp, 0, "hand") and t:is_in(c, 0, "trash"))
end)

-- ── ウリス 루리그·아츠 ──

case("紅蓮の閻魔 ウリス: 【出】은 코스트로 놓인 시그니도 대상", "WD22-001 FAQ 1", function(t)
  wd(t, 2)
  local g = t:put(N[1], 0, "lrig_deck")
  ena(t, 4)
  t:begin(0, PHASE_GROW)
  pick(t, HINT_GROW, g)
  pay(t, 3)
  pick(t, HINT_USE_TRIGGER, 1)
  local last = t:cards(0, "ena")[1]
  pay(t, 1)
  pick(t, HINT_TARGET, last)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(last, 0, "hand"))
end)

case("紅蓮の閻魔 ウリス: 【起】 흑 2장 버려 바니시, エクシード2로 라이프", "WD22-001", function(t)
  local lc = wd(t)
  for _ = 1, 2 do t:put_under(t:put(N[2], 0, "lrig_deck"), lc) end
  local a, b, x = t:put(BLK, 0, "hand"), t:put(BLK, 0, "hand"), t:put(BIG, 1, "signi_left")
  local h = t:put(BLK, 0, "signi_left")
  main(t)
  t:expect(t:answer(ability(t, lc, 0)))
  pick(t, HINT_DISCARD, a, b)
  pick(t, HINT_TARGET, x)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(x, 1, "ena") and t:count(0, "hand") == 0)
  t:expect(t:answer(ability(t, lc, 0)))  -- 이제 버릴 패가 없어 엑시드가 첫 선택지
  if t:wait(HINT_EXCEED) then t:expect(t:answer(table.unpack(t:under(lc)))) end
  pick(t, HINT_SELECT, h)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(h, 0, "trash") and t:count(0, "life_cloth") == 6)
end)

case("ウリス 레벨 1~3: 코인. 레벨 1은 1장 버린다", "WD22-002~004 FAQ", function(t)
  for _, c in ipairs{{2, 3, 2, 2}, {3, 4, 1, 1}, {4, 0, 0, 1}} do
    local lc = wd(t, c[2] > 0 and c[2] or 13)
    if c[2] == 0 then
      t:script(300001, [[
local s,id=GetID()
function s.initial_effect(c)
  Duel.SetLrigType(c,LRIG_URITH)
end]])
      t:card{cid = 300001, type = TYPE_LRIG, level = 0, color = COLOR_BLACK}
      t:move(lc, 0, "exclude")
      t:put(300001, 0, "lrig_center")
    end
    local g, h = t:put(N[c[1]], 0, "lrig_deck"), t:put(BLK, 0, "hand")
    ena(t, c[3])
    t:begin(0, PHASE_GROW)
    pick(t, HINT_GROW, g)
    if c[3] > 0 then pay(t, c[3]) end
    if c[2] == 0 then pick(t, HINT_DISCARD, h) end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:coins(0) == c[4] and t:count(0, "hand") == (c[2] == 0 and 0 or 1))
  end
end)

case("フォーカラー・マイアズマ: ウリス면 3개까지, 아니면 2개까지. 코스트 흑2 무2", "WD22-005 FAQ 1", function(t)
  for _, c in ipairs{{1, 3}, {7, 2}} do
    wd(t, c[1])
    local a = t:put(N[5], 0, "lrig_deck")
    ena(t, 4)
    main(t)
    use(t, a)
    t:expect(t:wait(HINT_MODE))
    t:expect(t:request().min == 1 and t:request().max == c[2])
    t:expect(not t:answer(0, 0), "같은 모드를 두 번")
    t:expect(t:answer(3))
    pay(t, 4)
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:count(0, "trash") == 11 and t:count(1, "trash") == 7)
  end
end)

case("フォーカラー・マイアズマ: 위에서부터 처리하고 룰 처리는 끝난 뒤", "WD22-005 FAQ 2·4", function(t)
  wd(t)
  local a = t:put(N[5], 0, "lrig_deck")
  local x, tr = t:put(OPP, 1, "signi_left"), t:put(AK, 0, "trash")
  ena(t, 4)
  main(t)
  use(t, a)
  pick(t, HINT_MODE, 0, 1, 3)
  pay(t, 4)
  pick(t, HINT_TARGET, x)
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(tr))
  zone(t)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(x, 1, "ena") and t:count(1, "trash") == 7 and t:at(tr) ~= "trash")
end)

case("バイオ・ハザード: 베트하면 흑 시그니 2장", "WD22-014 FAQ 1", function(t)
  for _, yes in ipairs{0, 1} do
    wd(t)
    t:add_coin(0, 2)
    local a = t:put(N[14], 0, "lrig_deck")
    local x, y = t:put(AK, 0, "trash"), t:put(YU, 0, "trash")
    ena(t, 3)
    main(t)
    use(t, a)
    pick(t, HINT_BET, yes)
    pay(t, 3)
    if yes == 1 then pick(t, HINT_TARGET, x, y) else pick(t, HINT_TARGET, x) end
    for _ = 0, yes do zone(t) end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:at(x) ~= "trash" and (t:at(y) ~= "trash") == (yes == 1))
  end
end)

case("バッド・エクシード: 밑에 4장이 있어야 낸다", "WD22-016 FAQ 1", function(t)
  for _, n in ipairs{4, 3} do
    local lc = wd(t)
    for _ = 1, n do t:put_under(t:put(N[2], 0, "lrig_deck"), lc) end
    local a, x = t:put(N[16], 0, "lrig_deck"), t:put(AK, 0, "trash")
    main(t)
    use(t, a)
    pick(t, HINT_TARGET, x)
    if n == 4 then
      pick(t, HINT_SELECT, table.unpack(t:under(lc)))
      zone(t)
    end
    t:expect(t:wait(HINT_MAIN))
    t:expect((t:at(x) ~= "trash") == (n == 4) and #t:under(lc) == (n == 4 and 0 or 3))
  end
end)

-- ── ウリス 시그니 ──

case("ディアボロス: 【出】 패가 모자라면 있는 만큼, 【起】로 레벨 −1, 【自】 레벨 3 이하 바니시", "WD22-018 FAQ 1", function(t)
  wd(t)
  local h, x = t:put(N[18], 0, "hand"), t:put(BIG, 1, "signi_left")
  local one = t:put(BLK, 0, "hand")
  ena(t, 1)
  main(t)
  play(t, h)
  pick(t, HINT_DISCARD, one)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "hand") == 0)
  t:expect(t:answer(ability(t, h)))
  pay(t, 1)
  pick(t, HINT_TARGET, x)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:level(x) == 3)
  pick(t, HINT_ATTACK_SIGNI, h)
  pick(t, HINT_TARGET, x)
  t:wait(HINT_ATTACK_LRIG)
  t:expect(t:is_in(x, 1, "ena"))
end)

case("ディアボロス: 레벨은 0 미만이 되지 않는다", "WD22-018", function(t)
  wd(t)
  local x = t:put(BLK, 1, "signi_left")
  for _ = 1, 3 do t:single(x, EFFECT_UPDATE_LEVEL, -1, 0) end
  t:expect(t:level(x) == 0)
end)

case("ディアボロス: LB 레벨 합계 3 이하로 고른다", "WD22-018", function(t)
  wd(t)
  local c = t:put(N[18], 0, "hand")
  local x, y = t:put(OPP, 1, "signi_left"), t:put(BLK, 1, "signi_center")
  burst(t, c)
  t:expect(t:wait(HINT_TARGET))
  t:expect(not t:answer(t:cards(1, "signi_right")[1], y), "4 + 1")
  t:expect(t:answer(x, y))
  t:wait(HINT_ATTACK_LRIG)
  t:expect(t:is_in(x, 1, "ena") and t:is_in(y, 1, "ena"))
end)

case("シヴァ: 패 0장이면 18000과 【起】, 4장 이상 버리면 라이프", "WD22-019", function(t)
  for _, n in ipairs{4, 3} do
    wd(t)
    local h, x = t:put(N[19], 0, "signi_left"), t:put(BIG, 1, "signi_left")
    t:fill(BLK, 0, "hand", n)
    t:expect(t:power(h) == 12000)
    main(t)
    t:expect(t:answer(ability(t, h, 0)))
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:count(0, "hand") == 0 and t:count(0, "life_cloth") == (n == 4 and 6 or 5) and t:power(h) == 18000)
    t:expect(t:answer(ability(t, h, 0)))
    pick(t, HINT_TARGET, x)
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:power(x) == 5000)
  end
end)

case("シヴァ: LB 패를 모두 버리고 흑 시그니 3장까지", "WD22-019", function(t)
  wd(t)
  local a, b = t:put(BLK, 0, "hand"), t:put(OPP, 0, "hand")
  burst(t, t:put(N[19], 0, "hand"))
  t:expect(t:wait(HINT_TARGET))
  t:expect(#t:request().options == 1, "방금 버린 흑 시그니")
  t:expect(t:answer(a))
  t:wait(HINT_ATTACK_LRIG)
  t:expect(t:is_in(a, 0, "hand") and t:is_in(b, 0, "trash"))
end)

case("ミリア: 10장 놓으면 흑 시그니 5장을 덱으로. 리프레시하지 않는다", "WD22-021 FAQ 3·4", function(t)
  wd(t)
  local h = t:put(N[21], 0, "hand")
  for i, c in ipairs(t:cards(0, "main_deck")) do if i > 10 then t:move(c, 0, "exclude") end end
  main(t)
  play(t, h)
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:request().min == 5 and t:request().max == 5)
  t:expect(t:answer(table.unpack(t:cards(0, "trash"), 1, 5)))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "main_deck") == 5 and t:count(0, "trash") == 5 and t:refreshes(0) == 0)
end)

case("ミリア: 흑 시그니가 5장이 안 되면 1장도 돌리지 않는다", "WD22-021 FAQ 1·5", function(t)
  wd(t)
  local h = t:put(N[21], 0, "hand")
  for _, c in ipairs(t:cards(0, "main_deck")) do t:move(c, 0, "exclude") end
  t:fill(OPP, 0, "main_deck", 8)
  t:fill(BLK, 0, "main_deck", 4)
  main(t)
  play(t, h)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "trash") == 10 and t:count(0, "main_deck") == 2 and not t:saw(HINT_TARGET))
end)

case("ケルべルン: 가운데 존이고 센터가 검정일 때만 어택하면 −3000", "WD22-022", function(t)
  for _, z in ipairs{"signi_center", "signi_left"} do
    wd(t)
    local h, x = t:put(N[22], 0, z), t:put(BIG, 1, "signi_right")
    t:begin(0, PHASE_ATTACK)
    pick(t, HINT_ATTACK_SIGNI, h)
    if z == "signi_center" then pick(t, HINT_TARGET, x) end
    t:wait(HINT_ATTACK_LRIG)
    t:expect(t:power(x) == (z == "signi_center" and 12000 or 15000))
  end
end)

case("ベルフェーゴ: ＜悪魔＞를 찾아 트래시에. 찾지 않아도 된다", "WD22-023 FAQ 1", function(t)
  for _, on in ipairs{true, false} do
    wd(t)
    local h, x = t:put(N[23], 0, "hand"), t:put(AK, 0, "main_deck")
    main(t)
    play(t, h)
    t:expect(t:wait(HINT_SELECT))
    if on then t:expect(t:answer(x)) else t:expect(t:answer()) end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(x, 0, on and "trash" or "main_deck"))
  end
end)

case("イフリード: 덱에서 트래시에 놓이면 −2000. 한정 조건과 관계없다", "WD22-024 FAQ 1", function(t)
  wd(t, 7)
  local i, s, x = t:put(N[24], 0, "main_deck"), t:put(N[38], 0, "hand"), t:put(OPP, 1, "signi_left")
  main(t)
  play(t, s)
  pick(t, HINT_TARGET, x)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(i, 0, "trash") and t:power(x) == 3000)
end)

case("イフリード: 어택 페이즈에 트래시의 4장을 제외하고 −15000", "WD22-024", function(t)
  wd(t, 7)
  local list = {}
  for k = 1, 4 do list[k] = t:put(N[24], 0, "trash") end
  local x = t:put(BIG, 1, "signi_left")
  main(t)
  t:expect(ability(t, list[1]) == nil)
  t:expect(t:answer(t:action(ACT_END)))
  t:expect(t:wait(HINT_PRE_ATTACK))
  t:expect(t:answer(ability(t, list[1])))
  if t:wait(HINT_SELECT) then t:expect(t:answer(table.unpack(list))) end
  pick(t, HINT_TARGET, x)
  t:wait(HINT_ATTACK_LRIG)
  t:expect(t:is_in(x, 1, "ena") and t:is_in(list[1], 0, "exclude") and t:count(0, "trash") == 0)
end)

-- ── グズ子 루리그·아츠 ──

case("グズ子: 트래시에서 나온 ＜遊具＞를 놓고 바니시. 안 써도 그 턴에는 끝", "WD22-007 FAQ 2·3", function(t)
  for _, yes in ipairs{1, 0} do
    wd(t, 8)
    local g = t:put(N[7], 0, "lrig_deck")
    t:add_coin(0, 1)
    ena(t, 5)
    local a, b, x = t:put(YU, 0, "trash"), t:put(YU3, 0, "trash"), t:put(BIG, 1, "signi_left")
    t:begin(0, PHASE_GROW)
    pick(t, HINT_GROW, g)
    pay(t, 3)
    pick(t, HINT_USE_TRIGGER, 1)
    pick(t, HINT_TARGET, a, b)
    zone(t)
    zone(t)
    if t:wait(HINT_TRIGGER_ORDER) then t:expect(t:answer(t:request().options[1])) end
    t:expect(t:saw(HINT_MAIN) == false)
    pick(t, HINT_TARGET, x)
    pick(t, HINT_SCRIPT, yes)
    if yes == 1 then pay(t, 1) end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(x, 1, yes == 1 and "ena" or "signi_left"))
    t:expect(t:count(0, "trash") == (yes == 1 and 5 or 3), "한 번만")
  end
end)

case("グズ子: チョウハン은 제외돼도 바니시한다", "WD22-007 FAQ 5, WD22-035 FAQ 1", function(t)
  wd(t, 7)
  t:put(BLK, 0, "signi_left")
  t:put(BLK, 0, "signi_center")
  local c, x = t:put(N[35], 0, "trash"), t:put(BIG, 1, "signi_left")
  ena(t, 1)
  t:begin(1, PHASE_ATTACK)
  pick(t, HINT_SCRIPT, 1)
  zone(t)
  pick(t, HINT_TARGET, x)
  pick(t, HINT_SCRIPT, 1)
  pay(t, 1)
  t:wait(HINT_ATTACK_LRIG)
  t:expect(t:is_in(c, 0, "exclude") and t:is_in(x, 1, "ena"))
end)

case("チョウハン: 시그니가 꼭 2체일 때만. 턴 종료 시에 제외", "WD22-035 FAQ 1·2", function(t)
  for _, n in ipairs{2, 1, 3} do
    wd(t, 8)
    t:signi(OPP, 100, COLOR_RED, 1)
    for i, z in ipairs{"signi_left", "signi_center", "signi_right"} do if i <= n then t:put(BIG, 0, z) end end
    for _, z in ipairs{"signi_left", "signi_center", "signi_right"} do
      for _, x in ipairs(t:cards(0, z)) do t:move(x, 0, "exclude") t:put(BLK, 0, z) end
    end
    local c, d = t:put(N[35], 0, "trash"), t:put(N[35], 0, "trash")
    t:begin(1, PHASE_ATTACK)
    if n == 2 then
      pick(t, HINT_TRIGGER_ORDER, t:request() and t:request().options[1] or 0)
      pick(t, HINT_SCRIPT, 1)
      zone(t)
    end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:turn_player() == 0)
    t:expect(t:count(0, "exclude") - n == (n == 2 and 1 or 0), n)
    t:expect(t:count(0, "trash") == (n == 2 and 1 or 2))
  end
end)

case("グズ子 레벨 1: 1장 버려 코인. 쓰지 않아도 된다", "WD22-010 FAQ 1", function(t)
  for _, yes in ipairs{1, 0} do
    local lc = wd(t, 13)
    t:script(300001, [[
local s,id=GetID()
function s.initial_effect(c)
  Duel.SetLrigType(c,LRIG_GUZUKO)
end]])
    t:card{cid = 300001, type = TYPE_LRIG, level = 0, color = COLOR_BLACK}
    t:move(lc, 0, "exclude")
    t:put(300001, 0, "lrig_center")
    local g, h = t:put(N[10], 0, "lrig_deck"), t:put(BLK, 0, "hand")
    t:begin(0, PHASE_GROW)
    pick(t, HINT_GROW, g)
    pick(t, HINT_USE_TRIGGER, yes)
    if yes == 1 then pick(t, HINT_DISCARD, h) end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:coins(0) == yes and t:count(0, "hand") == 1 - yes)
  end
end)

case("フーリッシュ・マイアズマ: ②로 뽑은 뒤의 패를 ③이 센다", "WD22-011 FAQ 4", function(t)
  wd(t)
  local a, x = t:put(N[11], 0, "lrig_deck"), t:put(OPP, 1, "signi_left")
  local p, q = t:put(BLK, 0, "signi_left"), t:put(BLK, 0, "signi_center")
  ena(t, 4)
  main(t)
  use(t, a)
  pick(t, HINT_MODE, 1, 2)
  pay(t, 4)
  pick(t, HINT_TARGET, x)
  pick(t, HINT_SELECT, p, q)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "hand") == 2 and t:is_in(x, 1, "ena"), "레벨 2 ≤ 패 2장")
end)

case("フーリッシュ・マイアズマ: ①과 ④를 고르면 ④로 나온 시그니에도 발동", "WD22-011 FAQ 5", function(t)
  wd(t)
  local a, x, tr = t:put(N[11], 0, "lrig_deck"), t:put(BIG, 1, "signi_left"), t:put(AK, 0, "trash")
  ena(t, 4)
  main(t)
  use(t, a)
  pick(t, HINT_MODE, 0, 3)
  pay(t, 4)
  pick(t, HINT_TARGET, tr)
  zone(t)
  pick(t, HINT_TARGET, x)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:power(x) == 8000)
end)

case("バッド・トイ: 한쪽만 있어도 처리한다. 베트하면 레벨 제한이 없다", "WD22-012 FAQ 1·2", function(t)
  for _, c in ipairs{{0, true, false}, {0, false, true}, {1, true, true}} do  -- {베트, 상대 시그니, 트래시}
    wd(t, 7)
    t:add_coin(0, 1)
    local a = t:put(N[12], 0, "lrig_deck")
    local x = c[2] and t:put(c[1] == 1 and BIG or OPP, 1, "signi_left")
    local y = c[3] and t:put(c[1] == 1 and YU3 or YU, 0, "trash")
    ena(t, 1)
    main(t)
    use(t, a)
    pick(t, HINT_BET, c[1])
    pay(t, 1)
    if x then pick(t, HINT_TARGET, x) end
    if y then
      pick(t, HINT_TARGET, y)
      zone(t)
    end
    t:wait(HINT_MAIN)
    if x then t:expect(t:is_in(x, 1, "trash")) end
    if y then t:expect(t:at(y) ~= "trash") end
  end
end)

-- ── グズ子 시그니 ──

case("マージャン: 상대 어택 페이즈에 상대가 1장 뽑을 때마다 다운", "WD22-029 FAQ 1", function(t)
  wd(t, 7)
  t:script(300000, [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg,ep) return ep==tp end)
  e1:SetOperation(function(e,tp) Duel.Draw(tp,2) end)
  c:RegisterEffect(e1)
end]])
  t:signi(300000, 1000, COLOR_RED, 1)
  t:put(N[29], 0, "signi_left")
  local x, y = t:put(300000, 1, "signi_left"), t:put(OPP, 1, "signi_center")
  t:begin(1, PHASE_ATTACK)
  pick(t, HINT_TARGET, x)
  pick(t, HINT_TARGET, y)
  t:wait(HINT_MAIN)
  t:expect(t:flags(x) & CF_DOWN ~= 0 and t:flags(y) & CF_DOWN ~= 0 and t:count(0, "life_cloth") == 5)
end)

case("マージャン: 어택하면 내 시그니를 놓고 정면을 트래시해 데미지. 자신을 놓으면 데미지가 없다", "WD22-029 FAQ 2·3", function(t)
  for _, self in ipairs{false, true} do
    wd(t, 7)
    local h, x = t:put(N[29], 0, "signi_left"), t:put(BIG, 1, "signi_right")
    local y = t:put(BLK, 0, "signi_center")
    t:begin(0, PHASE_ATTACK)
    pick(t, HINT_ATTACK_SIGNI, h)
    pick(t, HINT_TARGET, x)
    pick(t, HINT_SELECT, self and h or y)
    t:wait(HINT_ATTACK_LRIG)
    t:expect(t:is_in(x, 1, "trash") and t:is_in(self and h or y, 0, "trash"))
    t:expect(t:count(1, "life_cloth") == (self and 5 or 4))
  end
end)

case("アナベル: 놓은 자신도 다운으로 낼 수 있다", "WD22-030 FAQ 1", function(t)
  wd(t, 8)
  local h, x = t:put(N[30], 0, "signi_left"), t:put(OPP, 1, "signi_right")
  ena(t, 1)
  t:begin(0, PHASE_ATTACK)
  pick(t, HINT_ATTACK_SIGNI, h)
  pick(t, HINT_SCRIPT, 1)
  pay(t, 1)
  pick(t, HINT_TARGET, h)
  zone(t)
  t:wait(HINT_ATTACK_LRIG)
  t:expect(t:is_in(x, 1, "ena") and t:at(h) ~= "trash" and t:flags(h) & CF_DOWN ~= 0)
end)

case("サラマワ·シガボス: 시그니의 효과로 나왔을 때만", "WD22-031, WD22-033", function(t)
  for _, c in ipairs{{31, 8000}, {33, 12000}} do
    wd(t, 8)
    local h, s, x = t:put(N[c[1]], 0, "trash"), t:put(N[32], 0, "hand"), t:put(BIG, 1, "signi_left")
    ena(t, 1)
    main(t)
    play(t, s)
    pick(t, HINT_USE_TRIGGER, 1)
    pay(t, 1)
    pick(t, HINT_TARGET, h)
    zone(t)
    pick(t, HINT_TARGET, x)
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:power(x) == c[2] and t:flags(h) & CF_DOWN ~= 0)
    wd(t, 8)
    h, x = t:put(N[c[1]], 0, "hand"), t:put(BIG, 1, "signi_left")
    main(t)
    play(t, h)
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:power(x) == 15000)
  end
end)

case("チャッキー·ワラニン: 코스트로 놓인 시그니도 낼 수 있다", "WD22-032 FAQ 1, WD22-034 FAQ 1", function(t)
  for _, c in ipairs{{32, YU3}, {34, YU}} do
    wd(t, 8)
    local h, y = t:put(N[c[1]], 0, "hand"), t:put(c[2], 0, "ena")
    main(t)
    play(t, h)
    pick(t, HINT_USE_TRIGGER, 1)
    pay(t, 1)
    pick(t, HINT_TARGET, y)
    zone(t)
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:at(y) ~= "trash" and t:flags(y) & CF_DOWN ~= 0)
  end
end)

case("ペイン・バイ・ペイン: ① 5장에서 ＜遊具＞를 패나 장에, 덱이 모자라도 리프레시하지 않는다", "WD22-036 FAQ 2", function(t)
  for _, to in ipairs{0, 1} do
    wd(t, 7)
    for _, c in ipairs(t:cards(0, "main_deck")) do t:move(c, 0, "exclude") end
    t:fill(BLK, 0, "main_deck", 2)
    local y, sp, h = t:put(YU3, 0, "main_deck"), t:put(N[36], 0, "hand"), t:put(YU, 0, "signi_left")
    main(t)
    use(t, sp)
    pick(t, HINT_MODE, 0)
    pick(t, HINT_TARGET, h)
    pick(t, HINT_SELECT, y)
    pick(t, HINT_MODE, to)
    if to == 1 then zone(t) end
    t:expect(t:wait(HINT_ORDER))
    t:expect(t:answer(table.unpack(t:request().options)))
    t:wait(HINT_MAIN)
    t:expect(t:is_in(h, 0, "ena") and t:is_in(y, 0, "hand") == (to == 0) and t:count(0, "main_deck") == 2 and t:refreshes(0) == 0)
  end
end)

case("ペイン・バイ・ペイン: ② 트래시의 ＜遊具＞ 5장까지 덱으로", "WD22-036 FAQ 1", function(t)
  wd(t, 7)
  local sp, h = t:put(N[36], 0, "hand"), t:put(YU, 0, "signi_left")
  local a, b = t:put(YU, 0, "trash"), t:put(YU3, 0, "trash")
  main(t)
  use(t, sp)
  pick(t, HINT_MODE, 1)
  pick(t, HINT_TARGET, h)
  pick(t, HINT_TARGET, a, b)
  t:wait(HINT_MAIN)
  t:expect(t:is_in(h, 0, "ena") and t:is_in(a, 0, "main_deck") and t:is_in(b, 0, "main_deck"))
end)

-- ── 공용 ──

-- src: 1 시그니(チャッキー), 2 아츠(バイオ・ハザード), 3 스펠(リバース・キス), 4 루리그(グズ子)
case("ルーレット: 나오게 한 효과의 종류로 처리가 갈린다", "WD22-037", function(t)
  for src = 1, 4 do
    wd(t, src == 4 and 8 or 1)
    local rl = t:put(N[37], 0, "trash")
    local y, x = t:put(BLK, 0, "trash"), t:put(BIG, 1, "signi_left")
    t:script(300000, [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp) Duel.PutOnField(Duel.GetFirstTarget(),tp) end)
  c:RegisterEffect(e1)
end]])
    t:signi(300000, 1000, COLOR_BLACK, 1)
    if src == 1 then
      local h = t:put(300000, 0, "hand")
      main(t)
      play(t, h)
      pick(t, HINT_TARGET, rl)
    elseif src == 2 then
      local a = t:put(N[14], 0, "lrig_deck")
      ena(t, 3)
      main(t)
      use(t, a)
      pay(t, 3)
      pick(t, HINT_TARGET, rl)
    elseif src == 3 then
      local sp = t:put(N[41], 0, "hand")
      ena(t, 4)
      main(t)
      use(t, sp)
      pay(t, 1)
      pick(t, HINT_TARGET, rl)
    else
      local g = t:put(N[7], 0, "lrig_deck")
      t:add_coin(0, 1)
      ena(t, 3)
      t:begin(0, PHASE_GROW)
      pick(t, HINT_GROW, g)
      pay(t, 3)
      pick(t, HINT_USE_TRIGGER, 1)
      pick(t, HINT_TARGET, rl)
    end
    zone(t)
    -- 남은 요청: 순서는 아무거나, 대상은 x·y, 코스트는 낸다
    for _ = 1, 20 do
      local rq
      t:step()
      rq = t:request()
      if not rq or rq.hint == HINT_MAIN then break end
      if rq.hint == HINT_TARGET then
        local ok = false
        for _, o in ipairs(rq.options) do if o == x then ok = true end end
        t:answer(ok and x or y)
      elseif rq.hint == HINT_USE_TRIGGER then t:answer(1)
      elseif rq.hint == HINT_SCRIPT then t:answer(0)
      elseif rq.hint == HINT_PAY_ENA then t:answer(table.unpack(t:cards(0, "ena"), 1, rq.min))
      else t:answer(table.unpack(rq.options, 1, rq.min)) end
    end
    t:expect(t:power(x) == (src == 1 and 3000 or 15000), "시그니의 효과 " .. src)
    t:expect(t:is_in(y, 0, "hand") == (src == 2 or src == 4), "아츠·루리그의 효과 " .. src)
    t:expect(t:count(0, "life_cloth") == (src == 3 and 6 or 5), "스펠의 효과 " .. src)
  end
end)

case("スロット: 트래시 15장이면 12000, 【出】 뒤 20장이면 레벨 2 이하를 다운으로", "WD22-038 FAQ 1", function(t)
  for _, n in ipairs{15, 14} do
    wd(t)
    t:fill(BLK, 0, "trash", n)
    local h = t:put(N[38], 0, "hand")
    main(t)
    play(t, h)
    if n == 15 then
      local y = t:cards(0, "trash")[1]
      pick(t, HINT_TARGET, y)
      zone(t)
    end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:power(h) == 12000 and t:count(0, "trash") == (n == 15 and 19 or 19))
  end
end)

case("リバース・キス: 트래시 25장이면 코스트가 없다", "WD22-041", function(t)
  for _, n in ipairs{25, 24} do
    wd(t)
    t:fill(BLK, 0, "trash", n)
    local sp = t:put(N[41], 0, "hand")
    main(t)
    t:expect((t:action(ACT_USE, sp) ~= nil) == (n == 25))
    if n == 25 then
      local y = t:cards(0, "trash")[1]
      use(t, sp)
      pick(t, HINT_TARGET, y)
      zone(t)
      t:expect(t:wait(HINT_MAIN))
      t:expect(t:at(y) ~= "trash")
    end
  end
end)
