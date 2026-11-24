-- WD15-009 捲火重来
-- このカードは対戦相手のエナゾーンにカードが４枚以上ある場合にしか使用できない。
-- 対戦相手のエナゾーンからカードを２枚まで対象とし、それらをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCondition(function(e,tp) return Duel.GetMatchingGroup(nil,tp,0,LOCATION_ENA,nil):GetCount()>=4 end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,nil,tp,0,LOCATION_ENA,0,2,nil)
  end)
  e1:SetOperation(function(e,tp)
    for tc in Duel.GetTargets():Iter() do
      if tc:IsRelateToEffect(e) then Duel.SendToTrash(tc,REASON_EFFECT) end
    end
  end)
  c:RegisterEffect(e1)
end
