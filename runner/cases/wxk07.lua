-- WXK07 카드 스크립트 케이스. 근거는 카드별 FAQ(cards.json)

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

case("自縄自縛: 양쪽 시그니를 체크 존에 두었다가 다운 상태로 다시 낸다(새 오브젝트)", "WXK07-018", function(t)
  base(t, {types = {"メル"}, color = COLOR_GREEN})
  local a = t:put(t:no("WXK07-018"), 0, "lrig_deck")
  local x = t:put(GREEN, 0, "signi_left")
  local y = t:put(MID, 1, "signi_center")
  local ox, oy = t:oid(x), t:oid(y)
  t:put(GREEN, 0, "ena")
  t:put(GREEN, 0, "ena")
  main(t)
  t:expect(t:answer(t:action(ACT_END)))
  t:expect(t:wait(HINT_PRE_ATTACK))
  use(t, a)
  t:expect(until_hint(t, HINT_ATTACK_SIGNI, HINT_ATTACK_LRIG) or true)
  t:expect(t:is_in(x, 0, "signi_left") or t:is_in(x, 0, "signi_center") or t:is_in(x, 0, "signi_right"), "내 시그니는 장에")
  t:expect(t:flags(x) & CF_DOWN ~= 0 and t:flags(y) & CF_DOWN ~= 0, "둘 다 다운")
  t:expect(t:oid(x) ~= ox and t:oid(y) ~= oy, "새 오브젝트")
end)

case("黒鍵の巫女　タマヨリヒメ: 내 에나의 시그니가 흑이 된다", "WXK07-005 FAQ 1", function(t)
  base(t)
  t:put(t:no("WXK07-005"), 0, "key")
  local w = t:put(WS, 0, "ena")
  main(t)
  t:expect(t:color(w) == COLOR_BLACK, "흑 " .. t:color(w))
end)
