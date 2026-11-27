-- WX13-066 羅星　カプスワン
-- 【起】《ダウン》手札から＜宇宙＞のシグニを１枚捨てる：あなたのデッキからレベル２以下の＜宇宙＞のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local h=e:GetHandler()
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_UCHU)) end,tp,LOCATION_HAND,0,nil)
    if chk==0 then return h:IsUp() and g:GetCount()>0 end
    Duel.Down(h,REASON_COST)
    Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_COST+REASON_DISCARD)
  end)
  e1:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_UCHU)) end)(x) and x:GetLevel()<=2 end,1)
  end)
  c:RegisterEffect(e1)
end
