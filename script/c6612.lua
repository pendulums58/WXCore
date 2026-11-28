-- WXK05-070 幻水　コノハケロ
-- 【自】：このカードがあなたの効果によって手札から公開されたとき、対戦相手のパワー10000以上のシグニ１体を対象とし、あなたのターンの場合、《緑》を支払い、手札から《幻水　コノハケロ》を１枚捨ててもよい。そうした場合、それをエナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_REVEALED_FROM_HAND)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return rp==tp and eg:IsContains(e:GetHandler()) end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()>=10000 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    local h=Duel.GetMatchingGroup(function(x) return x:IsCardName(id) end,tp,LOCATION_HAND,0,nil)
    if not (tc and tc:IsRelateToEffect(e) and Duel.GetTurnPlayer()==tp and h:GetCount()>0 and Duel.CanPayEna(tp,"{G}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{G}"),REASON_COST)
    if Duel.SendToTrash(Duel.SelectCards(tp,h,1,1),REASON_EFFECT+REASON_DISCARD)>0 then Duel.SendToEna(tc) end
  end)
  c:RegisterEffect(e1)
end
