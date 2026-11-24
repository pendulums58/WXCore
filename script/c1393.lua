-- WD23-037-A 中罠　シューピン
-- 【トラップアイコン】：対戦相手のすべてのシグニを凍結する。
-- （凍結されたシグニは次の自分のアップフェイズにアップしない）
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_TRAP)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    for tc in Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil):Iter() do Duel.Freeze(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e2)
end
