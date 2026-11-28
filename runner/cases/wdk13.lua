-- WDK13 ミュウ 구축덱 카드 스크립트 케이스. 근거는 카드별 FAQ(cards.json)

local N = {}
local BLK, SP1, SP2, SP3, OPP1, OPP3, OPP4 = 200000, 200001, 200002, 200003, 101000, 101003, 101004

local function wd(t, center)
  t:start{db = true, seed = 1}
  for i = 1, 22 do N[i] = t:no(("WDK13-%03d"):format(i)) end
  t:signi(BLK, 1000, COLOR_BLACK, 1)
  for lv, cid in ipairs{SP1, SP2, SP3} do
    t:card{cid = cid, power = 1000, level = lv, classes = {"精羅：宇宙"}, color = COLOR_BLACK}
  end
  t:signi(OPP1, 1000, COLOR_RED, 1)
  t:signi(OPP3, 9000, COLOR_RED, 3)
  t:signi(OPP4, 12000, COLOR_RED, 4)
  t:fill(BLK, 0, "main_deck", 15)
  t:fill(OPP1, 1, "main_deck", 15)
  t:fill(BLK, 0, "life_cloth", 5)
  t:fill(OPP1, 1, "life_cloth", 5)
  t:put(N[1], 1, "lrig_center")
  return t:put(N[center or 1], 0, "lrig_center")
end

local function main(t, p)
  t:begin(p or 0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
end

local function ena(t, n, cid)
  for _ = 1, n do t:put(cid or BLK, 0, "ena") end
end

local function pick(t, hint, ...)
  t:expect(t:wait(hint), "힌트 " .. hint)
  t:expect(t:answer(...))
end

local function pay(t, n)
  t:expect(t:wait(HINT_PAY_ENA), "에나 " .. n)
  t:expect(t:answer(table.unpack(t:cards(0, "ena"), 1, n)))
end

local function use(t, c) t:expect(t:answer(t:action(ACT_USE, c))) end
local function ability(t, c, n) return t:action(ACT_ABILITY, c, n or 0) end

case("ミュウ＝バタフライ: 【出】 트래시의 ＜宇宙＞을 0~2장", "WDK13-001 FAQ 1", function(t)
  wd(t, 2)
  local g = t:put(N[1], 0, "lrig_deck")
  local a, b = t:put(SP1, 0, "trash"), t:put(SP2, 0, "trash")
  t:put(BLK, 0, "trash")
  t:begin(0, PHASE_GROW)
  pick(t, HINT_GROW, g)
  pick(t, HINT_TARGET, a)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(a, 0, "hand") and t:is_in(b, 0, "trash"))
end)

case("ミュウ＝バタフライ: ＜宇宙＞을 버리고 ①레벨 2 이하 바니시 / ②상대 트래시 1장 제외", "WDK13-001", function(t)
  for mode = 0, 1 do
    local lc = wd(t)
    local cost = t:put(SP1, 0, "hand")
    local x, y = t:put(OPP1, 1, "signi_left"), t:put(OPP3, 1, "signi_center")
    local tr = t:put(OPP1, 1, "trash")
    main(t)
    t:expect(t:answer(ability(t, lc, 0)))
    pick(t, HINT_MODE, mode)
    pick(t, HINT_DISCARD, cost)
    if mode == 0 then
      t:expect(t:wait(HINT_TARGET))
      t:expect(not t:answer(y), "레벨 3은 안 된다")
      t:expect(t:answer(x))
    else
      pick(t, HINT_TARGET, tr)
    end
    t:expect(t:wait(HINT_MAIN))
    t:expect(mode == 0 and t:is_in(x, 1, "ena") or t:is_in(tr, 1, "exclude"))
    t:expect(ability(t, lc, 0) == nil, "《ターン１回》")
  end
end)

case("ミュウ＝バタフライ: サイレント 상대 시그니를 전부 트래시. 《ゲーム１回》", "WDK13-001 FAQ 2·3", function(t)
  local lc = wd(t)
  t:add_coin(0, 4)
  local x, y = t:put(OPP1, 1, "signi_left"), t:put(OPP4, 1, "signi_center")
  local ch = t:put(OPP1, 1, "hand")
  t:attach(ch, y, "charm")
  main(t)
  -- 패가 없어 위의 【起】는 쓸 수 없으므로 고를 수 있는 것은 サイレント 하나
  t:expect(t:answer(ability(t, lc, 0)))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(x, 1, "trash") and t:is_in(y, 1, "trash") and t:is_in(ch, 1, "trash") and t:coins(0) == 2)
  t:expect(ability(t, lc, 0) == nil, "《ゲーム１回》")
end)

case("ハイドロ・サークル: 레벨 합계 5 이하로 2체까지. ベット하면 7 이하", "WDK13-007 FAQ 1", function(t)
  for _, bet in ipairs{0, 1} do
    wd(t)
    t:add_coin(0, 1)
    local arts = t:put(N[7], 0, "lrig_deck")
    local a, b, c = t:put(OPP4, 1, "signi_left"), t:put(OPP3, 1, "signi_center"), t:put(OPP1, 1, "signi_right")
    ena(t, 4)
    main(t)
    use(t, arts)
    pick(t, HINT_BET, bet)
    pay(t, 4)
    t:expect(t:wait(HINT_TARGET))
    if bet == 0 then
      t:expect(not t:answer(a, b), "4+3은 5를 넘는다")
      t:expect(t:answer(a, c))
    else
      t:expect(t:answer(a, b))
    end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(a, 1, "ena") and t:is_in(bet == 0 and c or b, 1, "ena"))
  end
end)

case("オリオンズ・バブル: ①은 레벨 합계가 딱 7", "WDK13-008", function(t)
  wd(t)
  local arts = t:put(N[8], 0, "lrig_deck")
  local a, b, c = t:put(SP3, 0, "trash"), t:put(SP3, 0, "trash"), t:put(SP1, 0, "trash")
  local d = t:put(SP2, 0, "trash")
  ena(t, 1)
  main(t)
  use(t, arts)
  pick(t, HINT_MODE, 0)
  pay(t, 1)
  t:expect(t:wait(HINT_TARGET))
  t:expect(not t:answer(a, b), "6은 안 된다")
  t:expect(t:answer(a, b, c))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(a, 0, "hand") and t:is_in(c, 0, "hand") and t:is_in(d, 0, "trash"))
end)

case("オリオンズ・バブル: ②는 상대 장에 키가 없으면 아무것도 하지 않는다", "WDK13-008", function(t)
  for _, key in ipairs{true, false} do
    wd(t)
    if key then t:put(N[10], 1, "key") end
    local arts = t:put(N[8], 0, "lrig_deck")
    local g = {}
    for i = 1, 4 do g[i] = t:put(SP3, 0, "trash") end
    ena(t, 1)
    main(t)
    use(t, arts)
    pick(t, HINT_MODE, 1)
    pay(t, 1)
    pick(t, HINT_TARGET, g[1], g[2], g[3], g[4])
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:count(0, "hand") == (key and 4 or 0))
  end
end)

case("聖援の使者　サシェ: 《無》로 센터 루리그와 같은 색 시그니를 찾는다", "WDK13-009 FAQ 1", function(t)
  wd(t)
  local k = t:put(N[9], 0, "key")
  ena(t, 1)
  local red = t:put(OPP1, 0, "main_deck")
  main(t)
  t:expect(t:answer(ability(t, k, 0)))
  pay(t, 1)
  t:expect(t:wait(HINT_SELECT))
  t:expect(not t:answer(red), "빨강은 안 된다")
  t:expect(t:answer(t:cards(0, "main_deck")[1]))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "hand") == 1 and t:is_in(k, 0, "key"))
end)

case("聖援の使者　サシェ: 어택 페이즈에 키를 두고 ＜宇宙＞을 장에. 【出】은 발동하지 않는다", "WDK13-009", function(t)
  wd(t)
  local k = t:put(N[9], 0, "key")
  local s = t:put(N[13], 0, "main_deck")
  t:put(SP2, 0, "hand")
  t:begin(0, PHASE_ATTACK)
  t:expect(t:wait(HINT_PRE_ATTACK))
  t:expect(t:answer(ability(t, k, 0)), "어택 페이즈에는 아래 【起】만")
  pick(t, HINT_SELECT, s)
  t:expect(t:wait(HINT_ZONE))
  t:expect(t:answer(t:request().options[1]))
  t:expect(t:wait(HINT_PRE_ATTACK), "ハッブラ의 【出】이 묻지 않는다")
  t:expect(t:is_in(k, 0, "lrig_trash") and not t:is_in(s, 0, "main_deck") and t:count(0, "hand") == 1)
end)

case("羅星 エスキモ: 버린 ＜宇宙＞의 레벨 합계와 같은 레벨의 시그니를 바니시", "WDK13-011", function(t)
  wd(t)
  local h = t:put(N[11], 0, "signi_left")
  local a, b = t:put(SP1, 0, "hand"), t:put(SP2, 0, "hand")
  local x, y = t:put(OPP3, 1, "signi_left"), t:put(OPP4, 1, "signi_center")
  main(t)
  t:expect(t:answer(ability(t, h, 0)))
  pick(t, HINT_DISCARD, a, b)
  t:expect(t:wait(HINT_TARGET))
  t:expect(not t:answer(y), "레벨 4는 안 된다")
  t:expect(t:answer(x))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(x, 1, "ena") and t:is_in(y, 1, "signi_center"))
end)

case("羅星 ホースヘッド: 공개한 시그니 레벨 합계 1당 －1000. 덱이 모자라면 있는 만큼", "WDK13-012 FAQ 1", function(t)
  wd(t)
  local h = t:put(N[12], 0, "signi_left")
  for _, c in ipairs(t:cards(0, "main_deck")) do t:move(c, 0, "exclude") end
  t:put(SP3, 0, "main_deck")
  t:put(SP2, 0, "main_deck")
  local x = t:put(OPP4, 1, "signi_left")
  main(t)
  t:expect(t:answer(ability(t, h, 0)))
  pick(t, HINT_TARGET, x)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:power(x) == 7000 and t:count(0, "main_deck") == 2 and t:refreshes(0) == 0)
end)

case("羅星 ハッブラ: 버린 시그니보다 레벨이 1 높은 시그니를 찾는다", "WDK13-013", function(t)
  wd(t)
  local s = t:put(N[13], 0, "hand")
  local cost = t:put(SP2, 0, "hand")
  local want, other = t:put(SP3, 0, "main_deck"), t:put(SP1, 0, "main_deck")
  ena(t, 0)
  main(t)
  t:expect(t:answer(t:action(ACT_PLAY, s, "signi_left")))
  pick(t, HINT_USE_TRIGGER, 1)
  pick(t, HINT_DISCARD, cost)
  t:expect(t:wait(HINT_SELECT))
  t:expect(not t:answer(other))
  t:expect(t:answer(want))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(want, 0, "hand"))
end)

case("羅星 シーガル: 내 레벨 합계가 상대 이하일 때만 －3000", "WDK13-015", function(t)
  for _, low in ipairs{true, false} do
    wd(t)
    local h = t:put(N[15], 0, "signi_left")
    t:put(low and SP1 or SP2, 0, "signi_center")
    local x = t:put(OPP3, 1, "signi_center")
    t:begin(0, PHASE_ATTACK)
    pick(t, HINT_ATTACK_SIGNI, h)
    pick(t, HINT_TARGET, x)
    t:expect(t:wait(HINT_ATTACK_SIGNI))
    t:expect(t:power(x) == (low and 6000 or 9000), "2+1은 3 이하, 2+2는 넘는다")
  end
end)

case("コズミック・シンクロナイズ: ①은 장에서의 레벨만큼 보고 1장 패에", "WDK13-022 FAQ 1", function(t)
  wd(t)
  local sp = t:put(N[22], 0, "hand")
  local f = t:put(SP3, 0, "signi_left")
  main(t)
  use(t, sp)
  pick(t, HINT_MODE, 0)
  pick(t, HINT_TARGET, f)
  t:expect(t:wait(HINT_SELECT))
  t:expect(#t:request().options == 3, "3장을 본다")
  t:expect(t:answer(t:request().options[1]))
  t:expect(t:wait(HINT_ORDER) or true)
  if t:request() and t:request().hint == HINT_ORDER then t:expect(t:answer(table.unpack(t:request().options))) end
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(f, 0, "trash") and t:count(0, "hand") == 1)
end)
