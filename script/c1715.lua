-- WDK11-012 ＧＦ　クローネ
-- 【出】：対戦相手のシグニ１体を対象とし、あなたの場に《ＧＦ　イザベラ》がある場合、それを手札に戻す。
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
  -- 조건은 처리할 때 본다
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if Duel.GetMatchingGroup(function(x) return x:IsCardName(1714) end,tp,LOCATION_SZONE,0,nil):GetCount()>0 and tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e1)
end
