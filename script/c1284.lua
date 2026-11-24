-- WD16-016 コードアート　Ｇ・Ｌ・Ｋ
-- 【常】：このシグニは、このターンに対戦相手が手札を捨てていた場合にしか新たに場に出すことができない。
-- ライフバースト：対戦相手の手札が５枚以下の場合、対戦相手は手札を１枚捨てる。６枚以上の場合、代わりに２枚捨てる。
local s,id=GetID()
function s.initial_effect(c)
  -- 효과로 낼 때도(FAQ 1). 출현 조건으로 버려도 「捨てた」다(FAQ 2)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_CANNOT_PLAY)
  e1:SetCondition(function(e) return Duel.GetDiscardedCount(1-e:GetHandlerPlayer())==0 end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp) aux.Discard(1-tp,Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil):GetCount()>=6 and 2 or 1) end)
  c:RegisterEffect(e2)
end
