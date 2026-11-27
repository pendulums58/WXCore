-- WX08-014 ドント・グロウ
-- このカードは対戦相手のセンタールリグがレベル４以上の場合にしか使用できない。
-- 次のターンの間、対戦相手はグロウできない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCondition(function(e,tp) local lc=Duel.GetMatchingGroup(nil,tp,0,LOCATION_LRIG,nil):GetFirst() return lc and lc:GetLevel()>=4 end)
  e1:SetOperation(function(e,tp)
    -- [の間] 「次のターンの間」
    local now=Duel.GetTurnCount()
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SKIP_GROW)
    e1:SetTargetRange(0,1)
    e1:SetCondition(function() return Duel.GetTurnCount()==now+1 end)
    e1:SetReset(RESET_PHASE+PHASE_END,2)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e1)
end
