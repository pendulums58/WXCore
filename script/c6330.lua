-- WXK02-054 浮英の揚力　マグナス
-- 【自】：このシグニがバトルによって対戦相手の凍結状態のシグニをバニッシュしたとき、対戦相手のライフクロス１枚をクラッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local front=nil  -- 어택했을 때 정면의 동결 시그니
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp,eg)
    local f=e:GetHandler():GetFrontCard()
    front=f and f:IsFrozen() and f or nil
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  -- 【ランサー】와 별도로 1장(FAQ 1)
  e2:SetDescription(aux.Ability(id,0))
  e2:SetCode(EVENT_BANISHED)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e,tp,eg,ep) return ep~=tp and Duel.GetBanisher()==e:GetHandler() and front~=nil and eg:IsContains(front) end)
  e2:SetOperation(function(e,tp,eg)
    front=nil
    Duel.Crush(1-tp,1)
  end)
  c:RegisterEffect(e2)
end
