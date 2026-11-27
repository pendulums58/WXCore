-- WX11 부스터 카드 스크립트 케이스(엑시드 코스트로 놓였을 때, 시그니 존 이동, 리프레시 후 턴 종료 등). 근거는 카드별 FAQ(cards.json)

local N = {}
local WS, OPP, MID = 200000, 101000, 101500
local TAMA4, IONA4, LTR = 300080, 300081, 300082

local function wd(t, lrig, p1)
  t:start{db = true, seed = 1}
  local function pick_card(x) return type(x) == "string" and t:no(x) or N[x] or x end
  for i = 1, 87 do N[i] = t:no(("WX11-%03d"):format(i)) end
  t:signi(WS, 1000, COLOR_WHITE, 1)
  t:signi(OPP, 3000, COLOR_GREEN, 1)
  t:signi(MID, 9000, COLOR_GREEN, 3)
  t:lrig(TAMA4, 4, 11, {"タマ"}, COLOR_WHITE)
  t:lrig(IONA4, 4, 11, {"イオナ"}, COLOR_WHITE)
  t:lrig(LTR, 1, 11, {"タマ"}, COLOR_WHITE)
  lrig, p1 = pick_card(lrig or TAMA4), pick_card(p1 or TAMA4)
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

case("神妙の巫女 タマヨリヒメ: 엑시드 코스트로 루리그 트래시에 놓이면 시그니 1체를 업", "WX11-007 FAQ 1", function(t)
  local lc = wd(t, 1)
  local u = t:put(N[7], 0, "lrig_trash")
  t:put_under(u, lc)
  t:put_under(t:put(LTR, 0, "lrig_trash"), lc)
  local s = t:put(WS, 0, "signi_center")
  t:set_flags(s, 1)  -- 다운
  t:put(OPP, 1, "signi_center")
  main(t)
  t:expect(t:answer(t:action(ACT_ABILITY, lc)))
  t:expect(t:wait(HINT_EXCEED))
  t:expect(t:answer(table.unpack(t:under(lc))))
  run(t)
  t:expect(t:is_in(u, 0, "lrig_trash") and t:flags(s) % 2 == 0, "업했다")
end)

case("純白の巫女 ユキ: 내 효과로 시그니가 다른 존으로 옮겨지면 에나 차지(턴 1회)", "WX11-002 FAQ 1", function(t)
  local lc = wd(t, 2)
  t:put_under(t:put(LTR, 0, "lrig_trash"), lc)
  t:put(OPP, 1, "signi_left")
  t:put(MID, 1, "signi_center")
  main(t)
  t:expect(t:answer(t:action(ACT_ABILITY, lc)))
  run(t)
  t:expect(t:count(0, "ena") <= 1, "여러 번 옮겨도 1장 " .. t:count(0, "ena"))
end)
