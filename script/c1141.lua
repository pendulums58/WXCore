-- WD06-006 クロス・クラッシュ・フラッシュ
-- 対戦相手はライフクロスの一番上を公開する。そのカードが【ライフバースト】を持たない場合、それをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
-- 트래시에 놓는 것은 크러시가 아니다. 【ライフバースト】 판정은 그 시점의 능력(FAQ 1)
function s.op(e,tp)
  local tc=Duel.GetLifetopGroup(1-tp,1):GetFirst()
  if not tc then return end
  Duel.RevealCards(tc)
  if not tc:IsLifeBurst() then Duel.SendToTrash(tc,REASON_EFFECT) end
end
