-- WX17-014 天馬轟空
-- あなたのデッキからカードを２枚まで探して手札に加える。その後、対戦相手はあなたの手札を１枚見ないで選び、あなたはそれを捨てる。その後、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local g=Duel.SelectCards(tp,Duel.GetMatchingGroup(nil,tp,LOCATION_MDECK,0,nil),0,2)
    if g:GetCount()>0 then Duel.SendToHand(g) end
    local h=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
    if h:GetCount()>0 then Duel.SendToTrash(Duel.SelectCards(1-tp,h,1,1),REASON_EFFECT+REASON_DISCARD) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
end
