-- WD20-007 生生流転
-- ベット―《コインアイコン》《コインアイコン》
-- あなたがベットする場合、このアーツの使用コストは《緑×0》になる。
-- あなたのデッキの一番上のカードをライフクロスに加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(2)
  e1:SetBetCost("")  -- 《緑×0》(FAQ 1)
  e1:SetOperation(function(e,tp) Duel.SendToLife(Duel.GetDecktopGroup(tp,1)) end)
  c:RegisterEffect(e1)
end
