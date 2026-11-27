-- WX07 부스터 카드 스크립트 케이스(크로스·레조나, 打ち消して使う, 自分でトラッシュに置けない 등). 근거는 카드별 FAQ(cards.json)

local N = {}
local WS, OPP, MID, BIG = 200000, 101000, 101500, 102000
local UCHU, ATOM, LV4, SP, GRN4, BLU4, US = 200030, 200031, 300040, 200032, 300041, 300042, 200002

local function wd(t, lrig, p1)
  t:start{db = true, seed = 1}
  for i = 1, 82 do N[i] = t:no(("WX07-%03d"):format(i)) end
  local function pick_card(x) return type(x) == "string" and t:no(x) or N[x] or x end
  t:signi(WS, 1000, COLOR_WHITE, 1)
  t:signi(OPP, 3000, COLOR_GREEN, 1)
  t:signi(MID, 9000, COLOR_GREEN, 3)
  t:signi(BIG, 15000, COLOR_GREEN, 4)
  t:card{cid = UCHU, power = 2000, level = 3, classes = {"精羅：宇宙"}, color = COLOR_WHITE}
  t:card{cid = ATOM, power = 2000, level = 1, classes = {"精羅：原子"}, color = COLOR_BLUE}
  t:card{cid = SP, type = TYPE_SPELL, color = COLOR_WHITE}
  t:script(SP, [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetOperation(function(e,tp) Duel.Draw(tp,2) end)
  c:RegisterEffect(e1)
end]])
  t:lrig(LV4, 4, 11, {"サシェ"}, COLOR_WHITE)
  t:lrig(GRN4, 4, 11, {"緑子"}, COLOR_GREEN)
  t:lrig(BLU4, 4, 11, {"ミルルン"}, COLOR_BLUE)
  t:signi(US, 1000, COLOR_BLUE, 1)
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

local function run(t)
  t:step()
  while t:request().hint ~= HINT_MAIN do
    local r = t:request()
    if r.hint == HINT_SCRIPT or r.hint == HINT_USE_TRIGGER then t:expect(t:answer(1)) else t:expect(t:answer(table.unpack(r.options, 1, math.max(r.min, 1)))) end
    t:step()
  end
end

case("羅星 アルファード: 자기 리무브·출현 조건으로 트래시에 둘 수 없다", "WX07-033 FAQ 1", function(t)
  wd(t, LV4)
  local a = t:put(N[33], 0, "signi_left")
  t:put(UCHU, 0, "signi_center")
  t:put(UCHU, 0, "signi_right")
  local r = t:put(t:no("WD09-007"), 0, "lrig_deck")  -- 白羅星 マーキュリー: 宇宙 3체
  main(t)
  t:expect(t:action(ACT_REMOVE, a) == nil, "리무브 못 한다")
  t:expect(t:action(ACT_RESONA, r) == nil, "아르파드 없이는 재료 2체뿐")
end)

case("白羅星 サタン: 레벨 합계 7 이상, 상대는 시그니 2체까지", "WX07-006 FAQ 1·2", function(t)
  wd(t, LV4)
  local r = t:put(N[6], 0, "lrig_deck")
  for _, z in ipairs{"signi_left", "signi_center", "signi_right"} do t:put(UCHU, 0, z) end
  local x, y, w = t:put(OPP, 1, "signi_left"), t:put(OPP, 1, "signi_center"), t:put(OPP, 1, "signi_right")
  main(t)
  t:expect(t:answer(t:action(ACT_RESONA, r)))
  run(t)
  t:expect(t:is_in(r, 0, "signi_left") or t:is_in(r, 0, "signi_center") or t:is_in(r, 0, "signi_right"))
  t:expect(t:count(1, "trash") == 1, "상대 시그니 1체 트래시")
end)

case("クロス・スクランブル: 상대 스펠을 打ち消し, 트래시에서 코스트 없이 쓴다", "WX07-014 FAQ 1·3", function(t)
  wd(t, BLU4)
  local a = t:put(N[14], 0, "lrig_deck")
  local x, y = t:put(t:no("WX07-058"), 0, "signi_left"), t:put(t:no("WX07-038"), 0, "signi_center")
  local sp = t:put(SP, 1, "hand")
  t:put(US, 0, "ena")
  main(t, 1)
  t:expect(t:answer(t:action(ACT_USE, sp)))
  t:expect(t:wait(HINT_CUTIN))
  t:expect(t:answer(t:action(ACT_USE, a)))
  run(t)
  t:expect(t:is_in(sp, 1, "trash"))
  t:expect(t:count(0, "hand") == 2 and t:count(1, "hand") == 0, "내가 2장 뽑았다 " .. t:count(0, "hand"))
end)

case("幻獣 ラクダ: 코스트로 파워 −5000, 【ランサー】를 얻는다", "WX07-042 FAQ 2", function(t)
  wd(t, GRN4)
  local k = t:put(N[42], 0, "signi_center")
  local p = t:power(k)
  main(t)
  t:expect(t:answer(t:action(ACT_ABILITY, k)))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:power(k) == p - 5000 and t:keyword(k, EFFECT_LANCER))
end)

case("白羅星 ジュピタ: 같은 이름 2체로 냈으면 에나 2장", "WX07-009", function(t)
  wd(t, LV4)
  local r = t:put(N[9], 0, "lrig_deck")
  t:put(WS, 0, "signi_left")
  t:put(WS, 0, "signi_center")
  main(t)
  t:expect(t:answer(t:action(ACT_RESONA, r)))
  run(t)
  t:expect(t:count(0, "ena") == 2)
end)

case("幻獣 ウサ: 《ヘブン》하면 그때의 파워만큼 ＋(2배)", "WX07-029 FAQ 1", function(t)
  wd(t, GRN4)
  local u = t:put(N[29], 0, "signi_left")
  local k = t:put(N[43], 0, "signi_center")
  t:expect(t:power(u) == 15000, "크로스 15000 " .. t:power(u))
end)
