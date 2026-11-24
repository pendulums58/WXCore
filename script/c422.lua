-- WD02-007 背炎之陣
-- 手札を３枚捨てる。そうした場合、すべてのシグニをバニッシュする。（あなたのシグニも含まれる）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
-- 패가 3장 미만이어도 쓸 수는 있지만, 3장을 버릴 수 없으면 아무 일도 일어나지 않는다(FAQ 2)
function s.op(e,tp)
  if Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()<3 then return end
  if aux.Discard(tp,3)<3 then return end
  Duel.Banish(Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,LOCATION_SZONE,nil))
end
