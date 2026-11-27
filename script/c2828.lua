-- WX15-118 ブラック・タイアップ
-- ターン終了時まで、対戦相手のすべてのシグニのパワーを－2000する。その後、ターン終了時まで、対戦相手の感染状態のすべてのシグニのパワーを－3000する。
-- （【ウィルス】と同じシグニゾーンにあるシグニは感染状態である）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    -- [まで] 둘 다 처리할 때 장에 있는 시그니(감염이 풀려도 그대로. FAQ 1)
    for tc in Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil):Iter() do aux.AddPower(e,tc,-2000) end
    for tc in Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsInfected() end,tp,0,LOCATION_SZONE,nil):Iter() do aux.AddPower(e,tc,-3000) end
  end)
  c:RegisterEffect(e1)
end
