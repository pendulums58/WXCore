-- WDK05-R17 国英の変動　エンダカ
-- 【出】：カードを１枚引き、手札からカード１枚をデッキの一番下に置く。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
    local g=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
    local n=math.min(1,g:GetCount())
    if n>0 then Duel.SendToDeckBottom(Duel.SelectOrder(tp,Duel.SelectCards(tp,g,n,n)),false) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e2)
end
