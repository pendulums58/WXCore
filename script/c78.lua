-- WDK-F03-06 モダン・バウンダリー
-- 数字１つを宣言する。その後、あなたのデッキの上からカードを３枚公開する。その中に宣言した数字と同じレベルのシグニがある場合、
-- 対戦相手のシグニ１体を対象とし、それを手札に戻す。この効果で公開したカードを好きな順番でデッキの一番上に戻す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
-- 덱이 3장보다 적으면 있는 만큼 공개한다(FAQ 1)
function s.op(e,tp)
  local n=Duel.AnnounceNumber(tp,0,5)
  local g=Duel.GetDecktopGroup(tp,3)
  if g:GetCount()==0 then return end
  Duel.RevealCards(g)
  local hit=false
  for c in g:Iter() do
    if c:IsSigni() and c:IsLevelBetween(n,n) then hit=true end
  end
  if hit then
    local tg=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
    local tc=tg:GetFirst()
    if tc then Duel.SendToHand(tc) end
  end
  aux.ToDeckTopInOrder(tp,g)
end
