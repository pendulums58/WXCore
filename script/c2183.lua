-- WX07-012 一致爆結
-- このカードはあなたの場にクロス状態のシグニがある場合にしか使用できない。
-- 対戦相手のパワー10000以下のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCondition(function(e,tp) return Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsCross() end,tp,LOCATION_SZONE,0,nil):GetCount()>0 end)
  e1:SetTarget(aux.BanishPowerTarget(10000))
  e1:SetOperation(aux.BanishOp)
  c:RegisterEffect(e1)
end
