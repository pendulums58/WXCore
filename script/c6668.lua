-- WXK06-053 幻竜　エキドーナ
-- 【自】：各ターン終了時、対戦相手のエナゾーンからカード１枚を対象とし、このシグニを場からトラッシュに置いてもよい。そうした場合、それをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TURN_END)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,nil,tp,0,LOCATION_ENA,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    local h=e:GetHandler()
    if tc and tc:IsRelateToEffect(e) and h:IsLocation(LOCATION_SZONE) and Duel.SelectYesNo(tp) and Duel.SendToTrash(h,REASON_EFFECT)>0 then Duel.SendToTrash(tc,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
end
