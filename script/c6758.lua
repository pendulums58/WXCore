-- WXK07-060 羅原　Nce
-- 【自】：このシグニがコストか効果によって場からトラッシュに置かれたとき、対戦相手のパワー12000以上のシグニ１体を対象とし、《赤》《赤》を支払ってもよい。そうした場合、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TO_TRASH)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r) return e:GetHandler():IsPreviousLocation(LOCATION_SZONE) and (r&(REASON_EFFECT|REASON_COST))~=0 and (r&REASON_BANISH)==0 end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()>=12000 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    if not (Duel.CanPayEna(tp,"{R}{R}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{R}{R}"),REASON_COST)
    Duel.Banish(tc)
  end)
  c:RegisterEffect(e1)
end
