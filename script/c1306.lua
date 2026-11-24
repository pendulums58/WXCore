-- WD20-004 ママ♥１　MODE２
-- 【出】《コインアイコン》《コインアイコン》：カードを１枚引き、手札からカードを１枚エナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCoinCost(2)
  e1:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
    local g=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
    if g:GetCount()>0 then Duel.SendToEna(Duel.SelectCards(tp,g,1,1)) end
  end)
  c:RegisterEffect(e1)
end
