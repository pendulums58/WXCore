-- WX08-042 美しき弦奏　コントラ
-- 【常】：あなたが《白》を支払う際、代わりにあなたのエナゾーンからこのシグニをトラッシュに置いてもよい。
-- 【自】：あなたのシグニ１体がエナゾーンから場に出たとき、あなたのデッキの一番上のカードをエナゾーンに置く。（このシグニがエナゾーンから場に出たときも、この能力は発動する）
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 《白》로도 낼 수 있다(내면 트래시에 놓인다)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_ADD_PAY_COLOR)
  e1:SetRange(LOCATION_ENA)
  e1:SetValue(COLOR_WHITE)
  c:RegisterEffect(e1)
  -- 자신이 에나에서 나와도(괄호)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x:GetControler()==tp and x:IsSigni() and x:IsPreviousLocation(LOCATION_ENA) end)
  e2:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e2)
end
