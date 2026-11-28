-- WDK16 にじさんじ 구축덱 카드 스크립트 케이스와 登録者数. 근거는 카드별 FAQ(cards.json)·용어집

local N = {}
local WH, DK, OPP, MID, BIG = 200000, 200001, 101000, 101500, 102000

local function wd(t, center)
  t:start{db = true, seed = 1}
  for _, k in ipairs{"01H", "01S", "01T", "02H", "03H", "04H", "05H", "05S", "05T", "06H", "06S", "06T", "07", "09", "13", "17", "22"} do
    N[k] = t:no("WDK16-" .. k)
  end
  t:signi(WH, 1000, COLOR_WHITE, 1)
  t:card{cid = DK, power = 1000, level = 1, classes = {"精械：電機"}, color = COLOR_WHITE}
  t:signi(OPP, 3000, COLOR_RED, 1)
  t:signi(MID, 9000, COLOR_RED, 3)
  t:signi(BIG, 15000, COLOR_RED, 4)
  t:fill(WH, 0, "main_deck", 15)
  t:fill(OPP, 1, "main_deck", 15)
  t:fill(WH, 0, "life_cloth", 5)
  t:fill(OPP, 1, "life_cloth", 5)
  t:put(N["01S"], 1, "lrig_center")
  return t:put(N[center or "01H"], 0, "lrig_center")
end

local function main(t, p)
  t:begin(p or 0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
end

local function ena(t, n, cid)
  for _ = 1, n do t:put(cid or WH, 0, "ena") end
end

local function pick(t, hint, ...)
  t:expect(t:wait(hint), "힌트 " .. hint)
  t:expect(t:answer(...))
end

local function use(t, c) t:expect(t:answer(t:action(ACT_USE, c))) end
local function ability(t, c, n) return t:action(ACT_ABILITY, c, n or 0) end

local function subs(t, n) t:add_subscribers(0, n) end

case("登録者数: 【出】로 얻고 쌓인다. 상한은 없다", "용어집: 登録者数, WDK16-02H", function(t)
  wd(t, "03H")
  local g = t:put(N["02H"], 0, "lrig_deck")
  ena(t, 2)
  t:begin(0, PHASE_GROW)
  pick(t, HINT_GROW, g)
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(table.unpack(t:cards(0, "ena"), 1, 2)))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:subscribers(0) == 20 and t:subscribers(1) == 0)
end)

case("樋口楓　レベル４: 80만 명이면 #でろおんえあ로 상대 시그니 전부 바니시. 모자라면 아무 일도 없다", "WDK16-01H", function(t)
  for _, n in ipairs{80, 70} do
    local lc = wd(t)
    local x, y = t:put(MID, 1, "signi_left"), t:put(BIG, 1, "signi_center")
    subs(t, n)
    main(t)
    t:expect(t:answer(ability(t, lc, 0)))
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(x, 1, n == 80 and "ena" or "signi_left") and t:is_in(y, 1, n == 80 and "ena" or "signi_center"))
  end
end)

case("静凛　レベル４: 턴 종료 시 패가 3장 이상이면 10만 명", "WDK16-01S", function(t)
  for _, n in ipairs{3, 2} do
    wd(t, "01S")
    for _ = 1, n do t:put(WH, 0, "hand") end
    main(t)
    t:expect(t:answer(t:action(ACT_END)))
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:subscribers(0) == (n >= 3 and 10 or 0))
  end
end)

case("月ノ美兎　レベル４: 《赤》《青》를 흰 에나로 낼 수 있다", "WDK16-01T", function(t)
  wd(t, "01T")
  local k = t:put(N["05T"], 0, "key")
  ena(t, 4)
  t:put(BIG, 1, "signi_left")
  t:begin(0, PHASE_ATTACK)
  t:expect(t:wait(HINT_PRE_ATTACK))
  t:expect(t:answer(ability(t, k, 0)))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(table.unpack(t:cards(0, "ena"), 1, 4)), "흰 4장으로 《青》《青》《赤》《赤》")
  t:expect(t:wait(HINT_PRE_ATTACK))
  t:expect(t:is_in(k, 0, "lrig_trash") and t:count(1, "signi_left") == 0 and t:count(0, "hand") == 3)
end)

case("楓サポーター: 센터가 《樋口楓　レベル４》가 아니면 낼 수 없다", "WDK16-05H", function(t)
  for _, center in ipairs{"01H", "01S"} do
    wd(t, center)
    local k = t:put(N["05H"], 0, "lrig_deck")
    ena(t, 2)
    main(t)
    t:expect((t:action(ACT_KEY, k) ~= nil) == (center == "01H"))
  end
end)

case("コードＶＬ　本間ひまわり: 《楓》 센터면 어택할 때 8000 이하 바니시, 100만 명이면 제한 없음", "WDK16-06H", function(t)
  for _, n in ipairs{0, 100} do
    wd(t)
    local h = t:put(N["06H"], 0, "signi_left")
    local x = t:put(BIG, 1, "signi_center")
    subs(t, n)
    t:begin(0, PHASE_ATTACK)
    pick(t, HINT_ATTACK_SIGNI, h)
    if n == 100 then pick(t, HINT_TARGET, x) end
    t:expect(t:wait(HINT_ATTACK_SIGNI) or t:wait(HINT_ATTACK_LRIG))
    t:expect(t:is_in(x, 1, n == 100 and "ena" or "signi_center"))
  end
end)

case("コードＶＬ　笹木咲: 《凛》 센터일 때만 상대가 1장 버린다", "WDK16-06S", function(t)
  for _, center in ipairs{"01S", "01H"} do
    wd(t, center)
    local s = t:put(N["06S"], 0, "hand")
    t:put(OPP, 1, "hand")
    main(t)
    t:expect(t:answer(t:action(ACT_PLAY, s, "signi_left")))
    if center == "01S" then pick(t, HINT_DISCARD, t:cards(1, "hand")[1]) end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:count(1, "hand") == (center == "01S" and 0 or 1))
  end
end)

case("マスト・ハイド: 70만 명이면 2체, 100만 명이면 센터 루리그도 어택할 수 없다", "WDK16-09", function(t)
  wd(t)
  local arts = t:put(N["09"], 0, "lrig_deck")
  local x, y = t:put(MID, 1, "signi_left"), t:put(BIG, 1, "signi_center")
  local olc = t:cards(1, "lrig_center")[1]
  ena(t, 2)
  subs(t, 100)
  t:begin(1, PHASE_ATTACK)
  t:expect(t:wait(HINT_DEFENSE))
  use(t, arts)
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(table.unpack(t:cards(0, "ena"), 1, 2)))
  pick(t, HINT_TARGET, x, y)
  pick(t, HINT_TARGET, olc)
  t:expect(t:wait(HINT_DEFENSE) or t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:keyword(x, EFFECT_CANNOT_ATTACK) and t:keyword(y, EFFECT_CANNOT_ATTACK) and t:keyword(olc, EFFECT_CANNOT_ATTACK))
end)

case("コードＶＬ　黒井しば: 덱 위가 레벨 1 ＜電機＞이면 장에", "WDK16-17", function(t)
  wd(t)
  local s = t:put(N["17"], 0, "hand")
  local top = t:put(DK, 0, "main_deck")
  main(t)
  t:expect(t:answer(t:action(ACT_PLAY, s, "signi_left")))
  t:expect(t:wait(HINT_ZONE))
  t:expect(t:answer(t:request().options[1]))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:at(top) ~= nil)
end)

case("チャイルド・クッキー: ①은 ＜電機＞을 트래시에 두면 상대가 고른 자기 시그니를 패로", "WDK16-22", function(t)
  wd(t)
  local sp = t:put(N["22"], 0, "hand")
  local f = t:put(DK, 0, "signi_left")
  local x = t:put(MID, 1, "signi_left")
  main(t)
  use(t, sp)
  pick(t, HINT_MODE, 0)
  pick(t, HINT_TARGET, f)
  pick(t, HINT_TARGET, x)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(f, 0, "trash") and t:is_in(x, 1, "hand"))
end)
