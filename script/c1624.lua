-- WDK07-E12 コードイート　ウジキントキ
-- 【出】《青》《青》：カードを２枚引き、手札からカードを２枚エナゾーンに置く。
-- （【出】能力の：の左側はコストである。コストを支払わず発動しないことを選んでもよい）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{U}{U}")
  e1:SetOperation(function(e,tp)
    Duel.Draw(tp,2)
    local g=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
    local n=math.min(2,g:GetCount())
    if n>0 then Duel.SendToEna(Duel.SelectCards(tp,g,n,n)) end
  end)
  c:RegisterEffect(e1)
end
