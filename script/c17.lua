-- WD04-007 再三再四
-- あなたのエナゾーンからカードを２枚まで対象とし、それらを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  -- 대상은 코스트를 낸 뒤에 고른다. 코스트로 낸 카드는 트래시에 있어 못 고른다(FAQ 1)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,nil,tp,LOCATION_ENA,0,0,2,nil)
  end)
  e1:SetOperation(function(e,tp)
    for tc in Duel.GetTargets():Iter() do
      if tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
    end
  end)
  c:RegisterEffect(e1)
end
