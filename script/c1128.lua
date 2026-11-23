-- WD04-006 意気揚々
-- ターン終了時まで、あなたのすべてのシグニのパワーを＋5000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
-- 사용한 때 장에 있는 시그니만. 뒤에 나온 시그니는 오르지 않는다(FAQ 1)
function s.op(e,tp)
  for tc in Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):Iter() do
    aux.AddPower(e,tc,5000)  -- [まで] ターン終了時まで
  end
end
