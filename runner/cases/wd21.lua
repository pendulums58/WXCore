-- WD21 カーニバル 구축덱 카드 스크립트 케이스. 근거는 카드별 FAQ(cards.json)

local N = {}
local U = {}  -- ＜宇宙＞ 레벨별
local RED, OPP, BIG = 201000, 101000, 102000

local function wd(t, center)
  t:start{db = true, seed = 1}
  for i = 1, 20 do
    local no = ("%03d"):format(i)
    N[no] = t:no("WD21-" .. no)
  end
  for lv = 1, 5 do
    U[lv] = 200000 + lv
    t:card{cid = U[lv], power = 4000, level = lv, classes = {"精羅：宇宙"}, color = COLOR_RED}
  end
  t:signi(RED, 1000, COLOR_RED, 1)
  t:signi(OPP, 3000, COLOR_GREEN, 1)
  t:signi(BIG, 15000, COLOR_GREEN, 3)
  t:fill(RED, 0, "main_deck", 12)
  t:fill(OPP, 1, "main_deck", 12)
  t:fill(RED, 0, "life_cloth", 5)
  t:fill(OPP, 1, "life_cloth", 5)
  t:put(N["001"], 1, "lrig_center")
  return t:put(N[center or "001"], 0, "lrig_center")
end

local function main(t, p)
  t:begin(p or 0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
end

local function ena(t, n)
  for _ = 1, n do t:put(RED, 0, "ena") end
end

local function pay(t, n)
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:request().min == n, "코스트 " .. n)
  t:expect(t:answer(table.unpack(t:cards(0, "ena"), 1, n)))
end

local function use(t, c) t:expect(t:answer(t:action(ACT_USE, c))) end

local function pick(t, hint, ...)
  t:expect(t:wait(hint))
  t:expect(t:answer(...))
end

-- 덱을 cid만으로 채운다
local function deck(t, cid, n)
  for _, c in ipairs(t:cards(0, "main_deck")) do t:move(c, 0, "exclude") end
  t:fill(cid, 0, "main_deck", n or 12)
end

local function grow(t, no, from, cost)
  wd(t, from)
  local g = t:put(N[no], 0, "lrig_deck")
  ena(t, cost)
  return g
end

-- ── 루리그 ──

case("カーニバルQA: 공개한 시그니의 레벨대로 얻는다. 레벨 5·스펠이면 아무 일도 없다", "WD21-001 FAQ 1·3·5", function(t)
  for lv, code in pairs{EFFECT_DOUBLE_CRUSH, EFFECT_ASSASSIN, EFFECT_LANCER, EFFECT_CANNOT_BANISH, 0, 0} do
    wd(t)
    deck(t, lv <= 5 and U[lv] or N["020"])
    local h = t:put(RED, 0, "signi_left")
    t:begin(0, PHASE_ATTACK)
    pick(t, HINT_TARGET, h)
    t:expect(t:wait(HINT_ATTACK_SIGNI))
    for _, c in ipairs{EFFECT_DOUBLE_CRUSH, EFFECT_ASSASSIN, EFFECT_LANCER, EFFECT_CANNOT_BANISH} do
      t:expect(t:keyword(h, c) == (c == code), lv)
    end
    t:expect(t:count(0, "main_deck") == 12)
  end
end)

case("カーニバルQA: 시그니가 없어도 공개한다", "WD21-001 FAQ 4", function(t)
  wd(t)
  deck(t, U[1], 1)
  local c = t:cards(0, "main_deck")[1]
  t:begin(0, PHASE_ATTACK)
  t:expect(t:wait(HINT_ATTACK_LRIG))
  t:expect(t:can_see(1, c))
end)

case("カーニバルQA: 《チドウ》가 있으면 레벨을 하나 고른다", "WD21-001 FAQ 2", function(t)
  wd(t)
  deck(t, U[1])
  local h = t:put(N["012"], 0, "signi_left")
  t:begin(0, PHASE_ATTACK)
  pick(t, HINT_TARGET, h)
  t:expect(t:wait(HINT_DECLARE))
  t:expect(#t:request().options == 4)
  t:expect(t:answer(3))
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:keyword(h, EFFECT_LANCER) and not t:keyword(h, EFFECT_DOUBLE_CRUSH))
end)

case("カーニバルQA: 【出】 코인 2개로 레벨만큼 뽑는다. 쓰지 않아도 된다", "WD21-001 FAQ 5·6", function(t)
  for _, c in ipairs{{1, 3, 3}, {0, 3, 0}, {1, 0, 0}} do
    local g = grow(t, "001", "002", 3)
    deck(t, c[2] > 0 and U[c[2]] or N["020"])
    t:add_coin(0, 2)
    t:begin(0, PHASE_GROW)
    pick(t, HINT_GROW, g)
    pay(t, 3)
    pick(t, HINT_USE_TRIGGER, c[1])
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:count(0, "hand") == c[3] and t:coins(0) == 2 - 2 * c[1])
  end
end)

case("カーニバル 레벨 1~3", "WD21-002~004", function(t)
  local g = grow(t, "002", "003", 3)
  t:begin(0, PHASE_GROW)
  pick(t, HINT_GROW, g)
  pay(t, 2)
  pick(t, HINT_USE_TRIGGER, 1)
  pay(t, 1)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:coins(0) == 1)
  g = grow(t, "003", "004", 1)
  t:begin(0, PHASE_GROW)
  pick(t, HINT_GROW, g)
  pay(t, 1)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:coins(0) == 1)
  g = grow(t, "004", "005", 0)
  t:add_coin(0, 1)
  t:begin(0, PHASE_GROW)
  pick(t, HINT_GROW, g)
  pick(t, HINT_USE_TRIGGER, 1)
  t:expect(t:wait(HINT_SELECT))
  t:expect(t:request().player == 1)
  t:expect(t:answer(t:cards(0, "hand")[1]))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "hand") == 1 and t:count(0, "trash") == 1)
end)

-- ── 아츠 ──

case("霹靂閃炎: 바니시하면 센터 루리그 밑에, 못 하면 루리그 트래시에", "WD21-006 FAQ 1", function(t)
  for _, on in ipairs{true, false} do
    local lc = wd(t)
    local a = t:put(N["006"], 0, "lrig_deck")
    local x = on and t:put(BIG, 1, "signi_left")
    ena(t, 3)
    main(t)
    use(t, a)
    pay(t, 3)
    if on then pick(t, HINT_TARGET, x) end
    t:expect(t:wait(HINT_MAIN))
    t:expect(#t:under(lc) == (on and 1 or 0) and t:count(0, "lrig_trash") == (on and 0 or 1))
    if on then t:expect(t:is_in(x, 1, "ena") and t:under(lc)[1] == a) end
  end
end)

case("自由自罪: 베트하면 한 번 더. 같은 시그니에 둘, 상대 시그니에도", "WD21-007 FAQ 1·2", function(t)
  for _, same in ipairs{true, false} do
    wd(t)
    local a = t:put(N["007"], 0, "lrig_deck")
    t:add_coin(0, 2)
    ena(t, 2)
    local h, x = t:put(RED, 0, "signi_left"), t:put(OPP, 1, "signi_left")
    main(t)
    use(t, a)
    pick(t, HINT_BET, 1)
    pick(t, HINT_MODE, 0)
    pay(t, 2)
    pick(t, HINT_TARGET, h)
    pick(t, HINT_MODE, same and 2 or 4)
    pick(t, HINT_TARGET, same and h or x)
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:keyword(h, EFFECT_ASSASSIN) and t:keyword(h, EFFECT_DOUBLE_CRUSH) == same)
    t:expect(t:keyword(x, EFFECT_CANNOT_ATTACK) == not same)
  end
end)

case("震亜動地: ＜宇宙＞를 버리면 코스트가 없다", "WD21-008", function(t)
  for _, mode in ipairs{0, 1, 2} do
    wd(t)
    local a, u = t:put(N["008"], 0, "lrig_deck"), t:put(U[1], 0, "hand")
    t:put(RED, 0, "hand")
    local x, y = t:put(OPP, 0, "trash"), t:put(BIG, 0, "trash")
    main(t)
    use(t, a)
    t:expect(t:wait(HINT_SELECT))
    t:expect(#t:request().options == 1 and not t:answer(), "에나가 없으면 버려야 한다")
    t:expect(t:answer(u))
    pick(t, HINT_MODE, mode)
    if mode == 2 then
      pick(t, HINT_TARGET, x, y)
      pick(t, HINT_DISCARD, x)
    end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:count(0, "hand") == ({3, 1, 2})[mode + 1] and t:count(0, "ena") == (mode == 1 and 2 or 0))
    t:expect(t:is_in(u, 0, "trash"))
  end
end)

case("燐廻転生: 놓은 장수의 처리를 모두. 5장이면 트리플 크러시와 업", "WD21-009 FAQ 1~3", function(t)
  for n, c in pairs{[1] = {1, false, false}, [2] = {1, true, false}, [4] = {3, true, false}, [5] = {3, true, true}} do
    local lc = wd(t)
    for _ = 1, 5 do t:put_under(t:put(N["006"], 0, "lrig_deck"), lc) end
    local a = t:put(N["009"], 0, "lrig_deck")
    ena(t, 3)
    main(t)
    use(t, a)
    pay(t, 3)
    t:expect(t:wait(HINT_ATTACK_LRIG))
    t:expect(t:answer(lc))
    local u = t:under(lc)
    t:expect(t:wait(HINT_SELECT))
    t:expect(t:answer(table.unpack(u, 1, n)))
    if n >= 2 then
      pick(t, HINT_DECLARE, 1)
      pick(t, HINT_DECLARE, 2)
    end
    if c[3] then
      t:expect(t:wait(HINT_ATTACK_LRIG), "다시 어택할 수 있다")
    else
      t:wait(HINT_MAIN)
    end
    t:expect(t:count(1, "life_cloth") == 5 - c[1], n)
    t:expect(t:saw(HINT_DECLARE) == false)
  end
end)

case("燐廻転生: 선언한 레벨의 서번트로 가드할 수 없다", "WD21-009", function(t)
  for _, lv in ipairs{1, 3} do
    local lc = wd(t)
    for _ = 1, 2 do t:put_under(t:put(N["006"], 0, "lrig_deck"), lc) end
    local a = t:put(N["009"], 0, "lrig_deck")
    local s = t:put(N["019"], 1, "hand")
    ena(t, 3)
    main(t)
    use(t, a)
    pay(t, 3)
    t:expect(t:wait(HINT_ATTACK_LRIG))
    t:expect(t:answer(lc))
    pick(t, HINT_SELECT, table.unpack(t:under(lc)))
    pick(t, HINT_DECLARE, lv)
    pick(t, HINT_DECLARE, lv)
    if lv == 3 then
      t:expect(t:wait(HINT_GUARD))
    else
      t:wait(HINT_MAIN)
      t:expect(not t:saw(HINT_GUARD))
    end
  end
end)

case("炎得火失: ① 4장 뽑고 상대가 고른 2장을 제외(있는 만큼)", "WD21-010 FAQ 1·3", function(t)
  for _, n in ipairs{12, 1} do
    wd(t)
    deck(t, RED, n)
    local a = t:put(N["010"], 0, "lrig_deck")
    ena(t, 1)
    main(t)
    local ex = t:count(0, "exclude")
    use(t, a)
    pick(t, HINT_MODE, 0)
    pay(t, 1)
    t:expect(t:wait(HINT_SELECT))
    local k = math.min(2, n)
    t:expect(t:request().player == 1 and t:request().min == k)
    t:expect(t:answer(table.unpack(t:cards(0, "hand"), 1, k)))
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:count(0, "exclude") == ex + k and t:count(0, "hand") == math.min(4, n) - k)
  end
end)

case("炎得火失: ② 바니시하고 상대는 뽑고 에나. 덱이 1장이면 뽑기만", "WD21-010 FAQ 4", function(t)
  for _, n in ipairs{12, 1} do
    wd(t)
    for i, c in ipairs(t:cards(1, "main_deck")) do if i > n then t:move(c, 1, "trash") end end
    local a, x = t:put(N["010"], 0, "lrig_deck"), t:put(BIG, 1, "signi_left")
    ena(t, 1)
    main(t)
    use(t, a)
    pick(t, HINT_MODE, 1)
    pay(t, 1)
    pick(t, HINT_TARGET, x)
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(x, 1, "ena") and t:count(1, "hand") == 1 and t:count(1, "ena") == (n == 1 and 1 or 2))
  end
end)

-- ── 시그니 ──

case("テンドウ: 【起】로 크러시하면 【自】으로 바니시. 턴 1회, 어택 페이즈에만", "WD21-011", function(t)
  wd(t)
  deck(t, N["020"])
  local h, x = t:put(N["011"], 0, "signi_left"), t:put(BIG, 1, "signi_left")
  main(t)
  t:expect(t:action(ACT_ABILITY, h) == nil)
  t:expect(t:answer(t:action(ACT_END)))
  pick(t, HINT_TARGET, h)  -- 루리그의 【自】(스펠이 공개돼 아무 일도 없다)
  t:expect(t:wait(HINT_PRE_ATTACK))
  t:expect(t:answer(t:action(ACT_ABILITY, h)))
  pick(t, HINT_TARGET, x)
  t:expect(t:wait(HINT_PRE_ATTACK))
  t:expect(t:is_in(x, 1, "ena") and t:count(0, "life_cloth") == 4)
  t:expect(t:action(ACT_ABILITY, h) == nil)
end)

case("テンドウ: 【出】 라이프가 0장일 때만 라이프를 더한다", "WD21-011", function(t)
  for _, n in ipairs{0, 1} do
    wd(t)
    for i, c in ipairs(t:cards(0, "life_cloth")) do if i > n then t:move(c, 0, "exclude") end end
    local h = t:put(N["011"], 0, "hand")
    ena(t, 2)
    main(t)
    t:expect(t:answer(t:action(ACT_PLAY, h, "signi_left")))
    pick(t, HINT_USE_TRIGGER, 1)
    pay(t, 2)
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:count(0, "life_cloth") == 1)
  end
end)

case("テンドウ: LB 이 턴에 2장 이상 크러시됐으면 라이프를 더한다", "WD21-011", function(t)
  for n = 1, 2 do
    wd(t)
    t:put(N["011"], 0, "life_cloth")
    local a = t:put(BIG, 1, "signi_left")
    if n == 2 then t:grant(a, EFFECT_DOUBLE_CRUSH, 0, 1) end
    t:begin(1, PHASE_ATTACK)
    pick(t, HINT_TARGET, a)
    pick(t, HINT_ATTACK_SIGNI, a)
    pick(t, HINT_LIFEBURST, 1)
    t:wait(HINT_ATTACK_LRIG)
    t:expect(t:count(0, "hand") == 1 and t:count(0, "life_cloth") == 5, n)
  end
end)

case("チドウ: 1·1·2도 합계 10으로 칠 수 있다. ＜宇宙＞가 아니면 그대로", "WD21-012 FAQ 1·2", function(t)
  for _, c in ipairs{{U[1], true}, {RED, false}} do
    wd(t)
    deck(t, c[1])
    local h, x = t:put(N["012"], 0, "signi_left"), t:put(OPP, 1, "signi_center")
    t:begin(0, PHASE_ATTACK)
    pick(t, HINT_TARGET, h)  -- 루리그의 【自】
    if c[2] then pick(t, HINT_DECLARE, 4) end
    pick(t, HINT_ATTACK_SIGNI, h)
    pick(t, HINT_TARGET, x)
    t:wait(HINT_ATTACK_LRIG)
    t:expect(t:is_in(x, 1, "ena") == c[2] and t:count(0, "trash") == 3)
  end
end)

case("チドウ: 덱에서 레벨 4를 찾을 때 ＜宇宙＞는 모두 후보. 장에 없으면 아니다", "WD21-012, WD21-013", function(t)
  for _, on in ipairs{true, false} do
    wd(t)
    local h, x = t:put(N["013"], 0, "signi_left"), t:put(U[1], 0, "signi_center")
    t:put(on and N["012"] or U[1], 0, "signi_right")
    local a, b = t:put(U[2], 0, "main_deck"), t:put(U[4], 0, "main_deck")
    main(t)
    t:expect(t:answer(t:action(ACT_ABILITY, h)))
    pick(t, HINT_SELECT, h, x)
    t:expect(t:wait(HINT_SELECT))
    t:expect(#t:request().options == (on and 2 or 1))
    t:expect(t:answer(on and a or b))
    t:expect(t:wait(HINT_ZONE))
    t:expect(t:answer(t:request().options[1]))
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:at(on and a or b) ~= "main_deck" and t:is_in(h, 0, "trash") and t:is_in(x, 0, "trash"))
  end
end)

case("ガイテン: 루리그가 레벨 3이면 레벨 4 시그니를 내지 못한다", "WD21-013 FAQ 2", function(t)
  wd(t, "002")
  local h, x = t:put(N["013"], 0, "signi_left"), t:put(U[1], 0, "signi_center")
  local b = t:put(U[4], 0, "main_deck")
  main(t)
  t:expect(t:answer(t:action(ACT_ABILITY, h)))
  pick(t, HINT_SELECT, h, x)
  pick(t, HINT_SELECT, b)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(b, 0, "main_deck"))
end)

case("レグルス: 상대 장에 레벨 3 이상이 있을 때만", "WD21-014", function(t)
  for _, on in ipairs{true, false} do
    wd(t)
    local h = t:put(N["014"], 0, "signi_left")
    t:put(on and BIG or OPP, 1, "signi_left")
    main(t)
    t:expect((t:action(ACT_ABILITY, h) ~= nil) == on)
    if on then
      t:expect(t:answer(t:action(ACT_ABILITY, h)))
      t:expect(t:wait(HINT_MAIN))
      t:expect(t:count(0, "hand") == 1)
    end
  end
end)

case("ハダル·アンタレス: 【出】 조건에 맞으면 1장", "WD21-015, WD21-016", function(t)
  for _, c in ipairs{{"015", 2, OPP, 1}, {"015", 3, OPP, 0}, {"016", 3, RED, 1}, {"016", 0, OPP, 0}} do
    wd(t)
    t:fill(OPP, 1, "hand", c[2])
    t:put(c[3], 1, "signi_left")
    local h = t:put(N[c[1]], 0, "hand")
    main(t)
    t:expect(t:answer(t:action(ACT_PLAY, h, "signi_left")))
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:count(0, "hand") == c[4], c[1])
  end
end)

case("センヤ: 효과로 바니시·트래시되면 발동", "WD21-017 FAQ 1·4", function(t)
  wd(t)
  local sp, h, x = t:put(N["020"], 0, "hand"), t:put(N["017"], 0, "signi_left"), t:put(OPP, 1, "signi_left")
  deck(t, U[2])
  main(t)
  use(t, sp)
  pick(t, HINT_TARGET, h)
  pick(t, HINT_TARGET, x)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(x, 1, "ena") and t:is_in(h, 0, "ena"))
  wd(t)
  local g
  g, h, x = t:put(N["013"], 0, "signi_center"), t:put(N["017"], 0, "signi_left"), t:put(OPP, 1, "signi_left")
  main(t)
  t:expect(t:answer(t:action(ACT_ABILITY, g)))
  pick(t, HINT_SELECT, g, h)
  pick(t, HINT_TARGET, x)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(x, 1, "ena") and t:is_in(h, 0, "trash"))
end)

case("センヤ: 배틀이나 파워 0의 룰 처리로는 발동하지 않는다", "WD21-017 FAQ 2·3", function(t)
  for _, rule in ipairs{true, false} do
    wd(t)
    local h, x = t:put(N["017"], 0, "signi_left"), t:put(OPP, 1, "signi_right")
    if rule then t:single(h, EFFECT_UPDATE_POWER, -2000, 1) end
    t:begin(1, PHASE_ATTACK)
    if not rule then
      pick(t, HINT_TARGET, x)
      pick(t, HINT_ATTACK_SIGNI, x)
    end
    t:wait(HINT_ATTACK_LRIG)
    t:expect(t:is_in(h, 0, "ena") and t:is_in(x, 1, "signi_right"))
  end
end)

-- ── 磊落の選択 ──

case("磊落の選択: 시그니가 나올 때까지 공개하고 레벨대로 처리", "WD21-020", function(t)
  for lv = 1, 5 do
    wd(t)
    deck(t, RED, 5)
    local u = t:put(U[lv], 0, "main_deck")
    t:put(N["020"], 0, "main_deck")  -- 맨 위 스펠
    t:fill(OPP, 1, "hand", 2)
    local sp, h = t:put(N["020"], 0, "hand"), t:put(U[1], 0, "signi_left")
    local tr = t:put(U[3], 0, "trash")
    main(t)
    use(t, sp)
    pick(t, HINT_TARGET, h)
    if lv == 3 then
      t:expect(t:wait(HINT_DISCARD))
      t:expect(t:answer(t:cards(1, "hand")[1]))
    elseif lv >= 4 then
      pick(t, HINT_TARGET, tr)
    end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:count(0, "hand") == ((lv == 1 or lv >= 4) and 1 or 0), lv)
    t:expect(t:count(0, "ena") == (lv == 2 and 2 or 1) and t:count(1, "hand") == (lv == 3 and 1 or 2))
    local d = t:cards(0, "main_deck")
    t:expect(d[1] == u or d[2] == u, "덱 맨 아래")
  end
end)

case("磊落の選択: 시그니가 없으면 섞어서 끝. 리프레시하지 않는다", "WD21-020 FAQ 1", function(t)
  wd(t)
  deck(t, N["020"], 3)
  local sp, h = t:put(N["020"], 0, "hand"), t:put(U[1], 0, "signi_left")
  main(t)
  use(t, sp)
  pick(t, HINT_TARGET, h)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "main_deck") == 3 and t:refreshes(0) == 0 and t:count(0, "hand") == 0)
end)

case("磊落の選択: 《チドウ》가 있으면 레벨 하나만 고른다", "WD21-012 FAQ 3", function(t)
  wd(t)
  deck(t, U[1])
  local sp, h = t:put(N["020"], 0, "hand"), t:put(U[1], 0, "signi_left")
  t:put(N["012"], 0, "signi_center")
  main(t)
  use(t, sp)
  pick(t, HINT_TARGET, h)
  pick(t, HINT_DECLARE, 2)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "ena") == 2 and t:count(0, "hand") == 0)
end)
