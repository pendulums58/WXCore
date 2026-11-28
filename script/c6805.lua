-- WXK08-016 オカルティック・サイン
-- 対戦相手のシグニ１体を対象とし、それをダウンし凍結する。その後、あなたのキー１枚を場からルリグトラッシュに置いてもよい。そうした場合、対戦相手のシグニ１体を対象とし、それをデッキの一番上に置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Down(tc) Duel.Freeze(tc) end
    local kg=Duel.GetMatchingGroup(nil,tp,LOCATION_KEY,0,nil)
    if kg:GetCount()==0 or not Duel.SelectYesNo(tp) then return end
    Duel.SendToLrigTrash(Duel.SelectCards(tp,kg,1,1),REASON_EFFECT)
    local x=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if x then Duel.SendToDeckPosition(x,1) end
  end)
  c:RegisterEffect(e1)
end
