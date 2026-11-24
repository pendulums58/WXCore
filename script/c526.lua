-- WD18-004 メル＝スプモニ
-- 【出】《コインアイコン》：あなたのデッキの一番上のカードをエナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCoinCost(1)
  e1:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e1)
end
