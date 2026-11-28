-- WXK04-067 羅植　キヌガサ
-- 【自】：対戦相手のターンの間、このシグニがバニッシュされたとき、【エナチャージ１】をする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BANISHED)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()~=tp end)
  e1:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e1)
end
