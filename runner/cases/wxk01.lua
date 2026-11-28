-- WXK01 카드 스크립트 케이스. 근거는 카드별 FAQ(cards.json)

local WS, OPP, MID, LV4, LV0 = 200000, 101000, 101500, 300100, 300101
local GREEN, BLACK, BLUE = 202000, 202003, 202002

local function base(t, opts)
  opts = opts or {}
  t:start{db = true, seed = 1}
  t:signi(WS, 1000, COLOR_WHITE, 1)
  t:signi(OPP, 3000, COLOR_RED, 1)
  t:signi(MID, 9000, COLOR_RED, 3)
  t:signi(GREEN, 1000, COLOR_GREEN, 1)
  t:signi(BLACK, 1000, COLOR_BLACK, 1)
  t:signi(BLUE, 1000, COLOR_BLUE, 1)
  t:lrig(LV4, 4, 11, opts.types or {"タマ"}, opts.color or COLOR_WHITE)
  t:lrig(LV0, 0, 0, {"タマ"}, COLOR_WHITE)
  t:fill(WS, 0, "main_deck", 15)
  t:fill(OPP, 1, "main_deck", 15)
  t:fill(WS, 0, "life_cloth", 5)
  t:fill(OPP, 1, "life_cloth", 5)
  if opts.setup then opts.setup() end
  t:put(opts.opp or LV4, 1, "lrig_center")
  return t:put(opts.center or LV4, 0, "lrig_center")
end

local function main(t, p)
  t:begin(p or 0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
end

local function use(t, c) t:expect(t:answer(t:action(ACT_USE, c))) end

-- 그 힌트가 올 때까지 다른 요청은 첫 선택지로(메인·어택 창은 넘긴다)
local function until_hint(t, ...)
  local want = {...}
  t:step()
  for _ = 1, 80 do
    local r = t:request()
    if not r then return false end
    for _, h in ipairs(want) do if r.hint == h then return true end end
    local pass = (r.hint == HINT_MAIN or r.hint == HINT_PRE_ATTACK or r.hint == HINT_DEFENSE) and t:action(ACT_END)
    if pass then t:expect(t:answer(pass)) else t:expect(t:answer(table.unpack(r.options, 1, math.max(r.min, 1)))) end
    t:step()
  end
  return false
end

case("応援の駄姫　グズ子: ダイレクト로 루리그 어택 대미지를 3번 준다", "WXK01-004 FAQ 2", function(t)
  local lc = base(t, {center = t:no("WXK01-004")})
  t:add_coin(0, 2)
  main(t)
  t:expect(t:answer(t:action(ACT_ABILITY, lc, 1)))
  t:expect(until_hint(t, HINT_MAIN))
  t:expect(t:answer(t:action(ACT_END)))
  t:expect(until_hint(t, HINT_ATTACK_LRIG))
  t:expect(t:answer(lc))
  t:expect(until_hint(t, HINT_MAIN, HINT_ATTACK_LRIG, HINT_GROW, HINT_ENA_CHARGE) or true)
  t:expect(t:count(1, "life_cloth") == 2, "3장 크래시 " .. t:count(1, "life_cloth"))
end)

case("アロス・ピルルク　ＴＥＴＲＡ: カタルシス 뒤 다음 드로 페이즈는 4장", "WXK01-002 FAQ 5", function(t)
  local lc = base(t, {center = t:no("WXK01-002")})
  t:add_coin(0, 1)
  main(t)
  t:expect(t:answer(t:action(ACT_ABILITY, lc)))
  t:expect(until_hint(t, HINT_MAIN))
  local h = t:count(0, "hand")
  -- 상대 턴을 넘겨 내 다음 에나 페이즈까지
  t:expect(t:answer(t:action(ACT_END)))
  t:step()
  for _ = 1, 80 do
    local r = t:request()
    if r.hint == HINT_ENA_CHARGE and r.player == 0 then break end
    local pass = (r.hint == HINT_MAIN or r.hint == HINT_PRE_ATTACK or r.hint == HINT_DEFENSE) and t:action(ACT_END)
    if pass then t:expect(t:answer(pass)) else t:expect(t:answer(table.unpack(r.options, 1, r.min))) end
    t:step()
  end
  t:expect(t:count(0, "hand") == h + 4, "4장 " .. (t:count(0, "hand") - h))
end)

case("アロス・ピルルク　ＴＥＴＲＡ: 손패 0장이면 상대 루리그 대미지를 1번만 막는다", "WXK01-002 FAQ 1", function(t)
  local lc = base(t, {center = t:no("WXK01-002")})
  t:begin(1, PHASE_UP)
  t:expect(until_hint(t, HINT_ATTACK_LRIG))
  t:expect(t:answer(t:center(1)))
  t:expect(until_hint(t, HINT_MAIN, HINT_GROW, HINT_ENA_CHARGE, HINT_ATTACK_LRIG) or true)
  t:expect(t:count(0, "life_cloth") == 5, "막았다 " .. t:count(0, "life_cloth"))
end)

case("幻怪姫　イバラヒメ: 《棘々迷路》를 루리그 덱에 더하고, 쓰면 게임에서 제외", "WXK01-042 FAQ 2", function(t)
  base(t, {types = {"緑子"}, color = COLOR_GREEN})
  local x = t:put(t:no("WXK01-042"), 0, "hand")
  local s = t:put(MID, 0, "signi_left")
  main(t)
  local n = t:count(0, "lrig_deck")
  t:expect(t:answer(t:action(ACT_PLAY, x, "signi_center")))
  t:expect(until_hint(t, HINT_MAIN))
  t:expect(t:count(0, "lrig_deck") == n + 1, "크래프트가 루리그 덱에")
  local craft = nil
  for _, c in ipairs(t:cards(0, "lrig_deck")) do if t:cid(c) == t:no("WXK01-TK-01A") then craft = c end end
  t:expect(t:action(ACT_USE, craft) == nil, "사용 타이밍은 어택 페이즈")
  t:expect(t:answer(t:action(ACT_END)))
  t:expect(t:wait(HINT_PRE_ATTACK))
  use(t, craft)
  t:expect(until_hint(t, HINT_TARGET))
  t:expect(t:answer(s))
  t:step()
  t:expect(t:is_in(craft, 0, "exclude"), "루리그 트래시 대신 제외 " .. tostring(t:at(craft)))
  t:expect(t:power(s) == 11000)
end)

case("強奪の箱舟: 모든 ＜乗機＞ 시그니에 탄다", "WXK01-038 FAQ 1", function(t)
  base(t, {types = {"レイラ"}, color = COLOR_RED})
  local sp = t:put(t:no("WXK01-038"), 0, "hand")
  local a = t:put(t:no("WXK01-050"), 0, "signi_left")
  local b = t:put(t:no("WXK01-079"), 0, "signi_center")
  for _ = 1, 3 do t:put(OPP, 0, "ena") end
  main(t)
  use(t, sp)
  t:expect(until_hint(t, HINT_MAIN))
  t:expect(t:drive(a) and t:drive(b), "둘 다 ドライブ状態")
end)

case("超罠　ヤミガネ: 이 턴에 장에 나온 상대 시그니만 대상", "WXK01-045", function(t)
  base(t, {types = {"グズ子"}, color = COLOR_BLACK})
  local y = t:put(t:no("WXK01-045"), 0, "signi_center")
  local old = t:put(MID, 1, "signi_center")
  t:put(BLACK, 0, "ena")
  main(t)
  t:expect(t:answer(t:action(ACT_END)))
  t:expect(until_hint(t, HINT_ATTACK_SIGNI))
  t:expect(t:answer(y))
  t:step()
  t:expect(not (t:request() and t:request().hint == HINT_TARGET), "전부터 있던 시그니는 대상이 아니다")
end)
