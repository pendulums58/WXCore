-- PR-205 簒奪の花嫁　アルフォウ（「selector infected WIXOSS-Re/verse- 」第２巻 付録）
-- 【自】：あなたがリフレッシュしたとき、対戦相手のシグニ１体を対象とし、それがこのターンであなたの最初のリフレッシュである場合、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_REFRESH)
  e1:SetRange(LOCATION_LRIG)
  e1:SetCondition(function(e,tp,eg,ep) return ep==tp end)
  -- 어느 턴이든, 상대의 리프레시는 세지 않는다(FAQ 1·2)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then if Duel.GetRefreshCount(tp)==1 then Duel.Banish(tc) end end
  end)
  c:RegisterEffect(e1)
end
