-- WXK08-037 コードＶＬ　竜胆尊
-- 【自】：このシグニがアタックしたとき、対戦相手のレベル１以下のシグニ１体を対象とし、《白》を支払ってもよい。そうした場合、それを手札に戻す。あなたの登録者数が７０万人を達成している場合、追加で【エナチャージ１】をする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=1 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    if not (Duel.CanPayEna(tp,"{W}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{W}"),REASON_COST)
    Duel.SendToHand(tc)
    if Duel.GetSubscribers(tp)>=70 then Duel.EnaCharge(tp,1) end
  end)
  c:RegisterEffect(e1)
end
