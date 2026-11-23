-- WD03-015 ＴＯＯ　ＢＡＤ
-- 対戦相手の手札を１枚見ないで選び、捨てさせる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
-- 상대 패가 없어도 쓸 수 있고, 아무것도 일어나지 않는다(FAQ 1). 「見ないで選び」는 뒷면 선택(FAQ 2)
function s.op(e,tp)
  local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil)
  if g:GetCount()>0 then Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_EFFECT+REASON_DISCARD) end
end
