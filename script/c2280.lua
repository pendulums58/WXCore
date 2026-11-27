-- WX08-034 羅星　ディアデム
-- 【自】：このシグニがアタックしたとき、対戦相手のシグニ１体を対象とし、あなたの場に《羅星　アルシャ》と《羅星　コロカロ》がある場合、それをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then if Duel.GetMatchingGroup(function(x) return x:IsCardName(2297) end,tp,LOCATION_SZONE,0,nil):GetCount()>0 and Duel.GetMatchingGroup(function(x) return x:IsCardName(2295) end,tp,LOCATION_SZONE,0,nil):GetCount()>0 then Duel.SendToTrash(tc,REASON_EFFECT) end end
  end)
  c:RegisterEffect(e1)
end
