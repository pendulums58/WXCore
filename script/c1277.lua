-- WD16-006 ドント・ステップ
-- このアーツの使用コストはあなたの手札の枚数から対戦相手の手札の枚数を引いた数１につき《青×1》減る。
-- 対戦相手のシグニを２体まで対象とし、それらをダウンする。
local s,id=GetID()
function s.initial_effect(c)
  -- 상대 패가 더 많아도 늘지 않는다(FAQ 2)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  aux.SetCostBy(e1,s.cost)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,0,2,nil)
  end)
  e1:SetOperation(function(e,tp)
    for tc in Duel.GetTargets():Iter() do
      if tc:IsRelateToEffect(e) then Duel.Down(tc) end
    end
  end)
  c:RegisterEffect(e1)
end
function s.cost(e,tp,base)
  local n=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()-Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil):GetCount()
  return Duel.ReduceCost(base,"{U}",n)
end
