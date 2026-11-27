-- WX08 부스터 카드 스크립트 케이스(존 잠금, 대신 지불, 게임 중 1번 등). 근거는 카드별 FAQ(cards.json)

local N = {}
local WS, KS, OPP, MID, BIG = 200000, 200004, 101000, 101500, 102000
local BUG, MYU4, PIR4, GRN4, RED4, RS, ELD4, US = 200040, 300050, 300051, 300052, 300053, 200001, 300054, 200002

local function wd(t, lrig, p1)
  t:start{db = true, seed = 1}
  for i = 1, 85 do N[i] = t:no(("WX08-%03d"):format(i)) end
  local function pick_card(x) return type(x) == "string" and t:no(x) or N[x] or x end
  t:signi(WS, 1000, COLOR_WHITE, 1)
  t:signi(KS, 1000, COLOR_BLACK, 1)
  t:signi(OPP, 3000, COLOR_GREEN, 1)
  t:signi(MID, 9000, COLOR_GREEN, 3)
  t:signi(BIG, 15000, COLOR_GREEN, 4)
  t:card{cid = BUG, power = 2000, level = 1, classes = {"精生：凶蟲"}, color = COLOR_BLACK}
  t:lrig(MYU4, 4, 11, {"ミュウ"}, COLOR_BLACK)
  t:lrig(PIR4, 4, 11, {"ピルルク"}, COLOR_BLUE)
  t:lrig(GRN4, 4, 11, {"アン"}, COLOR_GREEN)
  t:lrig(RED4, 4, 11, {"花代"}, COLOR_RED)
  t:signi(RS, 1000, COLOR_RED, 1)
  t:lrig(ELD4, 4, 11, {"エルドラ"}, COLOR_BLUE)
  t:signi(US, 1000, COLOR_BLUE, 1)
  lrig, p1 = pick_card(lrig or MYU4), pick_card(p1 or MYU4)
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

local function run(t)
  t:step()
  while t:request().hint ~= HINT_MAIN do
    local r = t:request()
    if r.hint == HINT_SCRIPT or r.hint == HINT_USE_TRIGGER then t:expect(t:answer(1)) else t:expect(t:answer(table.unpack(r.options, 1, math.max(r.min, 1)))) end
    t:step()
  end
end

case("ワーム・ホール: 바니시한 시그니가 있던 존에 상대는 새로 배치할 수 없다", "WX08-032", function(t)
  wd(t, MYU4)
  local sp = t:put(N[32], 0, "hand")
  local x = t:put(MID, 1, "signi_center")
  t:put(BUG, 0, "signi_left")
  for _ = 1, 8 do t:put(KS, 0, "ena") end
  local h = t:put(OPP, 1, "hand")
  main(t)
  t:expect(t:answer(t:action(ACT_USE, sp)))
  run(t)
  t:expect(t:is_in(x, 1, "ena"))
  t:expect(t:answer(t:action(ACT_END)))
  t:expect(t:wait(HINT_MAIN) and t:turn_player() == 1)
  t:expect(t:action(ACT_PLAY, h, "signi_center") == nil and t:action(ACT_PLAY, h, "signi_left") ~= nil)
end)

case("ハンマー・チャンス: 라이프 0장일 때만, 이 게임 동안 한 번", "WX08-015", function(t)
  wd(t, ELD4)
  for _, c in ipairs(t:cards(0, "life_cloth")) do t:move(c, 0, "exclude") end
  local a = t:put(N[15], 0, "lrig_deck")
  for _ = 1, 2 do t:put(US, 0, "ena") end
  main(t)
  t:expect(t:answer(t:action(ACT_USE, a)))
  run(t)
  t:expect(t:count(0, "life_cloth") == 2)
  for _, c in ipairs(t:cards(0, "life_cloth")) do t:move(c, 0, "exclude") end
  t:move(a, 0, "lrig_deck")
  t:expect(t:answer(t:action(ACT_END)))
  t:expect(t:wait(HINT_MAIN) and t:turn_player() == 1)
  t:expect(t:answer(t:action(ACT_END)))
  t:expect(t:wait(HINT_MAIN) and t:turn_player() == 0)
  t:expect(t:action(ACT_USE, a) == nil, "두 번째는 못 쓴다")
end)

case("不灯不屈: 자기 라이프 2장을 크러시(버스트 없음)하고 그만큼 바니시", "WX08-010", function(t)
  wd(t, RED4)
  local a = t:put(N[10], 0, "lrig_deck")
  local x, y = t:put(OPP, 1, "signi_left"), t:put(OPP, 1, "signi_center")
  for _ = 1, 3 do t:put(RS, 0, "ena") end
  main(t)
  t:expect(t:answer(t:action(ACT_USE, a)))
  run(t)
  t:expect(t:count(0, "life_cloth") == 3 and t:is_in(x, 1, "ena") and t:is_in(y, 1, "ena") and not t:saw(HINT_LIFEBURST))
end)

case("美しき弦奏 コントラ: 에나의 이 카드로 《白》를 낼 수 있다", "WX08-042", function(t)
  wd(t, GRN4)
  t:put(N[42], 0, "ena")
  local sp = t:put(t:no("WX01-063"), 0, "hand")  -- 《白》 스펠
  main(t)
  t:expect(t:action(ACT_USE, sp) ~= nil, "녹색 コントラ로 《白》")
end)

case("コードアート M・M: 상대 시그니가 동결되면 상대는 패 1장 버린다(턴 1회)", "WX08-039", function(t)
  wd(t, PIR4)
  t:put(N[39], 0, "signi_center")
  local x, y = t:put(OPP, 1, "signi_left"), t:put(OPP, 1, "signi_center")
  t:put(OPP, 1, "hand")
  t:put(OPP, 1, "hand")
  local sp = t:put(N[13], 0, "lrig_deck")  -- ロブ・ムーブ는 크로스가 필요하다
  local b = t:put(N[66], 0, "hand")  -- BEAUTIFUL: 2체 동결
  for _ = 1, 4 do t:put(t:no("WX01-100"), 0, "ena") end
  main(t)
  t:expect(t:answer(t:action(ACT_USE, b)))
  run(t)
  t:expect(t:count(1, "hand") == 1, "턴 1회 " .. t:count(1, "hand"))
end)
