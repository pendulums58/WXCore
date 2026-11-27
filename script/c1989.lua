-- WX03-040 羅石　コランダム
-- 【常】：あなたの緑のシグニのパワーを＋2000する。
-- 【常】：あなたの場に緑のシグニがあるかぎり、このシグニの基本パワーは5000になる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return x:IsSigni() and x:IsColor(COLOR_GREEN) end)
  e1:SetValue(2000)
  c:RegisterEffect(e1)
  -- [の間] 【常】
  aux.BasePower(c,5000,function(e) return Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsColor(COLOR_GREEN) end,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil):GetCount()>0 end)
end
