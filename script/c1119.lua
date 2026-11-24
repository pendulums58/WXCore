-- WD03-009 コードアート　Ｒ・Ｍ・Ｎ
-- 【出】《青》：対戦相手の手札を１枚見ないで選び、捨てさせる。
-- ライフバースト：対戦相手は手札を１枚捨てる。
local s,id=GetID()
function s.initial_effect(c)
  -- 코스트가 있는 【出】은 쓰지 않아도 된다(FAQ 3)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{U}")
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
  -- 라이프 버스트는 상대가 골라 버린다(FAQ 5)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp) aux.Discard(1-tp,1) end)
  c:RegisterEffect(e2)
end
-- 「見ないで選び」: 뒷면으로 고른다(FAQ 4)
function s.op(e,tp)
  local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil)
  if g:GetCount()>0 then Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_EFFECT+REASON_DISCARD) end
end
