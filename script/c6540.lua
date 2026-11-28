-- WXK04-084 幻水　マレガビ
-- 【自】：このカードがあなたの効果によって手札から公開されたとき、《緑》《緑》《無》を支払い、手札から《幻水 マレガビ》を１枚捨ててもよい。その後、この方法で《幻水 マレガビ》を捨てた場合、あなたのトラッシュからレベル３以下の＜水獣＞のシグニ１枚を対象とし、それを場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_REVEALED_FROM_HAND)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return rp==tp and eg:IsContains(e:GetHandler()) end)
  e1:SetOperation(function(e,tp,eg)
    local h=Duel.GetMatchingGroup(function(x) return x:IsCardName(id) end,tp,LOCATION_HAND,0,nil)
    if h:GetCount()==0 or not Duel.CanPayEna(tp,"{G}{G}{C}") or not Duel.SelectYesNo(tp) then return end
    if "{G}{G}{C}"~="" then Duel.SendToTrash(Duel.SelectEnaCost(tp,"{G}{G}{C}"),REASON_COST) end
    if Duel.SendToTrash(Duel.SelectCards(tp,h,1,1),REASON_EFFECT+REASON_DISCARD)==0 then return end
    local tc=Duel.SelectTarget(tp,function(x) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_SUIJU) end)(x) and x:GetLevel()<=3 end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    if tc then Duel.PutOnField(tc,tp) end
  end)
  c:RegisterEffect(e1)
end
