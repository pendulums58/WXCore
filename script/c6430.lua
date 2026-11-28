-- WXK03-056 中装　ジョワイ
-- 【常】：このターンにあなたが手札を１枚以上捨てていた場合、このシグニは「【自】：このシグニがアタックしたとき、対戦相手のパワー3000以下のシグニ１体を対象とし、《赤》を支払ってもよい。そうした場合、それをバニッシュする。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  g:SetDescription(aux.Stringid(id,0))
  g:SetCode(EVENT_ATTACK)
  g:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local pw=3000
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=pw end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  g:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e) and Duel.CanPayEna(tp,"{R}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{R}"),REASON_COST)
    Duel.Banish(tc)
  end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】 나오기 전에 버린 것도(FAQ 1)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_GRANT)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return Duel.GetDiscardedCount(e:GetHandlerPlayer())>=1 end)
  e1:SetLabelObject(g)
  c:RegisterEffect(e1)
end
