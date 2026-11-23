-- WDK08 爪牙 遊月 스타터 카드 스크립트 케이스. 패에서 공개(EVENT_REVEALED_FROM_HAND), 【Ｓランサー】(용어집: Sランサー),
-- ベット로 바뀌는 사용 코스트(WDK08-Y06)와 카드별 FAQ(cards.json)

local N = {}

-- 200: ＜水獣＞ 녹색 시그니 Lv1 1000, 201: 상대 시그니(백, 3000)
-- 211~214: ＜水獣＞ 녹색 Lv1~4(파워 1000·5000·7000·10000), 216: 백 Lv3(색이 다른 시그니)
local function yz(t, center_no, opts)
  opts = opts or {}
  t:start{db = true, seed = opts.seed or 1}
  for i = 1, 20 do
    local no = ("Y%02d"):format(i)
    N[no] = t:no("WDK08-" .. no)
  end
  t:card{cid = 200, power = 1000, level = 1, classes = {"精生：水獣"}, color = COLOR_GREEN}
  t:card{cid = 201, power = 3000, level = 1, classes = {"奏羅：宇宙"}, color = COLOR_WHITE}
  for lv, pw in ipairs({1000, 5000, 7000, 10000}) do
    t:card{cid = 210 + lv, power = pw, level = lv, classes = {"精生：水獣"}, color = COLOR_GREEN}
  end
  t:card{cid = 216, power = 8000, level = 3, classes = {"奏羅：宇宙"}, color = COLOR_WHITE}
  t:fill(201, 0, "main_deck", 10)
  t:fill(201, 1, "main_deck", 10)
  t:fill(201, 0, "life_cloth", 5)
  if not opts.no_life then t:fill(201, 1, "life_cloth", 5) end
  local center = t:put(N[center_no or "Y01"], 0, "lrig_center")
  t:put(t:no("WXDi-D01-004"), 1, "lrig_center")  -- 상대 센터 Lv3
  return center
end

local function main(t)
  t:begin(0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
end

local function contains(list, x)
  for _, v in ipairs(list) do if v == x then return true end end
  return false
end

local function ena(t, n, cid)
  for _ = 1, n do t:put(cid or 200, 0, "ena") end
  return t:cards(0, "ena")
end

-- 시그니를 패에서 낸다(【出】이 트리거한다)
local function play(t, c, zone)
  t:expect(t:answer(t:action(ACT_PLAY, c, zone or "signi_left")))
end

-- ── Y01 爪牙　遊月・肆 ──

case("Y01: 【出】 레벨이 다른 ＜水獣＞ 4장을 공개하면 1장 뽑고 대상을 에나에. 같은 레벨이 섞이면 뽑기만", "WDK08-Y01", function(t)
  for _, same in ipairs({false, true}) do
    yz(t, "Y02")
    local h = {t:put(211, 0, "hand"), t:put(212, 0, "hand"), t:put(213, 0, "hand"), t:put(same and 213 or 214, 0, "hand")}
    local y01 = t:put(N["Y01"], 0, "lrig_deck")
    local x = t:put(201, 1, "signi_left")
    t:begin(0, PHASE_GROW)
    t:expect(t:wait(HINT_GROW))
    t:expect(t:answer(y01))
    t:expect(t:wait(HINT_TARGET))
    t:expect(t:answer(x))
    t:expect(t:wait(HINT_SELECT))
    local r = t:request()
    t:expect(r.min == 0 and r.max == 4, "공개하지 않아도 된다(FAQ 3)")
    t:expect(not t:answer({h[1], h[2]}), "0장 아니면 4장")
    t:expect(t:answer(h))
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:count(0, "hand") == 5, "공개한 카드는 패에 남고 1장 뽑는다")
    if same then
      t:expect(t:is_in(x, 1, "signi_left"), "같은 레벨이 있으면 에나에 놓지 않는다")
    else
      t:expect(t:is_in(x, 1, "ena"))
    end
  end
end)

case("Y01: 【出】 대상이 없어도 공개하고 뽑을 수 있다", "WDK08-Y01 FAQ 1", function(t)
  yz(t, "Y02")
  for i = 1, 4 do t:put(210 + i, 0, "hand") end
  local y01 = t:put(N["Y01"], 0, "lrig_deck")
  t:begin(0, PHASE_GROW)
  t:expect(t:wait(HINT_GROW))
  t:expect(t:answer(y01))
  t:expect(t:wait(HINT_SELECT))
  t:expect(not t:saw(HINT_TARGET))
  t:expect(t:answer(t:cards(0, "hand")))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "hand") == 5)
end)

case("Y01: 【起】 버린 ＜水獣＞의 파워만큼 내 ＜水獣＞ 1체 ＋", "WDK08-Y01", function(t)
  local center = yz(t, "Y01")
  local s = t:put(200, 0, "signi_left")
  local d = t:put(214, 0, "hand")
  t:put(201, 0, "hand")  -- ＜水獣＞가 아니라 버릴 수 없다
  local paid = ena(t, 1)
  main(t)
  t:expect(t:answer(t:action(ACT_ABILITY, center)))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(paid[1]))
  t:expect(t:wait(HINT_DISCARD))
  local o = t:request().options
  t:expect(#o == 1 and o[1] == d, "＜水獣＞만 버린다")
  t:expect(t:answer(d))
  t:expect(t:wait(HINT_TARGET), "코스트를 낸 뒤 대상")
  t:expect(t:answer(s))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:power(s) == 11000)
  t:expect(t:action(ACT_ABILITY, center) == nil, "《ターン１回》")
end)

-- ── Y06 遮断装甲 ──

case("Y06: ベット하면 《緑》×1로 쓸 수 있다. 《緑》×3을 못 내면 묻지 않고 ベット", "WDK08-Y06 FAQ 1", function(t)
  local arts, pay, tgt
  for _, coin in ipairs({false, true}) do
    yz(t, "Y01")
    arts = t:put(N["Y06"], 0, "lrig_deck")
    t:put(201, 0, "ena")  -- 백. 《緑》로 낼 수 없다
    pay = t:put(200, 0, "ena")
    tgt = t:put(214, 0, "ena")
    if coin then t:add_coin(0, 1) end
    t:begin(0, PHASE_ATTACK)
    t:expect(t:wait(HINT_PRE_ATTACK))
    if not coin then t:expect(t:action(ACT_USE, arts) == nil, "코인이 없으면 《緑》×3을 내야 한다") end
  end
  t:expect(t:answer(t:action(ACT_USE, arts)))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(not t:saw(HINT_BET), "ベット 코스트로만 낼 수 있으면 묻지 않는다")
  t:expect(t:answer(pay))
  t:expect(t:wait(HINT_TARGET))
  local o = t:request().options
  t:expect(#o == 1 and o[1] == tgt, "코스트로 고른 카드는 대상에서 빠진다")
  t:expect(t:answer(tgt))
  t:expect(t:wait(HINT_ZONE))
  t:expect(t:answer(t:request().options[1]))
  t:expect(t:wait(HINT_PRE_ATTACK))
  t:expect(t:at(tgt):find("signi") ~= nil and t:power(tgt) == 20000)
  t:expect(t:coins(0) == 0 and t:is_in(pay, 0, "trash"))
end)

case("Y06: 《緑》×3을 낼 수 있으면 ベット할지 묻는다", "WDK08-Y06 FAQ 1, 용어집: ベット", function(t)
  yz(t, "Y01")
  local arts = t:put(N["Y06"], 0, "lrig_deck")
  local paid = ena(t, 3)
  t:add_coin(0, 1)
  t:begin(0, PHASE_ATTACK)
  t:expect(t:wait(HINT_PRE_ATTACK))
  t:expect(t:answer(t:action(ACT_USE, arts)))
  t:expect(t:wait(HINT_BET))
  t:expect(t:answer(0))
  t:expect(t:wait(HINT_PAY_ENA))
  local r = t:request()
  t:expect(r.min == 3, "ベット하지 않으면 《緑》×3")
  t:expect(t:answer(paid))
  t:expect(t:wait(HINT_PRE_ATTACK))
  t:expect(t:coins(0) == 1)
end)

-- ── Y07 真空斬撃 ──

case("Y07: 공개한 시그니의 파워 이하만 바니시. ベット하면 대신 에나에 놓고 【エナチャージ１】", "WDK08-Y07 FAQ 1", function(t)
  for _, bet in ipairs({false, true}) do
    yz(t, "Y01")
    local arts = t:put(N["Y07"], 0, "lrig_deck")
    local paid = ena(t, 1)
    if bet then t:add_coin(0, 1) end
    local h = t:put(213, 0, "hand")  -- 7000
    local small, big = t:put(201, 1, "signi_left"), t:put(216, 1, "signi_center")  -- 3000, 8000
    t:begin(0, PHASE_ATTACK)
    t:expect(t:wait(HINT_PRE_ATTACK))
    t:expect(t:answer(t:action(ACT_USE, arts)))
    if bet then
      t:expect(t:wait(HINT_BET))
      t:expect(t:answer(1))
    end
    t:expect(t:wait(HINT_PAY_ENA))
    t:expect(t:answer(paid[1]))
    t:expect(t:wait(HINT_SELECT))
    t:expect(t:answer(h))
    t:expect(t:wait(HINT_TARGET))
    local o = t:request().options
    t:expect(#o == 1 and o[1] == small, "7000 이하만")
    t:expect(t:answer(small))
    t:expect(t:wait(HINT_PRE_ATTACK))
    t:expect(t:is_in(small, 1, "ena") and t:is_in(big, 1, "signi_center"))
    t:expect(t:count(0, "ena") == (bet and 1 or 0), "ベット하면 【エナチャージ１】")
  end
end)

case("Y07: ベット하고 공개하지 않으면 「バニッシュされない」 파워 0 시그니를 에나에 놓을 수 있다", "WDK08-Y07 FAQ 2·3", function(t)
  yz(t, "Y01")
  local arts = t:put(N["Y07"], 0, "lrig_deck")
  local paid = ena(t, 1)
  t:add_coin(0, 1)
  t:put(213, 0, "hand")
  local x = t:put(201, 1, "signi_left")
  t:single(x, EFFECT_CANNOT_BANISH, 0, 1)
  t:single(x, EFFECT_UPDATE_POWER, -3000, 1)
  t:begin(0, PHASE_ATTACK)
  t:expect(t:wait(HINT_PRE_ATTACK))
  t:expect(t:is_in(x, 1, "signi_left") and t:power(x) == 0, "룰 처리로도 바니시되지 않는다")
  t:expect(t:answer(t:action(ACT_USE, arts)))
  t:expect(t:wait(HINT_BET))
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(paid[1]))
  t:expect(t:wait(HINT_SELECT))
  t:expect(t:request().min == 0)
  t:expect(t:answer({}))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(x))
  t:expect(t:wait(HINT_PRE_ATTACK))
  t:expect(t:is_in(x, 1, "ena"))
end)

-- ── Y08 猛威継承 ──

case("Y08: 에나를 전부 패에, 5장을 넘는 만큼 골라 에나에", "WDK08-Y08 FAQ 1", function(t)
  yz(t, "Y01")
  local arts = t:put(N["Y08"], 0, "lrig_deck")
  ena(t, 4)
  for _ = 1, 3 do t:put(201, 0, "hand") end
  main(t)
  t:expect(t:answer(t:action(ACT_USE, arts)))
  t:expect(t:wait(HINT_SELECT))
  local r = t:request()
  t:expect(r.min == 2 and r.max == 2 and #r.options == 7, "7장 → 2장")
  t:expect(t:answer({r.options[1], r.options[2]}))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "hand") == 5 and t:count(0, "ena") == 2)
end)

-- ── Y09 鍵型闘娘　翠子 ──

case("Y09: 【常】 내 시그니 ＋1000, 【出】 덱 위 3장 중 녹색은 에나·나머지는 트래시, 【起】 키를 놓고 ＋20000", "WDK08-Y09 FAQ 1", function(t)
  yz(t, "Y01")
  local key = t:put(N["Y09"], 0, "lrig_deck")
  local s = t:put(200, 0, "signi_left")
  local g1, w, g2 = t:put(200, 0, "main_deck"), t:put(201, 0, "main_deck"), t:put(211, 0, "main_deck")
  t:add_coin(0, 1)
  main(t)
  t:expect(t:answer(t:action(ACT_KEY, key)))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(g1, 0, "ena") and t:is_in(g2, 0, "ena") and t:is_in(w, 0, "trash"))
  t:expect(t:power(s) == 2000)
  t:begin(0, PHASE_ATTACK)
  t:expect(t:wait(HINT_PRE_ATTACK))
  t:expect(t:answer(t:action(ACT_ABILITY, key)))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(s))
  t:expect(t:wait(HINT_PRE_ATTACK))
  t:expect(t:is_in(key, 0, "lrig_trash"))
  t:expect(t:power(s) == 21000, "키가 떠나 ＋1000은 없어지고 ＋20000")
end)

-- ── Y10 ファントム・ガーデン ──

case("Y10: 센터와 색이 같은 레벨이 다른 시그니. ベット하면 4장까지", "WDK08-Y10 FAQ 2·3", function(t)
  yz(t, "Y01")
  local arts = t:put(N["Y10"], 0, "lrig_deck")
  local paid = ena(t, 1)
  t:add_coin(0, 1)
  local a, b, c, d = t:put(211, 0, "trash"), t:put(211, 0, "trash"), t:put(212, 0, "trash"), t:put(213, 0, "trash")
  local e, w = t:put(214, 0, "trash"), t:put(216, 0, "trash")
  main(t)
  t:expect(t:answer(t:action(ACT_USE, arts)))
  t:expect(t:wait(HINT_BET))
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(paid[1]))
  t:expect(t:wait(HINT_TARGET))
  local r = t:request()
  t:expect(r.max == 4 and not contains(r.options, w), "백 시그니는 안 된다")
  t:expect(not t:answer({a, b}), "같은 레벨은 안 된다")
  t:expect(t:answer({a, c, d, e}))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "hand") == 4 and t:is_in(b, 0, "trash"))
end)

case("Y10: 대상 후보가 없으면 걸어 둔 「レベルの異なる」 검증은 다음 선택으로 넘어가지 않는다", "랜덤 대전 시드 219(WDK08_yuzuki 미러)", function(t)
  yz(t, "Y01")
  local garden, rage = t:put(N["Y10"], 0, "lrig_deck"), t:put(N["Y08"], 0, "lrig_deck")
  local paid = ena(t, 3, 201)  -- 코스트로 트래시에 가도 대상(＜水獣＞)이 아니게
  for _ = 1, 5 do t:put(201, 0, "hand") end
  main(t)
  t:expect(t:answer(t:action(ACT_USE, garden)))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(paid[1]))
  t:expect(t:wait(HINT_MAIN))
  t:expect(not t:saw(HINT_TARGET), "트래시가 비어 대상 선택이 없다")
  t:expect(t:answer(t:action(ACT_USE, rage)))
  t:expect(t:wait(HINT_SELECT))
  local h = t:cards(0, "hand")
  t:expect(t:answer({h[1], h[2]}), "같은 레벨 2장도 고를 수 있다")
end)

-- ── Y11 幻水　スピノー ──

case("Y11: 【出】 ＜水獣＞ 6장 공개면 【Ｓランサー】, 4장이면 【ランサー】", "WDK08-Y11", function(t)
  for _, n in ipairs({6, 4, 3}) do
    yz(t, "Y01")
    local sp = t:put(N["Y11"], 0, "hand")
    for _ = 1, 6 do t:put(200, 0, "hand") end
    main(t)
    play(t, sp)
    t:expect(t:wait(HINT_SELECT))
    local o = t:request().options
    t:expect(#o == 6, "자신은 장에 있어 후보가 아니다")
    local pick = {}
    for i = 1, n do pick[i] = o[i] end
    t:expect(t:answer(pick))
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:keyword(sp, EFFECT_S_LANCER) == (n >= 6), "6장 이상이면 【Ｓランサー】")
    t:expect(t:keyword(sp, EFFECT_LANCER) == (n == 4 or n == 5), "대신이라 둘 다는 아니다")
  end
end)

case("Sランサー: 배틀로 바니시하면 라이프 클로스가 있으면 크러시, 없으면 데미지(승리)", "용어집: Sランサー", function(t)
  for _, life in ipairs({true, false}) do
    yz(t, "Y01", {no_life = not life})
    local sp = t:put(200, 0, "signi_left")
    t:grant(sp, EFFECT_S_LANCER, 0, 0)
    t:grant(sp, EFFECT_LANCER, 0, 0)
    t:single(sp, EFFECT_UPDATE_POWER, 5000, 0)
    local f = t:put(201, 1, "signi_right")  -- 정면
    t:begin(0, PHASE_ATTACK)
    t:expect(t:wait(HINT_ATTACK_SIGNI))
    t:expect(t:answer(sp))
    if life then
      t:expect(t:wait(HINT_ATTACK_SIGNI))
      t:expect(t:is_in(f, 1, "ena"))
      t:expect(t:count(1, "life_cloth") == 4, "【ランサー】와 같이 있어도 1장")
    else
      t:wait(HINT_ATTACK_SIGNI)
      t:expect(t:ended() and t:winner() == 0, "라이프 클로스가 없으면 데미지")
    end
  end
end)

case("Y11: 파워 20000 이상인 동안만 「バニッシュされない」", "WDK08-Y11", function(t)
  for _, big in ipairs({true, false}) do
    yz(t, "Y01")
    local sp = t:put(N["Y11"], 0, "signi_left")
    if big then t:single(sp, EFFECT_UPDATE_POWER, 8000, 0) end
    local f = t:put(216, 1, "signi_right")
    t:single(f, EFFECT_UPDATE_POWER, 30000, 1)
    t:begin(1, PHASE_ATTACK)
    t:expect(t:wait(HINT_ATTACK_SIGNI))
    t:expect(t:answer(f))
    t:wait(HINT_ATTACK_SIGNI)
    t:expect(t:is_in(sp, 0, "signi_left") == big)
  end
end)

case("Y11: 라이프 버스트 《緑》를 내면 바니시가 아니라 에나에", "WDK08-Y11 FAQ 1", function(t)
  yz(t, "Y01")
  local lb = t:put(N["Y11"], 0, "life_cloth")
  local paid = ena(t, 1)
  local x = t:put(201, 1, "signi_left")
  t:single(x, EFFECT_CANNOT_BANISH, 0, 1)
  t:put(201, 1, "signi_right")
  t:begin(1, PHASE_ATTACK)
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:answer(t:cards(1, "signi_right")[1]))
  t:expect(t:wait(HINT_LIFEBURST))
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(x))
  t:expect(t:wait(HINT_SCRIPT))
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(paid[1]))
  t:wait(HINT_ATTACK_SIGNI)
  t:expect(t:is_in(x, 1, "ena") and t:is_in(lb, 0, "ena"), "크러시된 카드도 에나로")
end)

-- ── 패에서 공개: Y12 ダンクルテウス / Y13 カババン / Y15 アマケロ ──

case("Y12: 내 효과로 패에서 공개되면 패에서 트리거. 내고 버리면 바니시(버리는 카드는 같은 이름 아무거나)", "WDK08-Y12 FAQ 1", function(t)
  yz(t, "Y01")
  local sp = t:put(N["Y11"], 0, "hand")
  local d1, d2 = t:put(N["Y12"], 0, "hand"), t:put(N["Y12"], 0, "hand")
  local paid = ena(t, 4)
  local x = t:put(201, 1, "signi_left")
  main(t)
  play(t, sp)
  t:expect(t:wait(HINT_SELECT))
  t:expect(t:answer(d1))
  t:expect(t:wait(HINT_TARGET), "공개된 d1의 【自】")
  t:expect(t:answer(x))
  t:expect(t:wait(HINT_SCRIPT))
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(paid))
  t:expect(t:wait(HINT_SELECT))
  local o = t:request().options
  t:expect(#o == 2 and contains(o, d1) and contains(o, d2))
  t:expect(t:answer(d2))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(x, 1, "ena") and t:is_in(d2, 0, "trash") and t:is_in(d1, 0, "hand"))
end)

case("Y13·Y15: 공개 한 번에 アマケロ는 한 번, カババン은 버리면 ＋5000", "WDK08-Y13 FAQ 1, WDK08-Y15", function(t)
  yz(t, "Y01")
  local am = t:put(N["Y15"], 0, "signi_center")
  local kero = t:put(N["Y17"], 0, "hand")
  local k1, k2 = t:put(N["Y13"], 0, "hand"), t:put(N["Y13"], 0, "hand")
  local o1 = t:put(200, 0, "hand")
  local paid = ena(t, 1)
  main(t)
  play(t, kero)
  t:expect(t:wait(HINT_USE_TRIGGER), "코스트가 있으면 임의")
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:answer(paid[1]))
  t:expect(t:wait(HINT_SELECT))
  t:expect(t:answer({k1, k2, o1}))
  -- 같이 트리거: カババン 둘, アマケロ 하나
  t:expect(t:wait(HINT_TRIGGER_ORDER))
  t:expect(#t:request().options == 3, "カババン 2장 + アマケロ 1번")
  local oc = t:request().option_cards
  local first
  for i, c in ipairs(oc) do if c == k1 then first = i - 1 end end
  t:expect(first ~= nil and contains(oc, k2) and contains(oc, am))
  t:expect(t:answer(first))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(am))
  t:expect(t:wait(HINT_SCRIPT), "버릴지 고른다")
  t:expect(t:answer(1))
  t:expect(t:wait(HINT_SELECT))
  local o = t:request().options
  t:expect(#o == 2 and contains(o, k1) and contains(o, k2), "자신도 버릴 수 있다")
  t:expect(t:answer(k2))
  -- 버려진 k2의 【自】도 처리하지만 패에 カババン이 없어 아무것도 못 한다
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(am))
  t:expect(t:wait(HINT_MAIN))
  -- アマケロ 5000 + 자기 ＋5000 + カババン ＋5000(두 번째 カババン은 버릴 카드가 없어 못 한다)
  t:expect(t:power(am) == 15000, "아마케로 " .. t:power(am))
  t:expect(t:power(kero) == 2000 and t:keyword(kero, EFFECT_LANCER), "ケロモドキ ＋1000·【ランサー】")
end)

-- ── Y14 幻水　メガネワニ ──

case("Y14: 어택 시 ＜水獣＞ 2장을 공개하면 대상 에나 ＜水獣＞를 패에", "WDK08-Y14 FAQ 1", function(t)
  yz(t, "Y01")
  local m = t:put(N["Y14"], 0, "signi_left")
  local back = t:put(214, 0, "ena")
  local h1, h2 = t:put(200, 0, "hand"), t:put(200, 0, "hand")
  t:begin(0, PHASE_ATTACK)
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:answer(m))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(back))
  t:expect(t:wait(HINT_SELECT))
  t:expect(t:answer({h1, h2}))
  t:expect(t:wait(HINT_ATTACK_SIGNI))
  t:expect(t:is_in(back, 0, "hand"))
end)

-- ── Y20 斬衝 ──

case("Y20: ① 내 ＜水獣＞를 트래시에 놓은 뒤 그 파워 이하를 바니시. 없으면 바니시하지 않는다", "WDK08-Y20 FAQ 1", function(t)
  yz(t, "Y01")
  local sp = t:put(N["Y20"], 0, "hand")
  local x = t:put(201, 1, "signi_left")
  main(t)
  t:expect(t:answer(t:action(ACT_USE, sp)))
  t:expect(t:wait(HINT_MODE))
  t:expect(t:answer(0))
  t:expect(t:wait(HINT_MAIN))
  t:expect(not t:saw(HINT_TARGET) and t:is_in(x, 1, "signi_left"))
  -- 있으면
  yz(t, "Y01")
  sp = t:put(N["Y20"], 0, "hand")
  local mine = t:put(213, 0, "signi_left")  -- 7000
  local small, big = t:put(201, 1, "signi_left"), t:put(216, 1, "signi_center")
  main(t)
  t:expect(t:answer(t:action(ACT_USE, sp)))
  t:expect(t:wait(HINT_MODE))
  t:expect(t:answer(0))
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:answer(mine))
  t:expect(t:wait(HINT_TARGET))
  local o = t:request().options
  t:expect(#o == 1 and o[1] == small, "7000 이하만")
  t:expect(t:answer(small))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(mine, 0, "trash") and t:is_in(small, 1, "ena") and t:is_in(big, 1, "signi_center"))
end)

