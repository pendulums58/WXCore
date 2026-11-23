-- WD01-014 小弓　ボーニャ
-- 【出】：あなたのデッキの上からカードを３枚見て、それらを好きな順番でデッキの一番上に戻す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
-- 덱이 2장 이하면 그만큼만 본다(FAQ 3)
function s.op(e,tp)
  local g=Duel.GetDecktopGroup(tp,3)
  if g:GetCount()==0 then return end
  Duel.ConfirmCards(tp,g)
  aux.ToDeckTopInOrder(tp,g)
end
