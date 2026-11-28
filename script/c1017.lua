-- SPK01-12 幻水　ナポフィ（パーティーパックVol.4）
-- 【自】：このシグニがアタックしたとき、あなたのトラッシュからこのターンに手札から捨てた＜水獣＞のシグニ１枚を対象とし、《緑》を支払ってもよい。そうした場合、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  -- 상대 효과로 버려진 것도(FAQ 1). 에나를 거쳐 간 것은 아니다(FAQ 2)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_SUIJU) and x:IsDiscardedThisTurn() end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e) and Duel.CanPayEna(tp,"{G}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{G}"),REASON_COST)
    if tc:IsLocation(LOCATION_TRASH) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e1)
end
