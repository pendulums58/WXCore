-- WX19-075 似之遊　†パイガオ†
-- 【出】：あなたの他のシグニ１体を場からトラッシュに置く。そうした場合、あなたのデッキの一番上のカードをエナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,e:GetHandler())
    if g:GetCount()==0 or Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_EFFECT)==0 then return end
    Duel.EnaCharge(tp,1)
  end)
  c:RegisterEffect(e1)
end
