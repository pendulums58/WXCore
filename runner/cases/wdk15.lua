-- WDK15 ナナシ 구축덱 카드 스크립트 케이스. 근거는 카드별 FAQ(cards.json)

local N = {}
local BLK, WP, OPP, MID, BIG = 200000, 200001, 101000, 101500, 102000

local function wd(t, center)
  t:start{db = true, seed = 1}
  for i = 1, 22 do N[i] = t:no(("WDK15-%03d"):format(i)) end
  t:signi(BLK, 1000, COLOR_BLACK, 1)
  t:card{cid = WP, power = 2000, level = 1, classes = {"精武：ウェポン"}, color = COLOR_BLACK}
  t:signi(OPP, 3000, COLOR_RED, 1)
  t:signi(MID, 9000, COLOR_RED, 3)
  t:signi(BIG, 15000, COLOR_RED, 4)
  t:fill(BLK, 0, "main_deck", 15)
  t:fill(OPP, 1, "main_deck", 15)
  t:fill(BLK, 0, "life_cloth", 5)
  t:fill(OPP, 1, "life_cloth", 5)
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

local function has(list, c)
  for _, x in ipairs(list) do if x == c then return true end end
  return false
end

local function use(t, c) t:expect(t:answer(t:action(ACT_USE, c))) end
local function ability(t, c, n) return t:action(ACT_ABILITY, c, n or 0) end

case("ナナシ　其ノ四ノ報: 【出】 라이즈 시그니와 ＜ウェポン＞을 1장씩. 한쪽만 있어도 된다", "WDK15-001 FAQ 3", function(t)
  for _, both in ipairs{true, false} do
    wd(t, 2)
    local g = t:put(N[1], 0, "lrig_deck")
    local r = both and t:put(N[11], 0, "trash")
    local w = t:put(WP, 0, "trash")
    t:begin(0, PHASE_GROW)
    pick(t, HINT_GROW, g)
    if r then pick(t, HINT_TARGET, r) end
    pick(t, HINT_TARGET, w)
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(w, 0, "hand") and (not r or t:is_in(r, 0, "hand")))
  end
end)

case("ナナシ　其ノ四ノ報: 라이즈 시그니가 나오면 트래시의 시그니를 그 아래에. 《ターン１回》", "WDK15-001 FAQ 1·2", function(t)
  wd(t)
  local base = t:put(WP, 0, "signi_left")
  local r = t:put(N[11], 0, "hand")
  local d = t:put(BLK, 0, "trash")
  ena(t, 0)
  main(t)
  t:expect(t:answer(t:action(ACT_PLAY, r, t:at(base))))
  pick(t, HINT_TARGET, d)
  t:expect(t:wait(HINT_MAIN))
  t:expect(has(t:under(r), d) and has(t:under(r), base) and t:power(r) == 15000, "아래 2장으로 ＋2000")
end)

case("ナナシ　其ノ四ノ報: ブラインド 트래시 2장을 한 체 아래에 두고 아래에 카드가 있는 시그니 수만큼 뽑는다", "WDK15-001 FAQ 4", function(t)
  local lc = wd(t)
  t:add_coin(0, 1)
  local w1, w2 = t:put(WP, 0, "signi_left"), t:put(WP, 0, "signi_center")
  local a, b = t:put(BLK, 0, "trash"), t:put(BLK, 0, "trash")
  t:put_under(t:put(BLK, 0, "hand"), w2)
  main(t)
  t:expect(t:answer(ability(t, lc, 0)))
  pick(t, HINT_TARGET, a, b)
  pick(t, HINT_TARGET, w1)
  t:expect(t:wait(HINT_MAIN))
  t:expect(has(t:under(w1), a) and has(t:under(w1), b) and t:count(0, "hand") == 2 and t:coins(0) == 0)
end)

case("フォトジェニック・バリアー: ベット하면 《黒》 하나(에나가 모자라면 자동으로 ベット). ＜ウェポン＞을 내고 그 아래에 2장", "WDK15-007", function(t)
  wd(t)
  t:add_coin(0, 1)
  local arts = t:put(N[7], 0, "lrig_deck")
  local w = t:put(N[12], 0, "trash")
  local a, b = t:put(BLK, 0, "trash"), t:put(BLK, 0, "trash")
  ena(t, 1)
  main(t)
  use(t, arts)
  pay(t, 1)  -- 《黒》×3을 낼 수 없으면 묻지 않고 ベット
  pick(t, HINT_TARGET, w)
  pick(t, HINT_TARGET, a, b)
  t:expect(t:wait(HINT_ZONE))
  t:expect(t:answer(t:request().options[1]))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:at(w) ~= nil and #t:under(w) == 2 and t:coins(0) == 0)
end)

case("ハイアングル・バズーカ: 아래 카드 2장을 트래시에 두고 2체 바니시", "WDK15-008 FAQ 1", function(t)
  wd(t)
  local arts = t:put(N[8], 0, "lrig_deck")
  local w = t:put(WP, 0, "signi_left")
  local u1, u2 = t:put(BLK, 0, "hand"), t:put(BLK, 0, "hand")
  t:put_under(u1, w)
  t:put_under(u2, w)
  local x, y = t:put(MID, 1, "signi_left"), t:put(BIG, 1, "signi_center")
  ena(t, 2)
  t:begin(0, PHASE_ATTACK)
  t:expect(t:wait(HINT_PRE_ATTACK))
  use(t, arts)
  pay(t, 2)
  pick(t, HINT_SELECT, u1, u2)
  pick(t, HINT_TARGET, x, y)
  t:expect(t:wait(HINT_PRE_ATTACK))
  t:expect(t:is_in(u1, 0, "trash") and t:is_in(x, 1, "ena") and t:is_in(y, 1, "ena"))
end)

case("弩書　トート: 아래 카드 1장당 ＋1000, 3장 이상이면 【ダブルクラッシュ】", "WDK15-011", function(t)
  wd(t)
  local h = t:put(N[11], 0, "signi_left")
  main(t)
  for i = 1, 3 do
    t:put_under(t:put(BLK, 0, "hand"), h)
    t:expect(t:power(h) == 13000 + 1000 * i and t:keyword(h, EFFECT_DOUBLE_CRUSH) == (i >= 3), "아래 " .. i)
  end
end)

case("弩書　トート: 어택하면 상대의 모든 시그니를 이 시그니 파워의 절반만큼 －", "WDK15-011 FAQ 2", function(t)
  wd(t)
  local h = t:put(N[11], 0, "signi_left")
  t:put_under(t:put(BLK, 0, "hand"), h)
  local x, y = t:put(BIG, 1, "signi_left"), t:put(BIG, 1, "signi_center")
  t:begin(0, PHASE_ATTACK)
  pick(t, HINT_ATTACK_SIGNI, h)
  t:expect(t:wait(HINT_ATTACK_LRIG))
  t:expect(t:power(x) == 15000 - 7000 and t:power(y) == 15000 - 7000, "14000의 절반")
end)

case("弩書　ジャパコカビ: 다운하고 아래 카드 1장을 트래시에 두어 －12000. 아래가 없으면 못 쓴다", "WDK15-012", function(t)
  for _, u in ipairs{false, true} do
    wd(t)
    local h = t:put(N[12], 0, "signi_left")
    local x = t:put(BIG, 1, "signi_left")
    local c = u and t:put(BLK, 0, "hand")
    if c then t:put_under(c, h) end
    main(t)
    if not u then
      t:expect(ability(t, h) == nil, "아래 카드가 없다")
    else
      t:expect(t:answer(ability(t, h)))
      pick(t, HINT_SELECT, c)
      pick(t, HINT_TARGET, x)
      t:expect(t:wait(HINT_MAIN))
      t:expect(t:is_in(c, 0, "trash") and t:power(x) == 3000 and t:flags(h) & CF_DOWN ~= 0)
    end
  end
end)

case("轟書　エンキリデ: 내 시그니를 아래 카드째 ＜ウェポン＞ 아래로", "WDK15-013 FAQ 2", function(t)
  wd(t)
  local h = t:put(N[13], 0, "signi_left")
  local a = t:put(BLK, 0, "signi_center")
  local u = t:put(BLK, 0, "hand")
  t:put_under(u, a)
  main(t)
  t:expect(t:answer(ability(t, h, 0)))
  pick(t, HINT_TARGET, a)
  pick(t, HINT_TARGET, h)
  t:expect(t:wait(HINT_MAIN))
  t:expect(has(t:under(h), a) and has(t:under(h), u))
end)

case("轟書　デマギア: 【出】 덱 위를 아래에. 아래에 카드가 있으면 어택할 때 －7000", "WDK15-014", function(t)
  wd(t)
  local s = t:put(N[14], 0, "hand")
  local x = t:put(MID, 1, "signi_center")
  ena(t, 1)
  main(t)
  t:expect(t:answer(t:action(ACT_PLAY, s, "signi_left")))
  pick(t, HINT_USE_TRIGGER, 1)
  pay(t, 1)
  t:expect(t:wait(HINT_MAIN))
  t:expect(#t:under(s) == 1)
end)

case("ニュース・デリバリー: ①은 ＜ウェポン＞을 트래시에 두면 트래시의 ＜ウェポン＞을 패에", "WDK15-022 FAQ 1·3", function(t)
  wd(t)
  local sp = t:put(N[22], 0, "hand")
  local f = t:put(WP, 0, "signi_left")
  local tr = t:put(N[16], 0, "trash")
  main(t)
  use(t, sp)
  pick(t, HINT_MODE, 0)
  pick(t, HINT_TARGET, f)
  pick(t, HINT_TARGET, tr)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(f, 0, "trash") and t:is_in(tr, 0, "hand"))
end)
