-- WX21-040 測英の懐古　#ヒャクヨウ#
-- 【出】英知＝８：あなたのデッキからレベル４以上の＜英知＞のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
-- 【常】英知＝１１：あなたの＜英知＞のシグニはコストの合計が１以下の対戦相手のアーツの効果を受けない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCondition(aux.EichiCon(8))
  e1:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_EICHI)) end)(x) and x:GetLevel()>=4 end,1)
  end)
  c:RegisterEffect(e1)
  -- [の間] 【常】
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EFFECT_IMMUNE)
  e2:SetRange(LOCATION_SZONE)
  e2:SetTargetRange(LOCATION_SZONE,0)
  e2:SetTarget(function(e,x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_EICHI)) end)(x) end)
  e2:SetCondition(aux.EichiCon(11))
  e2:SetValue(function(e,sc,sp) return sp~=e:GetHandlerPlayer() and sc:IsType(TYPE_ARTS) and sc:GetCostTotal()<=1 end)
  c:RegisterEffect(e2)
end
