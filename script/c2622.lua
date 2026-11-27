-- WX13-051 幻竜　＃モリドラ＃
-- 【自】：あなたの＜龍獣＞のシグニの効果によって対戦相手のシグニ１体がバニッシュされたとき、あなたのデッキの一番上のカードをエナゾーンに置く。
-- 【自】：このシグニが対戦相手の効果によってあなたの手札からトラッシュに置かれたとき、あなたのデッキの上からカードを２枚エナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BANISHED)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r) if r&REASON_EFFECT==0 or eg:GetFirst():GetOwner()==tp or not re then return false end local h=re:GetHandler() return h and h:GetControler()==tp and (function(x) return x:IsSigni() and (x:IsClass(0,RACE_RYUJU)) end)(h) end)
  e1:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_TO_TRASH)
  e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return e:GetHandler():IsPreviousLocation(LOCATION_HAND) and rp~=tp end)
  e2:SetOperation(function(e,tp)
    Duel.EnaCharge(tp,2)
  end)
  c:RegisterEffect(e2)
end
