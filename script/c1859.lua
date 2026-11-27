-- WX01-050 大化
-- ターン終了時まで、あなたのすべてのシグニのパワーを＋5000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- [まで] 처리할 때 장에 있는 시그니만(FAQ 1)
  e1:SetOperation(function(e,tp)
    for tc in Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):Iter() do aux.AddPower(e,tc,5000) end
  end)
  c:RegisterEffect(e1)
end
