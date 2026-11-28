-- WXK08-051 爆書　ダリチュー
-- 【出】あなたのシグニの下からカード１枚をトラッシュに置く：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=(function() local g=Group.CreateGroup() for x in Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):Iter() do for y in x:GetUnderGroup():Iter() do g:AddCard(y) end end return g end)()
    if chk==0 then return g:GetCount()>=1 end
    Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_COST)
  end)
  e1:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e1)
end
