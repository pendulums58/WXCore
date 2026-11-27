-- WX19-051 コードメイズ　ファルケン
-- 【自】《ターン２回》：シグニ１体が場に出たとき、ターン終了時まで、このシグニのパワーを＋2000する。（このシグニが場に出たときも発動する）
-- 【起】《ターン１回》《メインフェイズアイコン》《アタックフェイズアイコン》《白×0》：対戦相手のシグニ１体を対象とし、ターン終了時まで、それは能力を失い、新たに得られない。この能力はこのシグニのパワーが10000以上の場合にしか使用できない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(2)
  e1:SetCondition(function(e,tp,eg) return eg:GetFirst():IsSigni() end)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) then aux.AddPower(e,h,2000) end  -- [まで]
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetTiming(TIMING_MAIN+TIMING_ATTACK)
  e2:SetCondition(function(e) return e:GetHandler():GetPower()>=10000 end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_LOSE_ABILITY)
    e1:SetReset(RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e1) end
  end)
  c:RegisterEffect(e2)
end
