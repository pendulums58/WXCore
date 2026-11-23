-- WD06-007 サプライズ・ウィズ・ミー
-- あなたのライフクロスの上からカードを４枚まで見て、それらを好きな順番でデッキの一番上に戻す。
-- 아카이브 텍스트는 「デッキ」지만 FAQ 2(「戻しただけで、ライフクロスに加えているわけではない」)를 따라 라이프 클로스 위로 돌려놓는다
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
-- 3장 이하여도 쓸 수 있다(FAQ 1). 볼 장수를 정한다
function s.op(e,tp)
  local max=math.min(4,Duel.GetLifetopGroup(tp,4):GetCount())
  if max==0 then return end
  local g=Duel.GetLifetopGroup(tp,Duel.AnnounceNumber(tp,1,max))
  Duel.ConfirmCards(tp,g)
  aux.ToLifeTopInOrder(tp,g)
end
