-- WDK04-007 バッド・ボンバー
-- ターン終了時まで、対戦相手のすべてのシグニのパワーを－12000する。
-- （このアーツの後に場に出たシグニはこの効果の影響を受けない）
-- （パワーが０以下のシグニはルールによってバニッシュされる）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- [まで] 처리할 때 장에 있는 시그니만
  e1:SetOperation(function(e,tp)
    for tc in Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil):Iter() do
      aux.AddPower(e,tc,-12000)
    end
  end)
  c:RegisterEffect(e1)
end
