-- WXK07-048 羅菌　カリム
-- 【自】：対戦相手のターンの間、このシグニがバニッシュされたとき、このシグニに【チャーム】が付いていた場合、【エナチャージ２】をする。
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BANISHED)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()~=tp and e:GetHandler():IsPreviousCharm() end)
  e1:SetOperation(aux.EnaChargeOp(2))
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e9)
end
