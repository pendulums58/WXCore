-- WXK02-053 走英の空力　ダウンフォース
-- 【常】：あなたの＜英知＞のシグニのパワーを＋1000する。
-- 【常】：対戦相手の場に凍結状態のシグニがあるかぎり、あなたの＜英知＞のシグニのパワーを＋2000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_EICHI) end)(x) end)
  e1:SetValue(1000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  -- [の間] 【常】 몇 체든 ＋2000(FAQ 2)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EFFECT_UPDATE_POWER)
  e2:SetRange(LOCATION_SZONE)
  e2:SetTargetRange(LOCATION_SZONE,0)
  e2:SetTarget(function(e,x) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_EICHI) end)(x) end)
  e2:SetCondition(function(e) local tp=e:GetHandlerPlayer() return Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsFrozen() end,tp,0,LOCATION_SZONE,nil):GetCount()>0 end)
  e2:SetValue(2000)
  c:RegisterEffect(e2)
end
