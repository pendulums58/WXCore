-- WX06 부스터 카드 스크립트 케이스(공개 장수 +1, 「代わりに」 아츠 등). 근거는 카드별 FAQ(cards.json)

local N = {}
local WS, OPP, MID, BIG = 200000, 101000, 101500, 102000
local ANGEL, BIK, LV4, RED4, AN4, RS = 200020, 200021, 300030, 300031, 300032, 200001

local function wd(t, lrig, p1)
  t:start{db = true, seed = 1}
  for i = 1, 52 do N[i] = t:no(("WX06-%03d"):format(i)) end
  local function pick_card(x) return type(x) == "string" and t:no(x) or N[x] or x end
  t:signi(WS, 1000, COLOR_WHITE, 1)
  t:signi(OPP, 3000, COLOR_GREEN, 1)
  t:signi(MID, 9000, COLOR_GREEN, 3)
  t:signi(BIG, 15000, COLOR_GREEN, 4)
  t:card{cid = ANGEL, power = 2000, level = 1, classes = {"精羅：天使"}, color = COLOR_WHITE}
  t:card{cid = BIK, power = 2000, level = 1, classes = {"精像：美巧"}, color = COLOR_GREEN}
  t:lrig(LV4, 4, 11, {"タウィル"}, COLOR_WHITE)
  t:lrig(RED4, 4, 11, {"花代"}, COLOR_RED)
  t:lrig(AN4, 4, 11, {"アン"}, COLOR_GREEN)
  t:signi(RS, 1000, COLOR_RED, 1)
  lrig, p1 = pick_card(lrig or LV4), pick_card(p1 or LV4)
  t:fill(WS, 0, "main_deck", 15)
  t:fill(OPP, 1, "main_deck", 15)
  t:fill(WS, 0, "life_cloth", 5)
  t:fill(OPP, 1, "life_cloth", 5)
  t:put(p1, 1, "lrig_center")
  return t:put(lrig, 0, "lrig_center")
end

local function main(t, p)
  t:begin(p or 0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
end

local function ena(t, n, cid)
  for _ = 1, n do t:put(cid or WS, 0, "ena") end
end

local function pay(t)
  t:step()
  if t:request().hint == HINT_PAY_ENA then t:expect(t:answer(table.unpack(t:request().options, 1, t:request().min))) end
end

local function life(t, p, n)
  for i, c in ipairs(t:cards(p, "life_cloth")) do if i > n then t:move(c, p, "exclude") end end
end

case("永らえし者 タウィル＝フィーラ: 트래시 천사 7장을 덱 아래에 두면 바니시. 6장이면 아무것도 안 한다", "WX06-001 FAQ 6", function(t)
  for _, n in ipairs{7, 6} do
    local lc = wd(t, 1)
    local x = t:put(MID, 1, "signi_center")
    for _ = 1, n do t:put(ANGEL, 0, "trash") end
    main(t)
    t:expect(t:answer(t:action(ACT_ABILITY, lc)))
    t:step()
    while t:request().hint ~= HINT_MAIN do
      local r = t:request()
      t:expect(t:answer(table.unpack(r.options, 1, math.max(r.min, 1))))
      t:step()
    end
    t:expect(t:is_in(x, 1, n == 7 and "ena" or "signi_center"), "천사 " .. n)
    t:expect(t:count(0, "trash") == (n == 7 and 0 or 6))
  end
end)

case("火福糾縄: 센터가 적이고 라이프 2장 이하면 15000 이하 2체까지", "WX06-003", function(t)
  for _, pinch in ipairs{false, true} do
    wd(t, RED4)
    if pinch then life(t, 0, 2) end
    local a = t:put(N[3], 0, "lrig_deck")
    local x, y = t:put(BIG, 1, "signi_center"), t:put(OPP, 1, "signi_left")
    ena(t, 2, RS)
    main(t)
    t:expect(t:answer(t:action(ACT_USE, a)))
    pay(t)
    t:step()
    while t:request().hint == HINT_TARGET do
      t:expect(#t:request().options == (pinch and 2 or 1), "대상 후보 " .. #t:request().options)
      t:expect(t:answer(table.unpack(t:request().options)))
      t:step()
    end
    t:expect(t:wait(HINT_MAIN))
    t:expect(t:is_in(y, 1, "ena") and t:is_in(x, 1, pinch and "ena" or "signi_center"))
  end
end)

case("反復する独自性 グリッド: 이 턴, 덱 위 N장 공개가 N+1장이 된다(고르면)", "WX06-033 FAQ 1", function(t)
  wd(t, AN4)
  local g = t:put(N[33], 0, "hand")
  local k = t:put(t:no("WX05-068"), 0, "hand")  -- コラ: 2장 공개
  t:put(BIK, 0, "hand")
  for _ = 1, 3 do t:put(BIK, 0, "main_deck") end
  main(t)
  t:expect(t:answer(t:action(ACT_PLAY, g, "signi_left")))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:answer(t:action(ACT_PLAY, k, "signi_center")))
  t:step()
  while t:request().hint ~= HINT_MAIN do
    local r = t:request()
    if r.hint == HINT_SCRIPT or r.hint == HINT_USE_TRIGGER then t:expect(t:answer(1)) else t:expect(t:answer(table.unpack(r.options, 1, math.max(r.min, 1)))) end
    t:step()
  end
  t:expect(t:count(0, "hand") == 3, "美巧 3장(2+1) " .. t:count(0, "hand"))
end)

case("シャボン・サドゥン: 천사를 다운한 1체당 《無》×2 감소, 다운은 코스트", "WX06-024 FAQ 1·3", function(t)
  wd(t, LV4)
  local sp = t:put(N[24], 0, "hand")
  local a, b = t:put(ANGEL, 0, "signi_left"), t:put(ANGEL, 0, "signi_center")
  t:put(t:no("WX05-040"), 0, "signi_right")  -- サクラ: 효과로 다운하면 에나 차지
  local x = t:put(MID, 1, "signi_center")
  ena(t, 1)
  main(t)
  t:expect(t:answer(t:action(ACT_USE, sp)))
  t:expect(t:wait(HINT_SELECT))
  t:expect(t:answer(a, b))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:request().min == 1, "《白》만 남는다")
  t:expect(t:answer(t:request().options[1]))
  t:expect(t:wait(HINT_TARGET) and t:answer(x))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:is_in(x, 1, "trash") and t:count(0, "ena") == 0, "코스트 다운은 サクラ가 반응하지 않는다")
end)

case("大槍 トライデ: 센터가 백이고 중앙이면 기본 10000, 상대 효과로 바니시되지 않는다", "WX06-022 FAQ 1", function(t)
  wd(t, LV4)
  local x = t:put(N[22], 0, "signi_center")
  local y = t:put(N[22], 0, "signi_left")
  t:expect(t:power(x) == 10000 and t:power(y) ~= 10000)
end)

case("ラッキー・スリー: 레벨이 다른 무색이 아닌 시그니 3장", "WX06-025 FAQ 1", function(t)
  wd(t, LV4)
  local sp = t:put(N[25], 0, "hand")
  t:put(MID, 0, "main_deck")
  t:put(BIG, 0, "main_deck")
  ena(t, 3)
  main(t)
  t:expect(t:answer(t:action(ACT_USE, sp)))
  pay(t)
  t:expect(t:wait(HINT_SELECT))
  local o = t:request().options
  t:expect(not t:answer(o[1], o[2]), "2장은 안 된다")
end)
