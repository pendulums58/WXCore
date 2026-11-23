-- WD06-002 エルドラ＝マークⅢ´
-- 【出】：あなたのライフクロスの上からカードを２枚見て、それらを好きな順番で一番上に戻す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
-- 1장뿐이면 보고 그대로 둔다(FAQ 1)
function s.op(e,tp)
  local g=Duel.GetLifetopGroup(tp,2)
  if g:GetCount()==0 then return end
  Duel.ConfirmCards(tp,g)
  aux.ToLifeTopInOrder(tp,g)
end
