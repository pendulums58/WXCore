-- WD12-018 贈呈
-- あなたのエナゾーンからシグニ１枚を対象とし、それを手札に加える。その後、あなたの場にレゾナがある場合、追加であなたのエナゾーンからシグニを１枚まで対象とし、それを手札に加える。
-- ライフバースト：あなたのデッキの一番上のカードをエナゾーンに置く。その後、あなたのエナゾーンからシグニを１枚まで対象とし、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_ENA,0,1,1,nil)
  end)
  -- 「その後」의 대상은 처리 중에 고른다
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
    if Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_RESONA) end,tp,LOCATION_SZONE,0,nil):GetCount()>0 then s.more(tp) end
  end)
  c:RegisterEffect(e1)
  -- 방금 에나에 놓은 카드도 된다(FAQ 1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    Duel.EnaCharge(tp,1)
    s.more(tp)
  end)
  c:RegisterEffect(e2)
end
function s.more(tp)
  local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_ENA,0,0,1,nil):GetFirst()
  if tc then Duel.SendToHand(tc) end
end
