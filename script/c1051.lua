-- WX10-050 コードアンチ　エレチェア
-- 【出】：このシグニがトラッシュから場に出た場合、対戦相手は自分のシグニ１体を対象とし、それをバニッシュする。
-- ライフバースト：対戦相手のレベル２以下のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_TRASH) end)
  e1:SetOperation(function(e,tp)
    -- 상대가 고른다
    local tc=Duel.SelectTarget(1-tp,Card.IsSigni,1-tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
    if tc then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=2 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e2)
end
