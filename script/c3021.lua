-- WX18-071 幻蟲　§イバラカン§
-- 【自】《ターン１回》：あなたのトラッシュから＜凶蟲＞のシグニ１体が場に出たとき、あなたのデッキの一番上のカードをエナゾーンに置く。（このシグニがトラッシュから場に出たときも発動する）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x:GetControler()==tp and (function(x) return x:IsSigni() and (x:IsClass(0,RACE_KYOUCHU)) end)(x) and x:IsPreviousLocation(LOCATION_TRASH) end)
  e1:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e1)
end
