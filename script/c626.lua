-- SP38-002 炎天烈術（「ウィクロス 10th Anniversary Book」付録）
-- あなたのライフクロスが対戦相手より多い場合、このアーツの使用コストは《無×3》減る。
-- このターン、あなたのライフクロスが対戦相手より少ないかぎり、あなたのライフクロスはクラッシュされない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  aux.SetCostBy(e1,function(e,tp,base) if Duel.GetMatchingGroup(nil,tp,LOCATION_LIFE,0,nil):GetCount()>Duel.GetMatchingGroup(nil,1-tp,LOCATION_LIFE,0,nil):GetCount() then return Duel.ReduceCost(base,"{C}",3) end return base end)
  e1:SetOperation(function(e,tp)
    -- [の間] 「このターン」 적어진 뒤로는 크래시되지 않는다(FAQ 1). 【ダブルクラッシュ】는 2장을 한꺼번에(FAQ 2)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_CRUSH)
    e1:SetTargetRange(1,0)
    e1:SetCondition(function() return Duel.GetMatchingGroup(nil,tp,LOCATION_LIFE,0,nil):GetCount()<Duel.GetMatchingGroup(nil,1-tp,LOCATION_LIFE,0,nil):GetCount() end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e1)
end
