-- WX20-Re03 ドライ＝ラッカー
-- 【自】《ターン１回》：対戦相手のシグニのパワーが０以下になったとき、あなたのデッキの一番上のカードをエナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  -- 「パワーが０以下になったとき」는 룰 바니시 때로 근사
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BANISHED)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r) return eg:GetFirst():GetOwner()~=tp and r&REASON_RULE~=0 end)
  e1:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e1)
end
