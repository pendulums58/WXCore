-- WX14-066 弐ノ遊　ゴムボート
-- 【自】：アタックフェイズの間、このカードがルリグかシグニの効果によって手札かデッキからエナゾーンに置かれたとき、あなたのデッキの一番上のカードをエナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TO_ENA)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r) local h=e:GetHandler() if Duel.GetPhase()~=PHASE_ATTACK or r&REASON_EFFECT==0 or not re then return false end local s=re:GetHandler() return s and (s:IsSigni() or s:IsType(TYPE_LRIG)) and (h:IsPreviousLocation(LOCATION_HAND) or h:IsPreviousLocation(LOCATION_MDECK)) end)
  e1:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e1)
end
