-- WX03-029 コードアート　Ｃ・Ｖ・Ｙ
-- 【常】：あなたの場にレベル１の＜電機＞のシグニがあるかぎり、このシグニのパワーは＋2000される。
-- 【常】：あなたの場にレベル３の＜電機＞のシグニがあるかぎり、このシグニのパワーは＋3000される。
-- 【常】：あなたの場にレベル４の＜電機＞のシグニがあるかぎり、このシグニのパワーは＋5000される。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 셋 다 따로
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsClass(0,RACE_DENKI) and x:GetLevel()==1 end,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil):GetCount()>0 end)
  e1:SetValue(2000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EFFECT_UPDATE_POWER)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e) return Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsClass(0,RACE_DENKI) and x:GetLevel()==3 end,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil):GetCount()>0 end)
  e2:SetValue(3000)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EFFECT_UPDATE_POWER)
  e3:SetRange(LOCATION_SZONE)
  e3:SetCondition(function(e) return Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsClass(0,RACE_DENKI) and x:GetLevel()==4 end,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil):GetCount()>0 end)
  e3:SetValue(5000)
  c:RegisterEffect(e3)
end
