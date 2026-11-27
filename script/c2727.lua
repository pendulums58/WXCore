-- WX14-067 一ノ遊　ウキワ
-- 【自】：このシグニがアタックしたとき、あなたの手札からカード１枚をエナゾーンに置いてもよい。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp)
    local x=Duel.SelectCards(tp,Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil),0,1)
    if x:GetCount()>0 then Duel.SendToEna(x) end
  end)
  c:RegisterEffect(e1)
end
