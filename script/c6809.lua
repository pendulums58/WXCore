-- WXK08-022 ノンフィクション・コミック
-- 対戦相手のレベル３以下のシグニ１体を対象とし、それをバニッシュする。その後、あなたのキー１枚を場からルリグトラッシュに置いてもよい。そうした場合、あなたのトラッシュからシグニ１枚を対象とし、それを場に出す。それの【出】能力は発動しない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=3 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
    local kg=Duel.GetMatchingGroup(nil,tp,LOCATION_KEY,0,nil)
    if kg:GetCount()==0 or not Duel.SelectYesNo(tp) then return end
    Duel.SendToLrigTrash(Duel.SelectCards(tp,kg,1,1),REASON_EFFECT)
    local x=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    if x then Duel.PutOnField(x,tp,true) end
  end)
  c:RegisterEffect(e1)
end
