-- WD19-004 ナナシ　其ノ壱
-- 【出】《コインアイコン》：あなたのデッキの上からカードを２枚トラッシュに置く。その後、あなたのトラッシュから黒のカード１枚を対象とし、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCoinCost(1)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
-- 「その後」의 대상은 2장을 놓은 뒤에 고른다: 방금 놓은 카드도 된다(FAQ 1, 용어집: 対象).
-- 덱이 2장 이하면 있는 만큼 놓고, 리프레시는 처리가 끝난 뒤(FAQ 2)
function s.op(e,tp)
  local g=Duel.GetDecktopGroup(tp,2)
  if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
  local tc=Duel.SelectTarget(tp,function(x) return x:IsColor(COLOR_BLACK) end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
  if tc then Duel.SendToHand(tc) end
end
