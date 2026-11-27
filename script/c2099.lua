-- WX05-037 コードアート　Ｓ・Ｐ・Ｋ
-- 【出】：対戦相手のシグニ１体を対象とし、それを凍結する。その後、対戦相手のすべてのシグニが凍結状態である場合、対戦相手は手札を１枚捨てる。
-- （凍結状態のシグニは、そのシグニのアップフェイズ終了時に凍結状態ではなくなる）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Freeze(tc) end
    local g=Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil)
    if g:GetCount()>0 and g:Filter(Card.IsFrozen,nil):GetCount()==g:GetCount() then aux.Discard(1-tp,1) end
  end)
  c:RegisterEffect(e1)
end
