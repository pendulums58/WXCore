-- WXK04-056 幻水　オオサンショウ
-- 【自】：このカードがあなたの効果によって手札から公開されたとき、手札から《幻水 オオサンショウ》を１枚捨ててもよい。そうした場合、【エナチャージ２】をする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_REVEALED_FROM_HAND)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return rp==tp and eg:IsContains(e:GetHandler()) end)
  e1:SetOperation(function(e,tp,eg)
    local h=Duel.GetMatchingGroup(function(x) return x:IsCardName(id) end,tp,LOCATION_HAND,0,nil)
    if h:GetCount()==0 or not Duel.CanPayEna(tp,"") or not Duel.SelectYesNo(tp) then return end
    if ""~="" then Duel.SendToTrash(Duel.SelectEnaCost(tp,""),REASON_COST) end
    if Duel.SendToTrash(Duel.SelectCards(tp,h,1,1),REASON_EFFECT+REASON_DISCARD)==0 then return end
    Duel.EnaCharge(tp,2)
  end)
  c:RegisterEffect(e1)
end
