-- WX09-005 森羅万象
-- 対戦相手のターンの間、このカードの使用コストは《緑×3》になる。
-- 対戦相手のパワー15000以上のすべてのシグニをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  aux.SetCostBy(e1,function(e,tp,base) return Duel.GetTurnPlayer()~=tp and "{G}{G}{G}" or base end)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:GetPower()>=15000 end,tp,0,LOCATION_SZONE,nil)
    if g:GetCount()>0 then Duel.Banish(g) end
  end)
  c:RegisterEffect(e1)
end
