-- WXK01-047 コードライド　フブキ
-- 【常】：あなたの＜乗機＞のシグニのパワーを＋1000する。
-- 【自】《ターン１回》：あなたのシグニ１体がドライブ状態になったとき、ターン終了時まで、あなたのすべての＜乗機＞のシグニのパワーを＋2000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_JOUKI) end)(x) end)
  e1:SetValue(1000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  -- 여러 체가 한꺼번에여도 1번(FAQ 2)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_DRIVE)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x:IsSigni() and x:GetControler()==tp end)
  e2:SetOperation(function(e,tp,eg)
    for x in Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsClass(0,RACE_JOUKI) end,tp,LOCATION_SZONE,0,nil):Iter() do aux.AddPower(e,x,2000) end  -- [まで] ターン終了時まで
  end)
  c:RegisterEffect(e2)
end
