-- WX01-098 芽生
-- あなたのデッキの上からカードを２枚エナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(aux.EnaChargeOp(2))
  c:RegisterEffect(e1)
end
