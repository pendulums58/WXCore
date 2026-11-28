-- WXK01-059 幻怪　ダイダラ
-- 【常】：あなたの＜怪異＞のシグニのパワーを＋1000する。
-- 【自】《ターン１回》：あなたがアーツを使用したとき、ターン終了時まで、あなたのすべての＜怪異＞のシグニのパワーを＋2000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_KAII) end)(x) end)
  e1:SetValue(1000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_USE_CARD)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetCondition(function(e,tp,eg,ep) return ep==tp and eg:GetFirst():IsType(TYPE_ARTS) end)
  e2:SetOperation(function(e,tp,eg)
    for x in Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsClass(0,RACE_KAII) end,tp,LOCATION_SZONE,0,nil):Iter() do aux.AddPower(e,x,2000) end  -- [まで] ターン終了時まで
  end)
  c:RegisterEffect(e2)
end
