-- WX02 부스터 카드 스크립트 케이스. 근거는 카드별 FAQ(cards.json)

local N = {}
local WS, RS, US, GS, KS, OPP, MID, BIG = 200000, 200001, 200002, 200003, 200004, 101000, 101500, 102000
local ARM, WEP, ANG, WAT, PLA, GEM, BURST = 200010, 200011, 200012, 200013, 200014, 200015, 200016

-- lrig·p1: 이 부스터의 번호(숫자)나 카드 번호 문자열("WX01-003"). N은 여기서 채우므로 부르는 쪽에서 N[...]을 쓰지 않는다
local function wd(t, lrig, p1)
  t:start{db = true, seed = 1}
  for i = 1, 80 do N[i] = t:no(("WX02-%03d"):format(i)) end
  local function pick_card(x) return type(x) == "string" and t:no(x) or N[x] end
  lrig, p1 = pick_card(lrig or 1), p1 and pick_card(p1)
  t:signi(WS, 1000, COLOR_WHITE, 1)
  t:signi(RS, 1000, COLOR_RED, 1)
  t:signi(US, 1000, COLOR_BLUE, 1)
  t:signi(GS, 1000, COLOR_GREEN, 1)
  t:signi(KS, 1000, COLOR_BLACK, 1)
  t:signi(OPP, 3000, COLOR_GREEN, 1)
  t:signi(MID, 5000, COLOR_GREEN, 2)
  t:signi(BIG, 15000, COLOR_GREEN, 4)
  t:card{cid = ARM, power = 2000, level = 1, classes = {"精武：アーム"}, color = COLOR_WHITE}
  t:card{cid = WEP, power = 2000, level = 2, classes = {"精武：ウェポン"}, color = COLOR_RED}
  t:card{cid = ANG, power = 2000, level = 1, classes = {"精像：天使"}, color = COLOR_WHITE}
  t:card{cid = WAT, power = 2000, level = 1, classes = {"精生：水獣"}, color = COLOR_BLUE}
  t:card{cid = PLA, power = 2000, level = 1, classes = {"精羅：植物"}, color = COLOR_GREEN}
  t:card{cid = GEM, power = 2000, level = 1, classes = {"精羅：宝石"}, color = COLOR_RED}
  t:card{cid = BURST, power = 1000, level = 1, color = COLOR_RED, burst = 1}
  t:fill(WS, 0, "main_deck", 15)
  t:fill(OPP, 1, "main_deck", 15)
  t:fill(WS, 0, "life_cloth", 5)
  t:fill(OPP, 1, "life_cloth", 5)
  t:put(p1 or t:no("WX01-019"), 1, "lrig_center")
  return t:put(lrig, 0, "lrig_center")
end

local function main(t, p)
  t:begin(p or 0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
end

local function ena(t, n, cid)
  for _ = 1, n do t:put(cid or WS, 0, "ena") end
end

local function pay(t, n)
  t:expect(t:wait(HINT_PAY_ENA), "에나 " .. n)
  t:expect(t:request().min == n, "코스트 " .. n)
  t:expect(t:answer(table.unpack(t:request().options, 1, n)))
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

-- ── 루리그 ──

case("火鳥風月 遊月・肆: 모든 카드가 LB 【エナチャージ１】. 원래 LB가 있으면 둘 다 고른다", "WX02-002 FAQ 3", function(t)
  local lc = wd(t, 2)
  for _, c in ipairs(t:cards(0, "life_cloth")) do t:move(c, 0, "exclude") end
  t:script(BURST, [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_LIFEBURST)
  e1:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e1)
end]])
  t:put(WS, 0, "life_cloth")
  t:put(BURST, 0, "life_cloth")
  local x = t:put(BIG, 1, "signi_left")
  t:single(x, EFFECT_DOUBLE_CRUSH, 1, 1)
  t:begin(1, PHASE_ATTACK)
  pick(t, HINT_ATTACK_SIGNI, x)
  local n = 0
  for _ = 1, 20 do
    t:step()
    local q = t:request()
    if not q or q.hint == HINT_ATTACK_LRIG then break end
    if q.hint == HINT_LIFEBURST then
      n = n + 1
      t:answer(1)
    else
      t:answer(table.unpack(q.options, 1, math.max(q.min, 1)))
    end
  end
  t:expect(n == 3, "LB 질문 " .. n)
  t:expect(t:count(0, "hand") == 1 and t:count(0, "ena") == 4, "에나 차지 2 + 크러시된 2: " .. t:count(0, "hand") .. " " .. t:count(0, "ena"))
end)

case("火鳥風月 遊月・肆: 【出】 내 라이프 1장 크러시(강제), 【起】 다운하고 상대 1장", "WX02-002 FAQ 5", function(t)
  wd(t, 7)
  local g = t:put(N[2], 0, "lrig_deck")
  ena(t, 2, RS)
  ena(t, 2, GS)
  t:begin(0, PHASE_GROW)
  pick(t, HINT_GROW, g)
  pay(t, 4)
  t:step()
  if t:request().hint == HINT_LIFEBURST then t:answer(0) end
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "life_cloth") == 4)
  t:expect(t:answer(t:action(ACT_ABILITY, g)))
  t:wait(HINT_MAIN)
  t:expect(t:count(1, "life_cloth") == 4 and t:flags(g) & CF_DOWN ~= 0)
end)

case("エルドラ×マークⅣ: 라이프가 크러시될 때마다 1장 뽑아도 된다(2장이면 2번)", "WX02-003 FAQ 2", function(t)
  wd(t, 3)
  local x = t:put(BIG, 1, "signi_left")
  t:single(x, EFFECT_DOUBLE_CRUSH, 1, 1)
  t:begin(1, PHASE_ATTACK)
  pick(t, HINT_ATTACK_SIGNI, x)
  local n = 0
  for _ = 1, 20 do
    t:step()
    local q = t:request()
    if not q or q.hint == HINT_ATTACK_LRIG then break end
    if q.hint == HINT_SCRIPT then
      n = n + 1
      t:answer(1)
    else
      t:answer(table.unpack(q.options, 1, math.max(q.min, 1)))
    end
  end
  t:expect(n == 2 and t:count(0, "hand") == 2, n .. " " .. t:count(0, "hand"))
end)

case("ホワイト・ホープ: 레벨 2 이하 ＜アーム＞·＜ウェポン＞ 2장까지 내고 턴 종료 시 트래시. 떠난 것은 아니다", "WX02-005 FAQ 1·3", function(t)
  wd(t)
  local a, x, y = t:put(N[5], 0, "lrig_deck"), t:put(ARM, 0, "main_deck"), t:put(WEP, 0, "main_deck")
  ena(t, 2)
  ena(t, 1, RS)
  main(t)
  use(t, a)
  pay(t, 3)
  pick(t, HINT_SELECT, x, y)
  zone(t)
  zone(t)
  t:expect(t:wait(HINT_MAIN))
  t:move(y, 0, "ena")
  t:answer(t:action(ACT_END))
  t:expect(t:wait(HINT_ENA_CHARGE))
  t:expect(t:is_in(x, 0, "trash") and t:is_in(y, 0, "ena"))
end)

case("ブラック・デザイア: 트래시 25장이면 내 것까지 모든 시그니를 바니시(코스트 포함해서 센다)", "WX02-006 FAQ 1·2", function(t)
  for _, n in ipairs{22, 21} do
    wd(t, 4)
    local a, m, x = t:put(N[6], 0, "lrig_deck"), t:put(KS, 0, "signi_left"), t:put(BIG, 1, "signi_left")
    for _ = 1, n do t:put(KS, 0, "trash") end
    ena(t, 3, KS)
    main(t)
    use(t, a)
    pay(t, 3)
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(m, 0, n == 22 and "ena" or "signi_left") and t:is_in(x, 1, n == 22 and "ena" or "signi_left"), n)
  end
end)

case("気炎万丈: 크러시한 카드가 LB를 가지면 10000 이하 모두 바니시(遊月・肆로 얻은 것도). LB는 그 뒤", "WX02-017 FAQ 1·2", function(t)
  for _, c in ipairs{{7, WS, false}, {7, BURST, true}, {2, WS, true}} do
    wd(t, c[1])
    local a, x, y = t:put(N[17], 0, "lrig_deck"), t:put(MID, 1, "signi_left"), t:put(BIG, 1, "signi_center")
    t:put(c[2], 0, "life_cloth")
    ena(t, 1, RS)
    ena(t, 1, GS)
    main(t)
    use(t, a)
    pay(t, 2)
    if c[3] then
      t:expect(t:wait(HINT_LIFEBURST))
      t:expect(t:is_in(x, 1, "ena"), "LB를 묻기 전에 바니시")
      t:answer(0)
    end
    t:wait(HINT_MAIN)
    t:expect(t:is_in(x, 1, c[3] and "ena" or "signi_left") and t:is_in(y, 1, "signi_center"))
  end
end)

case("クロス・ライフ・クロス: 맨 위를 패에, 패 1장을 라이프에. 0장이면 아무것도", "WX02-019 FAQ 1~3", function(t)
  for _, n in ipairs{5, 0} do
    wd(t, 3)
    local a = t:put(N[19], 0, "lrig_deck")
    if n == 0 then for _, c in ipairs(t:cards(0, "life_cloth")) do t:move(c, 0, "exclude") end end
    local h = t:put(US, 0, "hand")
    local top = n > 0 and t:cards(0, "life_cloth")[n]
    ena(t, 1, US)
    main(t)
    use(t, a)
    pay(t, 1)
    if n > 0 then pick(t, HINT_SELECT, top) end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:count(0, "life_cloth") == n and t:is_in(h, 0, "hand"))
  end
end)

-- ── 시그니 ──

case("ガンスナイプ: LB 고를 때 파워 합계 8000 이하", "WX02-022 FAQ 1", function(t)
  wd(t, "WX01-003", "WX01-001")  -- 상대 루리그는 파워를 바꾸지 않는 것
  t:put(N[22], 0, "life_cloth")
  local a, b, c = t:put(MID, 1, "signi_left"), t:put(OPP, 1, "signi_center"), t:put(BIG, 1, "signi_right")
  t:begin(1, PHASE_ATTACK)
  pick(t, HINT_ATTACK_SIGNI, c)
  pick(t, HINT_LIFEBURST, 1)
  t:expect(t:wait(HINT_TARGET))
  local first = t:answer(a, b, c)
  t:expect(not first, "3체는 18000")
  t:expect(t:answer(a, b), "2체는 8000")
  t:wait(HINT_ATTACK_SIGNI)
  t:expect(t:is_in(a, 1, "ena") and t:is_in(b, 1, "ena"))
end)

case("ガンスナイプ: 라이프 3장 이하면 ＜ウェポン＞ ＋2000", "WX02-022", function(t)
  wd(t, "WX01-003")
  local g, w = t:put(N[22], 0, "signi_left"), t:put(WEP, 0, "signi_center")
  t:expect(t:power(w) == 2000)
  for i, c in ipairs(t:cards(0, "life_cloth")) do if i > 3 then t:move(c, 0, "exclude") end end
  t:expect(t:power(w) == 4000 and t:power(g) == 14000, "자신도 ＜ウェポン＞")
end)

case("スパイラル・カーミラ: 패가 2장 많으면 ＜水獣＞ ＋2000(2체면 ＋4000)", "WX02-023 FAQ 1", function(t)
  wd(t, 3)
  t:put(N[23], 0, "signi_left")
  t:put(N[23], 0, "signi_center")
  local w = t:put(WAT, 0, "signi_right")
  for _ = 1, 2 do t:put(US, 0, "hand") end
  t:expect(t:power(w) == 6000)
end)

case("ゴーシュ・アグネス: 업 상태의 ＜植物＞를 다운해 에나 차지. 1체에 1장", "WX02-024 FAQ 1", function(t)
  wd(t, "WX01-019")
  local h, p = t:put(N[24], 0, "signi_left"), t:put(PLA, 0, "signi_center")
  main(t)
  t:expect(t:answer(t:action(ACT_ABILITY, h)))
  pick(t, HINT_SELECT, p)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "ena") == 1 and t:flags(p) & CF_DOWN ~= 0 and t:flags(h) & CF_DOWN == 0)
end)

case("ウィッシュ・クライシス: ＜天使＞를 놓고 2장까지. 함께 낼 수 있는 것만", "WX02-026 FAQ 2·3", function(t)
  wd(t)
  local sp, h = t:put(N[26], 0, "hand"), t:put(ANG, 0, "signi_left")
  t:put(WS, 0, "signi_center")
  t:put(WS, 0, "signi_right")
  local a, b = t:put(ANG, 0, "main_deck"), t:put(ANG, 0, "main_deck")
  ena(t, 1)
  main(t)
  use(t, sp)
  pay(t, 1)
  pick(t, HINT_TARGET, h)
  t:expect(t:wait(HINT_SELECT))
  t:expect(not t:answer(a, b), "존이 1개뿐")
  t:expect(t:answer(a))
  zone(t)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(a, 0, "signi_left") and t:is_in(b, 0, "main_deck"))
end)

case("焦土の代償: 놓은 수만큼 상대를 고른다. 컷인으로 하나가 사라지면 그만큼 줄어든다", "WX02-027 FAQ 1·2", function(t)
  wd(t, 7)
  local sp, a, b = t:put(N[27], 0, "hand"), t:put(ARM, 0, "signi_left"), t:put(WEP, 0, "signi_center")
  local x, y = t:put(BIG, 1, "signi_left"), t:put(OPP, 1, "signi_center")
  t:put(OPP, 1, "signi_right")
  ena(t, 2, RS)
  main(t)
  use(t, sp)
  pay(t, 2)
  pick(t, HINT_TARGET, a, b)
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:request().min == 2 and t:answer(x, y))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(x, 1, "ena") and t:is_in(y, 1, "ena") and t:is_in(a, 0, "trash"))
end)

case("ミカガミ·カーネリアン·ハチ: 덱 위가 맞으면 패에, 아니면 그대로", "WX02-030 FAQ 1, WX02-033 FAQ 1, WX02-039 FAQ 1", function(t)
  for _, c in ipairs{{30, ARM, true}, {30, WS, false}, {33, GEM, true}} do
    wd(t, c[1] == 33 and 7 or nil)
    local h, top = t:put(N[c[1]], 0, "signi_left"), t:put(c[2], 0, "main_deck")
    main(t)
    t:expect(t:answer(t:action(ACT_ABILITY, h)))
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(top, 0, c[3] and "hand" or "main_deck"))
  end
end)

case("望まぬ衝動: 에나에 적과 녹 카드가 있어야. 【マルチエナ】는 아니다", "WX02-034 FAQ 1", function(t)
  for _, c in ipairs{{RS, GS, true}, {t, t, false}} do
    wd(t, 7)
    local sp, x = t:put(N[34], 0, "hand"), t:put(BIG, 1, "signi_left")
    if c[3] then
      ena(t, 1, RS)
      ena(t, 1, GS)
    else
      ena(t, 1, RS)
      t:put(t:no("WX01-101"), 0, "ena")
    end
    ena(t, 1, RS)
    ena(t, 1, GS)
    main(t)
    use(t, sp)
    t:expect(t:wait(HINT_PAY_ENA))
    local o = t:request().options
    t:expect(t:answer(o[#o - 1], o[#o]))
    pick(t, HINT_TARGET, x)
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(x, 1, c[3] and "ena" or "signi_left"))
  end
end)

case("SPRASH: ＜水獣＞를 바니시해야 2장", "WX02-037 FAQ 1", function(t)
  wd(t, 3)
  local sp, w = t:put(N[37], 0, "hand"), t:put(WAT, 0, "signi_left")
  ena(t, 2, US)
  main(t)
  use(t, sp)
  pay(t, 2)
  pick(t, HINT_TARGET, w)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(w, 0, "ena") and t:count(0, "hand") == 2)
end)

case("着植: LB는 다음 내 턴 동안 모든 시그니가 【ランサー】(나중에 나온 것도). 그 턴만", "WX02-040 FAQ 2·4", function(t)
  wd(t, "WX01-019")
  t:put(N[40], 0, "life_cloth")
  local x = t:put(BIG, 1, "signi_left")
  local late = t:put(GS, 0, "hand")
  t:begin(1, PHASE_ATTACK)
  pick(t, HINT_ATTACK_SIGNI, x)
  pick(t, HINT_LIFEBURST, 1)
  t:expect(t:wait(HINT_ATTACK_LRIG))
  local a = t:put(GS, 0, "signi_left")
  t:expect(not t:keyword(a, EFFECT_LANCER), "상대 턴")
  t:expect(t:wait(HINT_MAIN) and t:request().player == 0)
  t:expect(t:keyword(a, EFFECT_LANCER))
  play(t, late, "signi_center")
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:keyword(late, EFFECT_LANCER))
  t:answer(t:action(ACT_END))
  t:expect(t:wait(HINT_ENA_CHARGE) and t:request().player == 1)
  t:expect(not t:keyword(a, EFFECT_LANCER))
end)

case("キティラ: 3장 공개, ＜古代兵器＞ 1장을 패에, 나머지 트래시", "WX02-043 FAQ 1", function(t)
  wd(t, 4)
  local h = t:put(N[43], 0, "signi_left")
  local a, b, c = t:put(KS, 0, "main_deck"), t:put(N[71], 0, "main_deck"), t:put(KS, 0, "main_deck")
  main(t)
  t:expect(t:answer(t:action(ACT_ABILITY, h)))
  pick(t, HINT_SELECT, b)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(b, 0, "hand") and t:is_in(a, 0, "trash") and t:is_in(c, 0, "trash"))
end)

case("サクリファイス・スラッシュ: 내 시그니를 바니시해야 상대도", "WX02-045 FAQ 1·2", function(t)
  wd(t, 4)
  local sp, m, x = t:put(N[45], 0, "hand"), t:put(KS, 0, "signi_left"), t:put(BIG, 1, "signi_left")
  ena(t, 3, KS)
  main(t)
  use(t, sp)
  pay(t, 3)
  pick(t, HINT_TARGET, m)
  pick(t, HINT_TARGET, x)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(m, 0, "ena") and t:is_in(x, 1, "ena"))
end)

case("キュアエル·ランチャーギア·ミズアオイ: 다른 같은 종족이 있으면 기본 파워", "WX02-046·051·062", function(t)
  wd(t)
  local a = t:put(N[46], 0, "signi_left")
  t:expect(t:power(a) == 8000)
  t:put(ANG, 0, "signi_center")
  t:expect(t:power(a) == 12000)
end)

case("BLUEGAIN·豊潤: 처리할 때 센 수만큼", "WX02-061 FAQ 2, WX02-066 FAQ 2", function(t)
  wd(t, 3)
  local sp = t:put(N[61], 0, "hand")
  t:put(WAT, 0, "signi_left")
  t:put(N[58], 0, "signi_center")
  t:put(US, 0, "signi_right")
  ena(t, 2, US)
  main(t)
  use(t, sp)
  pay(t, 2)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "hand") == 2)
end)

case("デリー: 트래시에 있을 때만 장에. 에나에서 코스트로 놓아도 안 된다", "WX02-071 FAQ 1", function(t)
  wd(t, 4)
  local d = t:put(N[71], 0, "trash")
  local e = t:put(N[71], 0, "ena")
  ena(t, 2, KS)
  main(t)
  t:expect(t:action(ACT_ABILITY, e) == nil)
  t:expect(t:answer(t:action(ACT_ABILITY, d)))
  t:expect(t:wait(HINT_PAY_ENA))
  local o = t:request().options
  t:expect(t:answer(o[#o - 1], o[#o]))
  zone(t)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:at(d) ~= "trash")
end)

case("グリム: 트래시 2장 이상이면 기본 5000", "WX02-074", function(t)
  wd(t, 4)
  local g = t:put(N[74], 0, "signi_left")
  t:put(KS, 0, "trash")
  t:expect(t:power(g) == 2000)
  t:put(KS, 0, "trash")
  t:expect(t:power(g) == 5000)
end)
