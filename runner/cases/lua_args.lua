-- 스크립트의 잘못된 인자는 오류 로그로 끝나고 대전은 이어진다(점검 2026-11-24 #3-2)

local function run(t, code)
  t:allow_logs()
  t:lrig(1, 3, 9, {"タマ"})
  t:signi(100, 1000)
  t:signi(300, 1000)
  t:script(300, ([[
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetRange(LOCATION_SZONE)
  e1:SetOperation(function(e,tp) %s done=1 end)
  c:RegisterEffect(e1)
end]]):format(code))
  t:start()
  t:fill(100, 0, "main_deck", 10)
  t:put(1, 0, "lrig_center")
  local c = t:put(300, 0, "signi_left")
  t:begin(0, PHASE_MAIN)
  t:expect(t:wait(HINT_MAIN))
  t:expect(t:answer(t:action(ACT_ABILITY, c)))
  t:expect(t:wait(HINT_MAIN), code)
end

case("인자: 없는 플레이어·존·선언 범위는 오류", "점검 2026-11-24 #3-2", function(t)
  for _, code in ipairs{"Duel.Draw(7,1)", "Duel.AddCoin(-1,1)", "Duel.PlaceGate(9999)", "Duel.AnnounceNumber(tp,5,1)", "Duel.AnnounceNumber(tp,0,100000000)"} do
    run(t, code)
    t:expect(t:global("done") ~= 1, code)
    t:expect(t:logs() > 0)
  end
end)

case("인자: 음수 장수는 0장", "점검 2026-11-24 #3-2", function(t)
  run(t, "COUNT=Duel.GetDecktopGroup(tp,-1):GetCount()+Duel.GetLifetopGroup(tp,-3):GetCount()")
  t:expect(t:global("COUNT") == 0 and t:global("done") == 1)
end)
