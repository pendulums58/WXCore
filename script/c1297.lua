-- WD19-011 羅菌　ショウコカビ
-- 【自】：このシグニがアタックしたとき、対戦相手の感染状態のシグニ１体を対象とし、ターン終了時まで、それのパワーを－4000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsInfected() end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
-- 나중에 감염 상태가 아니게 돼도 턴 끝까지 －4000 그대로(FAQ 1)
function s.op(e,tp)
  local tc=Duel.GetFirstTarget()
  if not (tc and tc:IsRelateToEffect(e)) then return end
  -- [まで] ターン終了時まで
  local e1=Effect.CreateEffect(e:GetHandler())
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetValue(-4000)
  e1:SetReset(RESET_PHASE+PHASE_END)
  tc:RegisterEffect(e1)
end
