-- WXK03-051 偉智の遊　オシャブ
-- 【起】《ダウン》：【エナチャージ１】をし、このシグニをデッキの一番上に置く。
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCost(aux.SelfDownCost)
  e1:SetOperation(function(e,tp,eg)
    Duel.EnaCharge(tp,1)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) then Duel.SendToDeckPosition(h,1) end
  end)
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e9)
end
