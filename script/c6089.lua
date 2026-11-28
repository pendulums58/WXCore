-- WXEX1-55 コードメイズ　ラビュリン
-- 【自】《ターン１回》：場にあるシグニ１体があなたの効果によって他のシグニゾーンに移動したとき、対戦相手のシグニ１体を対象とし、ターン終了時まで、それは能力を失う。
-- 【自】：このシグニがアタックしたとき、能力を持たない対戦相手のシグニ１体を対象とし、《白》を支払ってもよい。そうした場合、それを手札に戻す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_SIGNI_MOVED)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return rp==tp end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      -- [まで] ターン終了時まで能力を失う
      local e0=Effect.CreateEffect(e:GetHandler())
      e0:SetType(EFFECT_TYPE_SINGLE)
      e0:SetCode(EFFECT_DISABLE_ABILITY)
      e0:SetValue(ABILITY_ALL)
      e0:SetReset(RESET_PHASE+PHASE_END)
      tc:RegisterEffect(e0)
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:HasNoAbility() end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) or not Duel.CanPayEna(tp,"{W}") or not Duel.SelectYesNo(tp) then return end
    local g=Duel.SelectEnaCost(tp,"{W}")
    if g:GetCount()>0 and Duel.SendToTrash(g,REASON_COST)>0 then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e2)
end
