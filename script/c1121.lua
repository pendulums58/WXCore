-- WD03-011 コードアート　Ｓ・Ｍ・Ｐ
-- 【出】：対戦相手の手札を見てレベル１のカード１枚を選び、捨てさせる。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e2)
end
-- 레벨 1 카드가 없으면 보기만 한다(FAQ 4)
function s.op(e,tp)
  local hand=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil)
  Duel.ConfirmCards(tp,hand)
  local g=hand:Filter(function(x) return x:GetLevel()==1 end,nil)
  if g:GetCount()>0 then Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_EFFECT+REASON_DISCARD) end
end
