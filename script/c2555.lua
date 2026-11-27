-- WX12-029 羅石　アクアマリン
-- 【自】《ターン１回》：あなたのシグニが【起】能力のコストとして場からトラッシュに置かれたとき、あなたのデッキの一番上のカードをエナゾーンに置く。（起動能力にある ： の左側がコスト、右側が効果）
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TO_TRASH)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r) local x=eg:GetFirst() return r&REASON_COST~=0 and x:GetOwner()==tp and x:IsSigni() and x:IsPreviousLocation(LOCATION_SZONE) and re and re:IsAbilityType(ABILITY_IGNITION) end)
  e1:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e2)
end
