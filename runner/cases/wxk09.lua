-- WXK09 카드 스크립트 케이스. 근거는 카드별 FAQ(cards.json)

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

-- 다음 메인 창(HINT_MAIN) 또는 어택 쪽 창이 올 때까지. 「〜してもよい」는 한다
local function next_window(t)
  t:step()
  for _ = 1, 40 do
    local r = t:request()
    if not r then return nil end
    if r.hint == HINT_MAIN or r.hint == HINT_PRE_ATTACK or r.hint == HINT_ATTACK_SIGNI or r.hint == HINT_ATTACK_LRIG then return r.hint end
    if (r.hint == HINT_SCRIPT or r.hint == HINT_USE_TRIGGER) and #r.options == 2 and r.options[1] == 0 and r.options[2] == 1 then t:expect(t:answer(1))
    else t:expect(t:answer(table.unpack(r.options, 1, math.max(r.min, 1)))) end
    t:step()
  end
end

case("改造素材: 쓴 대상 시그니의 「《改造素材》が使用されたとき」가 발동한다(E・M・B 에나 차지 2)", "WXK09-077", function(t)
  base(t, {types = {"ピルルク"}, color = COLOR_GREEN})
  local k = t:put(6974, 0, "lrig_deck")
  t:put(t:no("WXK09-077"), 0, "signi_center")
  main(t)
  local ena = #t:cards(0, "ena")
  use(t, k)
  t:expect(until_hint(t, HINT_MAIN))
  t:expect(#t:cards(0, "ena") == ena + 2, "에나 +2 " .. (#t:cards(0, "ena") - ena))
  t:expect(t:action(ACT_USE, k) == nil, "이 턴 다시 못 쓴다")
end)
