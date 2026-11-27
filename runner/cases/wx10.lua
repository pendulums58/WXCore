-- WX10 부스터 카드 스크립트 케이스(색 지정 엑시드, 【チェイン】, グロウできない, 어택 무효 횟수 등). 근거는 카드별 FAQ(cards.json)

local N = {}
local WS, RS, GS, OPP, MID, BIG = 200000, 200001, 200003, 101000, 101500, 102000
local RED4, TAMA4, WL, RL = 300070, 300071, 300072, 300073

local function wd(t, lrig, p1)
  t:start{db = true, seed = 1}
  local function pick_card(x) return type(x) == "string" and t:no(x) or N[x] or x end
  for i = 1, 100 do N[i] = t:no(("WX10-%03d"):format(i)) end
  t:signi(WS, 1000, COLOR_WHITE, 1)
  t:signi(RS, 1000, COLOR_RED, 1)
  t:signi(GS, 1000, COLOR_GREEN, 1)
  t:signi(OPP, 3000, COLOR_GREEN, 1)
  t:signi(MID, 9000, COLOR_GREEN, 3)
  t:signi(BIG, 15000, COLOR_GREEN, 4)
  t:lrig(RED4, 4, 11, {"花代"}, COLOR_RED)
  t:lrig(TAMA4, 4, 11, {"タマ"}, COLOR_WHITE)
  t:lrig(WL, 1, 11, {"タマ"}, COLOR_WHITE)
  t:lrig(RL, 1, 11, {"タマ"}, COLOR_RED)
  lrig, p1 = pick_card(lrig or RED4), pick_card(p1 or RED4)
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

case("炎・タマヨリヒメ・伍: 엑시드 1(백의 카드)은 백색 카드가 아래에 있어야 쓴다", "WX10-001 FAQ 1", function(t)
  for _, white in ipairs{true, false} do
    local lc = wd(t, 1)
    t:put_under(t:put(white and WL or RL, 0, "lrig_trash"), lc)
    t:put(OPP, 1, "signi_center")
    main(t)
    -- 백 엑시드(대상: 패로)는 첫 번째 【起】, 적 엑시드는 두 번째
    local a = t:action(ACT_ABILITY, lc)
    t:expect(a ~= nil, "적 엑시드나 백 엑시드 중 하나는 쓸 수 있다")
    t:expect(t:answer(a))
    t:expect(t:wait(HINT_EXCEED))
    t:expect(t:answer(t:request().options[1]))
    run(t)
    t:expect(t:count(1, "hand") == (white and 1 or 0), white and "백: 패로" or "적: 바니시")
  end
end)

case("チェイン・Ｗキャノン: 다음 아츠의 코스트가 《白》《赤》 준다", "WX10-004 FAQ 1", function(t)
  wd(t, RED4)
  local a, b = t:put(N[4], 0, "lrig_deck"), t:put(N[5], 0, "lrig_deck")
  for _, c in ipairs{WS, WS, RS, RS, GS, WS, WS} do t:put(c, 0, "ena") end
  t:put(OPP, 1, "signi_center")
  main(t)
  t:expect(t:answer(t:action(ACT_USE, a)))
  run(t)
  t:expect(t:count(0, "ena") == 4)
  t:expect(t:answer(t:action(ACT_USE, b)))
  t:expect(t:wait(HINT_PAY_ENA))
  t:expect(t:request().min == 4, "《赤》《赤》《緑》《無》《無》 − 《赤》 = 4 " .. t:request().min)
end)

case("駆馬炎鞭: 이 게임 동안 센터 루리그는 【ダブルクラッシュ】, 그로우할 수 없다", "WX10-011 FAQ 1", function(t)
  local lc = wd(t, RED4)
  local a = t:put(N[11], 0, "lrig_deck")
  t:put(RS, 0, "ena")
  t:put(RS, 0, "ena")
  local g = t:put(t:no("WX05-002"), 0, "lrig_deck")
  main(t)
  t:expect(t:answer(t:action(ACT_USE, a)))
  run(t)
  t:expect(t:keyword(lc, EFFECT_DOUBLE_CRUSH))
  t:expect(t:action(ACT_GROW, g) == nil)
end)

case("暴風警報: 이 턴 상대의 1·2번째 어택을 무효", "WX10-018 FAQ 2", function(t)
  wd(t, RED4)
  local a = t:put(N[18], 0, "lrig_deck")
  for _ = 1, 2 do t:put(GS, 0, "ena") end
  local x, y, z = t:put(MID, 1, "signi_left"), t:put(MID, 1, "signi_center"), t:put(MID, 1, "signi_right")
  t:begin(1, PHASE_ATTACK)
  t:expect(t:wait(HINT_DEFENSE))
  t:expect(t:answer(t:action(ACT_USE, a)))
  for _, c in ipairs{x, y, z} do t:expect(t:wait(HINT_ATTACK_SIGNI) and t:answer(c)) end
  t:expect(t:wait(HINT_ATTACK_LRIG))
  t:expect(t:count(0, "life_cloth") == 4, "3번째만 통했다 " .. t:count(0, "life_cloth"))
end)
