-- WDK09-017 コードメイズ　マリナカ
-- 【出】：このシグニが中央のシグニゾーンに出ていた場合、対戦相手の手札を見て無色ではないカードを１枚まで選ぶ。
--         カードを１枚選んだ場合、対戦相手はそれをデッキの一番下に置きカードを１枚引く。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCondition(function(e,tp) return e:GetHandler():GetZone()==Duel.GetSigniZones(tp)[2] end)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e2)
end
-- 1장도 고르지 않을 수 있다(FAQ 1). 고르지 않았으면 거기서 끝(FAQ 2)
function s.op(e,tp)
  local hand=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil)
  Duel.ConfirmCards(tp,hand)
  local c=Duel.SelectCards(tp,hand:Filter(function(x) return x:GetColor()~=0 end,nil),0,1):GetFirst()
  if not c then return end
  Duel.SendToDeckBottom(c,false)
  Duel.Draw(1-tp,1)
end
