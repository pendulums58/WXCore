-- WD05-014 堕落の砲女　サキュ
-- 【出】：あなたのデッキの上からカードを３枚トラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
-- 3장 미만이면 있는 만큼 놓고, 리프레시는 효과가 끝난 뒤(FAQ 1·2)
function s.op(e,tp)
  local g=Duel.GetDecktopGroup(tp,3)
  if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
end
