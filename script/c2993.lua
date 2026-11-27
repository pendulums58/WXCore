-- WX18-040 大剣　イナリカギ
-- 【常】：対戦相手はレベル１以下のシグニで【ガード】ができない。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 레벨별로 하나씩
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_CANNOT_GUARD)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(0,1)
  e1:SetValue(0)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetDescription(aux.Ability(id,0))
  e2:SetCode(EFFECT_CANNOT_GUARD)
  e2:SetRange(LOCATION_SZONE)
  e2:SetTargetRange(0,1)
  e2:SetValue(1)
  c:RegisterEffect(e2)
end
