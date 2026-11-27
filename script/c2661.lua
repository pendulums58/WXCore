-- WX13-090 千夜の二夜　シャイターン
-- 【出】：あなたの手札が０枚の場合、あなたのデッキの一番上のカードをエナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    if Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()==0 then Duel.EnaCharge(tp,1) end
  end)
  c:RegisterEffect(e1)
end
