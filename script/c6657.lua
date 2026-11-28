-- WXK06-042 コードメイズ　シシジョウ
-- 【自】《ターン１回》：対戦相手のカードがあなたの効果によってデッキに移動したとき、【エナチャージ１】をする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_MOVED_TO_DECK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) if rp~=tp then return false end for x in eg:Iter() do if x:GetOwner()~=tp then return true end end return false end)
  e1:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e1)
end
