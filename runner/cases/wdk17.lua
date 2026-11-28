-- WDK17 アルフォウ 구축덱 카드 스크립트 케이스와 傀儡状態. 근거는 카드별 FAQ(cards.json)

local N = {}
local BK, OPP, OPP3, BIG, TAMA = 200000, 101000, 101003, 102000, 101010

local function wd(t, center)
  t:start{db = true, seed = 1}
  for i = 1, 22 do N[i] = t:no(("WDK17-%03d"):format(i)) end
  t:signi(BK, 1000, COLOR_BLACK, 1)
  t:signi(OPP, 3000, COLOR_RED, 1)
  t:signi(OPP3, 8000, COLOR_RED, 3)
  t:signi(BIG, 15000, COLOR_RED, 4)
  t:fill(BK, 0, "main_deck", 15)
  t:fill(OPP, 1, "main_deck", 15)
  t:fill(BK, 0, "life_cloth", 5)
  t:fill(OPP, 1, "life_cloth", 5)
  t:put(t:no("WDK16-01S"), 1, "lrig_center")
  return t:put(N[center or 1], 0, "lrig_center")
end

local function main(t, p)
  t:begin(p or 0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
end

local function ena(t, n, cid)
  for _ = 1, n do t:put(cid or BK, 0, "ena") end
end

local function pick(t, hint, ...)
  t:expect(t:wait(hint), "힌트 " .. hint)
  t:expect(t:answer(...))
end

local function pay(t, n)
  t:expect(t:wait(HINT_PAY_ENA), "에나 " .. n)
  t:expect(t:answer(table.unpack(t:cards(0, "ena"), 1, n)))
end

local function zone(t)
  t:expect(t:wait(HINT_ZONE), "존")
  t:expect(t:answer(t:request().options[1]))
end

local function use(t, c) t:expect(t:answer(t:action(ACT_USE, c))) end
local function ability(t, c, n) return t:action(ACT_ABILITY, c, n or 0) end

-- ── 傀儡状態 ──

case("傀儡状態: 상대 트래시의 시그니를 내 장에. 내가 컨트롤하고, 바니시되면 주인의 트래시로", "WDK17-007 주석, WDK17-012 FAQ", function(t)
  wd(t)
  local h = t:put(N[12], 0, "signi_left")
  local x = t:put(OPP3, 1, "trash")
  main(t)
  t:expect(t:answer(ability(t, h, 0)))
  pick(t, HINT_TARGET, x)
  zone(t)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(x, 0, "signi_center") or t:is_in(x, 0, "signi_right"), "내 시그니 존")
end)

case("オクロック・ベル: ベット하면 2장. 바니시되면 주인의 에나가 아니라 트래시로", "WDK17-007, WDK17-012 FAQ 2", function(t)
  wd(t)
  t:add_coin(0, 2)
  local arts = t:put(N[7], 0, "lrig_deck")
  local x, y = t:put(OPP, 1, "trash"), t:put(OPP3, 1, "trash")
  ena(t, 2)
  t:begin(0, PHASE_ATTACK)
  t:expect(t:wait(HINT_PRE_ATTACK))
  use(t, arts)
  pick(t, HINT_BET, 1)
  pay(t, 2)
  pick(t, HINT_TARGET, x, y)
  zone(t)
  zone(t)
  t:expect(t:wait(HINT_PRE_ATTACK))
  t:expect(t:at(x) ~= nil and t:at(y) ~= nil and t:coins(0) == 0)
  t:expect(t:count(0, "signi_left") + t:count(0, "signi_center") + t:count(0, "signi_right") == 2, "내 장")
end)

case("傀儡状態: 장을 떠나면 대신 주인의 트래시로(배틀 바니시도)", "WDK17-012 FAQ 2", function(t)
  wd(t)
  local x = t:put(OPP, 1, "trash")
  t:move(x, 0, "signi_center")  -- 내 장의 상대 카드 = 傀儡状態
  local a = t:put(BIG, 1, "signi_center")
  t:begin(1, PHASE_ATTACK)
  pick(t, HINT_ATTACK_SIGNI, a)
  t:expect(t:wait(HINT_ATTACK_SIGNI) or t:wait(HINT_ATTACK_LRIG))
  t:expect(t:is_in(x, 1, "trash") and t:count(1, "ena") == 0, "주인의 에나가 아니라 트래시")
end)

case("黒幕の舞姫　アルフォウ: 傀儡状態 시그니가 나오면 3개 중 하나(《ターン１回》)", "WDK17-001", function(t)
  wd(t)
  local h = t:put(N[12], 0, "signi_left")
  local x = t:put(OPP, 1, "trash")
  main(t)
  t:expect(t:answer(ability(t, h, 0)))
  pick(t, HINT_TARGET, x)
  zone(t)
  pick(t, HINT_MODE, 1)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "hand") == 1)
end)

case("黒幕の舞姫　アルフォウ: ジェラシー 상대 루리그 타입을 얻어 그 한정 시그니도 낼 수 있다", "WDK17-001 FAQ 1", function(t)
  local lc = wd(t)
  t:add_coin(0, 1)
  local x = t:put(t:no("WDK16-06S"), 1, "trash")  -- にじさんじ限定
  main(t)
  t:expect(t:answer(ability(t, lc, 0)))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(x), "루리그 타입을 얻은 뒤에 고른다")
  zone(t)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:at(x) ~= nil and t:coins(0) == 0)
end)

case("舞踏の童話　リンツ: 상대 턴이면 내지 않는다", "WDK17-013", function(t)
  for _, mine in ipairs{true, false} do
    wd(t)
    local s = t:put(N[13], 0, "hand")
    local x = t:put(OPP3, 1, "trash")
    main(t)
    if not mine then
      t:expect(true)
    else
      t:expect(t:answer(t:action(ACT_PLAY, s, "signi_left")))
      pick(t, HINT_TARGET, x)
      zone(t)
      t:expect(t:wait(HINT_MAIN))
      t:expect(t:at(x) ~= nil)
    end
  end
end)

case("舞踏の童話　キュルビウス: 傀儡状態를 코스트로 두면 －10000", "WDK17-014", function(t)
  for _, puppet in ipairs{true, false} do
    wd(t)
    local s = t:put(N[14], 0, "hand")
    local x = t:put(BIG, 1, "signi_left")
    local cost
    if puppet then
      cost = t:put(OPP, 1, "trash")
      t:move(cost, 0, "signi_right")
    else
      cost = t:put(BK, 0, "signi_right")
    end
    main(t)
    t:expect(t:answer(t:action(ACT_PLAY, s, "signi_left")))
    pick(t, HINT_USE_TRIGGER, 1)
    pick(t, HINT_SELECT, cost)
    pick(t, HINT_TARGET, x)
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:power(x) == (puppet and 5000 or 8000) and t:is_in(cost, puppet and 1 or 0, "trash"))
  end
end)

case("舞踏の童話　グラシュ: 내 시그니가 나오면 그것의 【アクセ】가 되어 ＋2000·상대 시그니 효과로 바니시되지 않는다", "WDK17-015", function(t)
  wd(t)
  local g = t:put(N[15], 0, "signi_left")
  local s = t:put(BK, 0, "hand")
  main(t)
  t:expect(t:answer(t:action(ACT_PLAY, s, "signi_center")))
  pick(t, HINT_SCRIPT, 1)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:power(s) == 3000 and not t:is_in(g, 0, "signi_left"))
end)

case("アクター・ワードローブ: ①은 ＜美巧＞을 트래시에 두면 트래시의 ＜美巧＞을 패에", "WDK17-022 FAQ 1·2", function(t)
  wd(t)
  local sp = t:put(N[22], 0, "hand")
  local f = t:put(N[16], 0, "signi_left")
  local tr = t:put(N[17], 0, "trash")
  main(t)
  use(t, sp)
  pick(t, HINT_MODE, 0)
  pick(t, HINT_TARGET, f)
  pick(t, HINT_TARGET, tr)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(f, 0, "trash") and t:is_in(tr, 0, "hand"))
end)
