-- WX01-063 ゲット・レディ
-- あなたのすべてのシグニをアップする。
-- ライフバースト：あなたのデッキからシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 동결 상태여도 업한다(FAQ 1)
  e1:SetOperation(function(e,tp)
    for tc in Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):Iter() do Duel.Up(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    aux.SearchToHand(tp,Card.IsSigni,1)
  end)
  c:RegisterEffect(e2)
end
