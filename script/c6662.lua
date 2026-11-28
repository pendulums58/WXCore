-- WXK06-047 ＩＮ　ＴＥＭＰＯ
-- カードを２枚引き、手札を１枚捨てる。その後、対戦相手は、自分のシグニ１体を対象とし、それをデッキの一番上に置かないかぎり手札を１枚デッキの一番下に置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,2)
    aux.Discard(tp,1)
    local p=1-tp
    local x=Duel.GetMatchingGroup(Card.IsSigni,p,LOCATION_SZONE,0,nil):GetCount()>0 and Duel.SelectYesNo(p) and Duel.SelectTarget(p,Card.IsSigni,p,LOCATION_SZONE,0,1,1,nil):GetFirst() or nil
    if x then Duel.SendToDeckPosition(x,1) return end
    local h=Duel.GetMatchingGroup(nil,p,LOCATION_HAND,0,nil)
    if h:GetCount()>0 then Duel.SendToDeckBottom(Duel.SelectCards(p,h,1,1),false) end
  end)
  c:RegisterEffect(e1)
end
