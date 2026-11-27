-- WX10-040 レゾナンス
-- あなたのルリグデッキからレゾナ１枚を出現条件を無視して場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local x=Duel.SelectCards(tp,Duel.GetMatchingGroup(function(c) return c:IsType(TYPE_RESONA) end,tp,LOCATION_LDECK,0,nil),0,1):GetFirst()
    if x then Duel.PutOnField(x,tp) end
  end)
  c:RegisterEffect(e1)
end
