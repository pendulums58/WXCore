-- WX18-075 コードイート　サヌウド
-- 【常】：このシグニはあなたのシグニに付いている【アクセ】が合計２枚以上ある場合にしか新たに場に出すことができない。
-- 【常】：【ランサー】
-- （【ランサー】を持つシグニがバトルでシグニをバニッシュしたとき、対戦相手のライフクロスを１枚クラッシュする）
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 둘
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_CANNOT_PLAY)
  e1:SetCondition(function(e) return Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),LOCATION_ACCE,0,nil):GetCount()<2 end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EFFECT_LANCER)
  e2:SetRange(LOCATION_SZONE)
  c:RegisterEffect(e2)
end
