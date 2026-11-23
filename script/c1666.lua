-- WDK08-Y08 猛威継承
-- あなたのエナゾーンにあるすべてのカードを手札に加える。その後、あなたの手札が５枚より多い場合、その差の分だけ手札からカードをエナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
-- 5장 이하면 끝, 6장 이상이면 5장을 넘는 만큼 골라 에나에(FAQ 1)
function s.op(e,tp)
  Duel.SendToHand(Duel.GetMatchingGroup(nil,tp,LOCATION_ENA,0,nil))
  local hand=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
  local n=hand:GetCount()-5
  if n>0 then Duel.SendToEna(Duel.SelectCards(tp,hand,n,n)) end
end
