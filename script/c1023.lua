-- WDK06-R09 メル＝マドラー
-- 【自】：対戦相手のターン終了時、このターンにアタックしたシグニを２体まで対象とし、このキーを場からルリグトラッシュに置いてもよい。そうした場合、それらをバニッシュする。
-- 【出】：【エナチャージ２】
-- 【起】《ターン１回》《アタックフェイズアイコン》《緑×0》：シグニ１体を対象とし、ターン終了時まで、それのパワーを＋2000する。
local s,id=GetID()
function s.initial_effect(c)
  -- 어택하고 있는 시그니로 나온 것은 고를 수 없다(FAQ 2)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TURN_END)
  e1:SetRange(LOCATION_KEY)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()~=tp end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:HasAttacked() end,tp,LOCATION_SZONE,LOCATION_SZONE,0,2,nil)
  end)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if not (h:IsLocation(LOCATION_KEY) and Duel.SelectYesNo(tp)) then return end
    Duel.SendToLrigTrash(h,REASON_EFFECT)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.Banish(g) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(aux.EnaChargeOp(2))
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_KEY)
  e3:SetTiming(TIMING_ATTACK)
  e3:SetCountLimit(1)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,2000) end
  end)  -- [まで] ターン終了時まで
  c:RegisterEffect(e3)
end
