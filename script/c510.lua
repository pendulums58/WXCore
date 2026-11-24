-- WD17-006 孤立無炎
-- ベット―《コインアイコン》《コインアイコン》
-- あなたがベットする場合、このアーツの使用コストは《赤×0》になる。
-- 対戦相手のすべてのシグニをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(2)
  e1:SetBetCost("")
  e1:SetOperation(function(e,tp) Duel.Banish(Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil)) end)
  c:RegisterEffect(e1)
end
