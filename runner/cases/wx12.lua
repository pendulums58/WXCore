-- WX12 부스터 카드 스크립트 케이스(아래 루리그의 【起】, 【ガード】 상실, 패배하지 않음 등). 근거는 카드별 FAQ(cards.json)

local N = {}
local WS, OPP, MID = 200000, 101000, 101500
local TAWIL4, LTR, ANGEL = 300090, 300091, 200090

local function wd(t, lrig, p1)
  t:start{db = true, seed = 1}
  local function pick_card(x) return type(x) == "string" and t:no(x) or N[x] or x end
  for i = 1, 56 do N[i] = t:no(("WX12-%03d"):format(i)) end
  t:signi(WS, 1000, COLOR_WHITE, 1)
  t:signi(OPP, 3000, COLOR_GREEN, 1)
  t:signi(MID, 9000, COLOR_GREEN, 3)
  t:card{cid = ANGEL, power = 2000, level = 1, classes = {"精羅：天使"}, color = COLOR_WHITE}
  t:script(LTR, [[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetRange(LOCATION_LRIG)
  e1:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e1)
end]])
  t:lrig(LTR, 3, 11, {"タウィル"}, COLOR_WHITE)
  t:lrig(TAWIL4, 4, 11, {"タウィル"}, COLOR_WHITE)
  lrig, p1 = pick_card(lrig or TAWIL4), pick_card(p1 or TAWIL4)
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

case("永らえし者 タウィル＝フェム: 아래 루리그의 【起】를 쓴다", "WX12-001 FAQ 1", function(t)
  local lc = wd(t, 1)
  t:put_under(t:put(LTR, 0, "lrig_trash"), lc)
  main(t)
  t:expect(t:answer(t:action(ACT_ABILITY, lc)))
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:count(0, "hand") == 1)
end)

case("羅星 アルケス: 센터가 ＜サシェ＞가 아니면 패에서 【ガード】를 잃는다", "WX12-025", function(t)
  for _, sashe in ipairs{true, false} do
    wd(t, TAWIL4)
    t:lrig(300092, 4, 11, {"サシェ"}, COLOR_WHITE)
    if sashe then t:move(t:center(0), 0, "exclude") t:put(300092, 0, "lrig_center") end
    local g = t:put(N[25], 0, "hand")
    t:begin(1, PHASE_ATTACK)
    t:expect(t:wait(HINT_ATTACK_LRIG))
    t:expect(t:answer(t:center(1)))
    t:step()
    local asked = t:request().hint == HINT_GUARD
    t:expect(asked == sashe, sashe and "サシェ면 가드할 수 있다" or "아니면 가드 없음")
  end
end)

case("紅蓮乙女 遊月・肆: 라이프 3장 이상으로 상대 어택 페이즈가 시작되면 이 턴 패배하지 않는다", "WX12-002 FAQ 1·2", function(t)
  wd(t, N[2])
  for i, c in ipairs(t:cards(0, "life_cloth")) do if i > 3 then t:move(c, 0, "exclude") end end
  t:begin(1, PHASE_ATTACK)
  t:expect(t:wait(HINT_ATTACK_LRIG))
  for _, c in ipairs(t:cards(0, "life_cloth")) do t:move(c, 0, "exclude") end
  t:expect(t:answer(t:center(1)))
  t:step()
  if t:request().hint == HINT_GUARD then t:expect(t:answer()) t:step() end
  t:expect(not t:ended(), "라이프 0장에서 대미지를 받아도 지지 않는다")
end)
