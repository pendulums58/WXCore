-- WX01-023 大器晩成
-- 対戦相手のエナゾーンにあるすべてのカードと対戦相手のすべてのシグニをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ENA,nil)
    for x in Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil):Iter() do g:AddCard(x) end
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
end
