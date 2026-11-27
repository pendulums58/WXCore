-- WX03-030 ＰＩＣＫ　ＵＰ
-- あなたと対戦相手は手札をすべて捨て、これにより捨てられたカードの枚数のうち最も大きい数に等しい枚数のカードを引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 둘 다 뽑는다(FAQ 1)
  e1:SetOperation(function(e,tp)
    local a=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
    local b=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil)
    local na,nb=a:GetCount(),b:GetCount()
    if na>0 then Duel.SendToTrash(a,REASON_EFFECT+REASON_DISCARD) end
    if nb>0 then Duel.SendToTrash(b,REASON_EFFECT+REASON_DISCARD) end
    local n=math.max(na,nb)
    if n==0 then return end
    Duel.Draw(tp,n)
    Duel.Draw(1-tp,n)
  end)
  c:RegisterEffect(e1)
end
