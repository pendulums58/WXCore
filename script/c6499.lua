-- WXK04-043 紅蓮の使い魔　エリゴス
-- 【常】：あなたの＜紅蓮＞と＜古代兵器＞のシグニのパワーを＋1000する。
-- 【自】《ターン１回》：あなたのシグニ１体が血晶武装状態になったとき、ターン終了時まで、そのシグニのパワーを＋5000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return x:IsSigni() and (x:IsClass(0,RACE_GUREN) or x:IsClass(0,RACE_KODAIHEIKI)) end)
  e1:SetValue(1000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_BLOOD_ARMED)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetCondition(function(e,tp,eg) return eg:GetFirst():GetControler()==tp end)
  e2:SetOperation(function(e,tp,eg)
    local x=eg:GetFirst()
    if x:IsLocation(LOCATION_SZONE) then aux.AddPower(e,x,5000) end
  end)
  c:RegisterEffect(e2)
end
