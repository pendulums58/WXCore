-- WX14-022 クライシス・チャンス
-- あなたのトラッシュからシグニ１枚を対象とし、あなたの手札が０枚の場合、それを手札に加える。
-- あなたのエナゾーンにカードがない場合、あなたのデッキの上からカードを２枚エナゾーンに置く。
-- あなたの場にシグニがない場合、あなたの手札からシグニ１枚を場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local hand0=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()==0
    local x=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    if x and hand0 then Duel.SendToHand(x) end
    if Duel.GetMatchingGroup(nil,tp,LOCATION_ENA,0,nil):GetCount()==0 then Duel.EnaCharge(tp,2) end
    if Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):GetCount()==0 then
      local y=Duel.SelectCards(tp,Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_HAND,0,nil),0,1):GetFirst()
      if y then Duel.PutOnField(y,tp) end
    end
  end)
  c:RegisterEffect(e1)
end
