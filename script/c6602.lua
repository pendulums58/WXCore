-- WXK05-060 紅蓮の使い魔　グレモリー
-- 【常】：このシグニが血晶武装状態であるかぎり、あなたのシグニのパワーを＋3000する。
-- 【出】：ターン終了時まで、あなたのすべての＜紅蓮＞と＜古代兵器＞のシグニのパワーを＋2000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return x:IsSigni() end)
  e1:SetCondition(function(e) return e:GetHandler():IsBloodArmed() end)
  e1:SetValue(3000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp,eg)
    for x in Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_GUREN) or x:IsClass(0,RACE_KODAIHEIKI)) end,tp,LOCATION_SZONE,0,nil):Iter() do aux.AddPower(e,x,2000) end
  end)
  c:RegisterEffect(e2)
end
