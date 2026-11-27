-- WX22-029 参ノ遊　ハンスピ
-- 【自】《ターン１回》：このシグニがアタックしたとき、あなたのエナゾーンからシグニ１枚を手札に加える。そうした場合、手札からカードを１枚エナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetCountLimit(1)
  e1:SetOperation(function(e,tp)
    local x=Duel.SelectCards(tp,Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_ENA,0,nil),1,1)
    if x:GetCount()==0 or Duel.SendToHand(x)==0 then return end
    local h=Duel.SelectCards(tp,Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil),1,1)
    if h:GetCount()>0 then Duel.SendToEna(h) end
  end)
  c:RegisterEffect(e1)
end
