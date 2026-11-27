-- WX03 부스터 카드 스크립트 케이스. 근거는 카드별 FAQ(cards.json)

local N = {}
local WS, RS, US, GS, KS, OPP, MID, BIG = 200000, 200001, 200002, 200003, 200004, 101000, 101500, 102000
local ANC1, ANC2, ANC3, ANG, WAT, PLA, DEN1, DEN3 = 200010, 200011, 200012, 200013, 200014, 200015, 200016, 200017

-- lrig·p1: 이 부스터의 번호(숫자)나 카드 번호 문자열. N은 여기서 채우므로 부르는 쪽에서 N[...]을 쓰지 않는다
local function wd(t, lrig, p1)
  t:start{db = true, seed = 1}
  for i = 1, 50 do N[i] = t:no(("WX03-%03d"):format(i)) end
  local function pick_card(x) return type(x) == "string" and t:no(x) or N[x] end
  lrig, p1 = pick_card(lrig or 10), p1 and pick_card(p1)
  t:signi(WS, 1000, COLOR_WHITE, 1)
  t:signi(RS, 1000, COLOR_RED, 1)
  t:signi(US, 1000, COLOR_BLUE, 1)
  t:signi(GS, 1000, COLOR_GREEN, 1)
  t:signi(KS, 1000, COLOR_BLACK, 1)
  t:signi(OPP, 3000, COLOR_GREEN, 1)
  t:signi(MID, 9000, COLOR_GREEN, 3)
  t:signi(BIG, 15000, COLOR_GREEN, 4)
  for i, lv in ipairs{1, 2, 3} do
    t:card{cid = ({ANC1, ANC2, ANC3})[i], power = 2000, level = lv, classes = {"精械：古代兵器"}, color = COLOR_BLACK}
  end
  t:card{cid = ANG, power = 2000, level = 1, classes = {"精像：天使"}, color = COLOR_WHITE}
  t:card{cid = WAT, power = 2000, level = 1, classes = {"精生：水獣"}, color = COLOR_BLUE}
  t:card{cid = PLA, power = 2000, level = 1, classes = {"精羅：植物"}, color = COLOR_GREEN}
  t:card{cid = DEN1, power = 2000, level = 1, classes = {"精械：電機"}, color = COLOR_BLUE}
  t:card{cid = DEN3, power = 2000, level = 3, classes = {"精械：電機"}, color = COLOR_BLUE}
  t:fill(WS, 0, "main_deck", 15)
  t:fill(OPP, 1, "main_deck", 15)
  t:fill(WS, 0, "life_cloth", 5)
  t:fill(OPP, 1, "life_cloth", 5)
  t:put(p1 or t:no("WX01-001"), 1, "lrig_center")
  return t:put(lrig, 0, "lrig_center")
end

local function main(t, p)
  t:begin(p or 0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
end

local function ena(t, n, cid)
  for _ = 1, n do t:put(cid or KS, 0, "ena") end
end

local function pay(t, n)
  t:expect(t:wait(HINT_PAY_ENA), "에나 " .. n)
  t:expect(t:request().min == n, "코스트 " .. n .. " / " .. t:request().min)
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

case("ウムル＝フィーラ: ＜古代兵器＞를 놓고 같은 레벨의 시그니를 바니시(내 것도 고를 수 있다)", "WX03-001", function(t)
  local lc = wd(t, 1)
  local a, x, y = t:put(ANC3, 0, "signi_left"), t:put(MID, 1, "signi_left"), t:put(OPP, 1, "signi_center")
  ena(t, 2)
  main(t)
  t:expect(t:answer(t:action(ACT_ABILITY, lc)))
  t:step()
  if t:request().hint == HINT_PAY_ENA then t:answer(table.unpack(t:request().options, 1, 2)) end
  t:step()
  if t:request().hint == HINT_SELECT then t:answer(a) end
  t:expect(t:wait(HINT_TARGET))
  t:expect(#t:request().options == 1 and t:answer(x))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(a, 0, "trash") and t:is_in(x, 1, "ena") and t:is_in(y, 1, "signi_center"))
end)

case("基本コスト: 상대 센터가 그 색이면 줄어든다", "WX03-002~005, WX03-014", function(t)
  for _, c in ipairs{{3, "WX01-019", 2}, {3, "WX01-001", 5}, {2, "WX02-004", 2}, {14, "WX01-001", 1}} do
    wd(t, 10, c[2])
    local a = t:put(N[c[1]], 0, "lrig_deck")
    t:put(BIG, 1, "signi_left")
    t:put(KS, 0, "trash")
    ena(t, 5, c[1] == 3 and RS or (c[1] == 2 and WS or KS))
    main(t)
    t:expect(t:answer(t:action(ACT_USE, a)), "쓸 수 있다")
    t:expect(t:wait(HINT_PAY_ENA))
    t:expect(t:request().min == c[3], c[1] .. " " .. c[2] .. " 코스트 " .. t:request().min)
  end
end)

case("ホーリーアクト: ＜天使＞가 아닌 것만", "WX03-002", function(t)
  wd(t, 10, "WX02-004")
  local a, x = t:put(N[2], 0, "lrig_deck"), t:put(ANG, 1, "signi_left")
  local y = t:put(OPP, 1, "signi_center")
  ena(t, 2, WS)
  main(t)
  use(t, a)
  pay(t, 2)
  t:expect(t:wait(HINT_TARGET))
  t:expect(#t:request().options == 1 and t:answer(y))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(y, 1, "trash") and t:is_in(x, 1, "signi_left"))
end)

case("デス・コロッサオ: 놓아도 안 놓아도 된다. 레벨이 다른 3체면 상대를 모두 바니시", "WX03-015 FAQ 1·2", function(t)
  for _, c in ipairs{{{ANC1, ANC2, ANC3}, 1, true}, {{ANC1, ANC1, ANC3}, 1, false}, {{ANC1, ANC2, ANC3}, 0, false}} do
    wd(t, 1)
    local a = t:put(N[15], 0, "lrig_deck")
    local l = {}
    for i, z in ipairs{"signi_left", "signi_center", "signi_right"} do l[i] = t:put(c[1][i], 0, z) end
    local x = t:put(BIG, 1, "signi_left")
    ena(t, 3)
    main(t)
    use(t, a)
    pay(t, 3)
    pick(t, HINT_SCRIPT, c[2])
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(l[1], 0, c[2] == 1 and "trash" or "signi_left") and t:is_in(x, 1, c[3] and "ena" or "signi_left"))
  end
end)

case("ロスト・テクノロジー: ＜古代兵器＞ 3체를 놓으면 상대 라이프 2장(함께 크러시)", "WX03-021 FAQ 1·3", function(t)
  wd(t, 1)
  local sp = t:put(N[21], 0, "hand")
  for _, z in ipairs{"signi_left", "signi_center", "signi_right"} do t:put(ANC1, 0, z) end
  ena(t, 1)
  main(t)
  use(t, sp)
  pay(t, 1)
  pick(t, HINT_SCRIPT, 1)
  t:wait(HINT_MAIN)
  t:expect(t:count(1, "life_cloth") == 3)
end)

case("ラビエル 등: 루리그 덱의 그 색 아츠를 루리그 트래시에 둔다. 없으면 쓸 수 없다", "WX03-016~019", function(t)
  for _, has in ipairs{true, false} do
    wd(t, "WX01-001")
    local h, x = t:put(N[16], 0, "hand"), t:put(BIG, 1, "signi_left")
    local a = has and t:put(t:no("WX01-010"), 0, "lrig_deck")
    ena(t, 1, WS)
    main(t)
    play(t, h)
    if has then
      pick(t, HINT_USE_TRIGGER, 1)
      pay(t, 1)
      pick(t, HINT_SELECT, a)
      pick(t, HINT_TARGET, x)
    end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(x, 1, has and "hand" or "signi_left") and not (not has and t:saw(HINT_USE_TRIGGER)))
  end
end)

case("パルテノ: 트래시에서 나오면 모두 ＋2000. 자신도 트리거하고 2체면 각각", "WX03-020 FAQ 1·2", function(t)
  wd(t, 1)
  local h, b = t:put(N[20], 0, "hand"), t:put(N[20], 0, "trash")
  local k = t:put(KS, 0, "signi_right")
  ena(t, 2)
  main(t)
  play(t, h)
  pick(t, HINT_USE_TRIGGER, 1)
  pay(t, 2)
  pick(t, HINT_TARGET, b)
  zone(t)
  t:step()
  if t:request().hint == HINT_TRIGGER_ORDER then t:answer(0) end
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:power(k) == 5000, "2체가 각각 ＋2000: " .. t:power(k))
end)

case("カクマル·アヤボン: 서로 있으면 8000. 루리그 트래시 7장이면 【ダブルクラッシュ】", "WX03-023, WX03-026 FAQ 2", function(t)
  wd(t, "WX01-003")
  local k, a = t:put(N[23], 0, "signi_left"), t:put(N[26], 0, "signi_center")
  t:expect(t:power(k) == 8000 and t:power(a) == 8000 and not t:keyword(a, EFFECT_DOUBLE_CRUSH))
  for _ = 1, 7 do t:put(t:no("WX01-014"), 0, "lrig_trash") end
  t:expect(t:keyword(a, EFFECT_DOUBLE_CRUSH))
end)

case("ゲット・グロウ: 공통 루리그 타입이 없으면 그로우하지 않는다", "WX03-024 FAQ 3·4", function(t)
  local lc = wd(t, "WX01-001")
  local sp, g, other = t:put(N[24], 0, "hand"), t:put(t:no("WX01-002"), 0, "lrig_deck"), t:put(t:no("WX01-003"), 0, "lrig_deck")
  t:set_flags(lc, CF_DOWN)
  ena(t, 1, WS)
  main(t)
  use(t, sp)
  pay(t, 1)
  pick(t, HINT_SELECT, other)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(lc, 0, "lrig_center") and t:is_in(other, 0, "lrig_deck"), "<花代>는 <タマ>와 공통 타입이 없다")
end)

case("ゲット・グロウ: 그로우하면 다운 상태 그대로, 아래에 쌓인다", "WX03-024 FAQ 4", function(t)
  local lc = wd(t, "WX01-001")
  local sp, g = t:put(N[24], 0, "hand"), t:put(t:no("WX01-002"), 0, "lrig_deck")
  t:set_flags(lc, CF_DOWN)
  ena(t, 1, WS)
  main(t)
  use(t, sp)
  pay(t, 1)
  pick(t, HINT_SELECT, g)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(g, 0, "lrig_center") and t:flags(g) & CF_DOWN ~= 0 and t:under(g)[1] == lc)
end)

case("ゲット・グロウ: LB 다음 내 턴, 루리그 타입이 완전히 같은 루리그의 그로우 코스트 0", "WX03-024 FAQ 2", function(t)
  wd(t, "WX01-009")
  t:put(N[24], 0, "life_cloth")
  local g = t:put(t:no("WX01-008"), 0, "lrig_deck")
  local x = t:put(BIG, 1, "signi_left")
  t:begin(1, PHASE_ATTACK)
  pick(t, HINT_ATTACK_SIGNI, x)
  pick(t, HINT_LIFEBURST, 1)
  t:expect(t:wait(HINT_GROW))
  t:expect(t:request().player == 0 and t:answer(g))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(g, 0, "lrig_center") and not t:saw(HINT_PAY_ENA))
end)

case("R・G・N: 청 아츠 《無》 1 줄어든다. 루리그 덱 0장이면 18000", "WX03-028 FAQ 1", function(t)
  wd(t, "WX01-016")
  local h = t:put(N[28], 0, "signi_left")
  local a = t:put(t:no("WX01-018"), 0, "lrig_deck")
  t:expect(t:power(h) == 11000, "피루루크Β ＋1000")
  t:move(a, 0, "lrig_trash")
  t:expect(t:power(h) == 19000)
end)

case("C・V・Y: 레벨 1·3·4 ＜電機＞마다", "WX03-029", function(t)
  wd(t, "WX01-001")
  local h = t:put(N[29], 0, "signi_left")
  t:put(DEN1, 0, "signi_center")
  t:expect(t:power(h) == 7000)
  t:put(DEN3, 0, "signi_right")
  t:expect(t:power(h) == 10000)
end)

case("PICK UP: 둘 다 버리고 많은 쪽 장수만큼 둘 다 뽑는다", "WX03-030 FAQ 1", function(t)
  wd(t, "WX01-016")
  local sp = t:put(N[30], 0, "hand")
  t:put(US, 0, "hand")
  for _ = 1, 3 do t:put(OPP, 1, "hand") end
  ena(t, 2, US)
  main(t)
  use(t, sp)
  pay(t, 2)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "hand") == 3 and t:count(1, "hand") == 3 and t:count(1, "trash") == 3)
end)

case("ベイア: 내 시그니가 크러시하면 에나 차지(2장이면 2번)", "WX03-031 FAQ 2", function(t)
  wd(t, "WX01-019")
  local b = t:put(N[31], 0, "signi_left")
  t:single(b, EFFECT_DOUBLE_CRUSH, 1, 0)
  t:begin(0, PHASE_ATTACK)
  pick(t, HINT_ATTACK_SIGNI, b)
  for _ = 1, 4 do
    t:step()
    local q = t:request()
    if not q or q.hint ~= HINT_TRIGGER_ORDER then break end
    t:answer(0)
  end
  t:wait(HINT_ATTACK_LRIG)
  t:expect(t:count(0, "ena") == 2 and t:count(1, "life_cloth") == 3)
end)

case("カーノ: 내 턴에 에나가 늘 때마다 ＋3000", "WX03-032", function(t)
  wd(t, "WX01-019")
  local h, x = t:put(N[32], 0, "signi_left"), t:put(BIG, 1, "signi_left")
  local a = t:put(t:no("WX01-098"), 0, "hand")
  ena(t, 3, GS)
  main(t)
  use(t, a)
  pay(t, 1)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:power(h) == 12000, "芽生 2장으로 ＋3000 두 번")
end)

case("カーノ: 파워가 15000을 넘는 순간 트리거", "WX03-032", function(t)
  wd(t, "WX01-019")
  local h, x = t:put(N[32], 0, "signi_left"), t:put(BIG, 1, "signi_left")
  local a = t:put(t:no("WX01-024"), 0, "lrig_deck")
  t:single(h, EFFECT_UPDATE_POWER, 4000, 0)
  main(t)
  use(t, a)
  pick(t, HINT_TARGET, h)
  pick(t, HINT_TARGET, x)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(h, 0, "ena") and t:is_in(x, 1, "ena"))
end)

case("コスタリク·クリスカル: 트래시에서 나왔을 때만", "WX03-034, WX03-048", function(t)
  wd(t, 1)
  local c, k, x = t:put(N[34], 0, "trash"), t:put(N[48], 0, "trash"), t:put(BIG, 1, "signi_left")
  local a1, a2 = t:put(N[14], 0, "lrig_deck"), t:put(N[14], 0, "lrig_deck")
  ena(t, 2)
  main(t)
  use(t, a1)  -- デッド・スプラッシュ: 상대 센터가 백이라 《黒》 1
  pay(t, 1)
  pick(t, HINT_TARGET, c)
  zone(t)
  pick(t, HINT_TARGET, x)
  t:expect(t:wait(HINT_MAIN))
  use(t, a2)
  pay(t, 1)
  pick(t, HINT_TARGET, k)
  zone(t)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:power(x) == 10000 and t:power(k) == 5000)
  wd(t, 1)
  c, k, x = t:put(N[34], 0, "hand"), t:put(N[48], 0, "hand"), t:put(BIG, 1, "signi_left")
  main(t)
  play(t, c)
  pick(t, HINT_TARGET, x)
  t:expect(t:wait(HINT_MAIN))
  play(t, k, "signi_center")
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:power(x) == 15000 and t:power(k) == 2000, "패에서")
end)

case("セルフ・スラッシュ: 상대가 자기 시그니를 고른다", "WX03-049 FAQ 1", function(t)
  wd(t, 1)
  local sp, x, y = t:put(N[49], 0, "hand"), t:put(BIG, 1, "signi_left"), t:put(OPP, 1, "signi_center")
  ena(t, 2)
  main(t)
  use(t, sp)
  pay(t, 2)
  t:expect(t:wait(HINT_TARGET))
  t:expect(t:request().player == 1 and t:answer(y))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(y, 1, "ena") and t:is_in(x, 1, "signi_left"))
end)

case("打突: ＋5000 해서 15000 이상이면 【ランサー】", "WX03-046 FAQ 1", function(t)
  for _, c in ipairs{{MID, true}, {OPP, false}} do
    wd(t, "WX01-019")
    local sp, x = t:put(N[46], 0, "hand"), t:put(c[1], 0, "signi_left")
    ena(t, 1, GS)
    main(t)
    use(t, sp)
    pay(t, 1)
    pick(t, HINT_TARGET, x)
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:keyword(x, EFFECT_LANCER) == c[2])
  end
end)

case("ICE BREAK: 동결된 시그니만(업 상태여도)", "WX03-043 FAQ 1", function(t)
  wd(t, "WX01-016")
  local sp, x, y = t:put(N[43], 0, "hand"), t:put(BIG, 1, "signi_left"), t:put(OPP, 1, "signi_center")
  t:set_flags(x, CF_FROZEN)
  ena(t, 1, US)
  main(t)
  use(t, sp)
  pay(t, 1)
  t:expect(t:wait(HINT_TARGET))
  t:expect(#t:request().options == 1 and t:answer(x))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(x, 1, "ena"))
end)

case("アークホールド 등: 다른 같은 종족 ＋2000, 자신은 아니다", "WX03-037·039·041·044", function(t)
  wd(t, "WX01-001")
  local h, a = t:put(N[37], 0, "signi_left"), t:put(ANG, 0, "signi_center")
  t:expect(t:power(h) == 7000 and t:power(a) == 4000)
end)

case("ザンテツ·コランダム: 그 색 시그니 ＋2000, 있으면 기본 5000", "WX03-038, WX03-040", function(t)
  wd(t, "WX01-001")
  local h = t:put(N[38], 0, "signi_left")
  t:expect(t:power(h) == 2000)
  local r = t:put(RS, 0, "signi_center")
  t:expect(t:power(h) == 5000 and t:power(r) == 3000)
end)
