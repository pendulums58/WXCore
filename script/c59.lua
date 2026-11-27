-- WX09-Re04 アイギス・シールド
-- 対戦相手のターンの場合、ターン終了時まで、あなたのすべてのシグニのパワーを＋5000する。（この効果を処理したあとに場に出たシグニは、この効果の影響を受けない）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- [まで] 처리할 때 장에 있는 시그니(괄호)
  e1:SetOperation(function(e,tp)
    if Duel.GetTurnPlayer()==tp then return end
    for tc in Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):Iter() do aux.AddPower(e,tc,5000) end
  end)
  c:RegisterEffect(e1)
end
