-- WX10-038 極剣　クララス
-- 【常】：あなたの赤のシグニの基本パワーを15000にする。
-- 【常】：あなたの場に赤のシグニがあるかぎり、このシグニの基本パワーは15000になる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 둘
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_SET_BASE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return x:IsSigni() and x:IsColor(COLOR_RED) end)
  e1:SetValue(15000)
  c:RegisterEffect(e1)
  aux.BasePower(c,15000,function(e) return Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsColor(COLOR_RED) end,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil):GetCount()>0 end)
end
