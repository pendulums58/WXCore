-- WX10-054 大剣　ヌアードゥ
-- 【常】：あなたの赤のシグニのパワーを＋2000する。
-- 【常】：あなたの場に赤のシグニがある場合、このシグニの基本パワーは12000になる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 둘
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return x:IsSigni() and x:IsColor(COLOR_RED) end)
  e1:SetValue(2000)
  c:RegisterEffect(e1)
  aux.BasePower(c,12000,function(e) return Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsColor(COLOR_RED) end,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil):GetCount()>0 end)
end
