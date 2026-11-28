-- WXK01-053 魔海の船員　アンボニー
-- 【常】：あなたの＜悪魔＞のシグニのパワーを＋1000する。
-- 【常】：あなたの手札が０枚であるかぎり、あなたの＜悪魔＞のシグニのパワーを＋2000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_AKUMA) end)(x) end)
  e1:SetValue(1000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  -- [の間] 【常】
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EFFECT_UPDATE_POWER)
  e2:SetRange(LOCATION_SZONE)
  e2:SetTargetRange(LOCATION_SZONE,0)
  e2:SetTarget(function(e,x) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_AKUMA) end)(x) end)
  e2:SetCondition(function(e) local tp=e:GetHandlerPlayer() return Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()==0 end)
  e2:SetValue(2000)
  c:RegisterEffect(e2)
end
