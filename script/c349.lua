-- PR-K021 讃の遊　シンカリオンＥ６こまち
-- 【自】：各アタックフェイズ開始時、ターン終了時まで、このシグニの基本パワーは正面のシグニのパワーと同じ値になる。
-- 【自】：このシグニがアタックしたとき、このシグニのパワーが8000の場合、【エナチャージ１】する。
-- 【自】：このシグニがアタックしたとき、シグニ１体を対象とし、このシグニのパワーが12000の場合、《白》《白》《無》《無》を支払ってもよい。そうした場合、それを手札に戻す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  -- 정면이 없으면 바뀌지 않는다
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    local f=h:GetFrontCard()
    if not f then return end
    local e1=Effect.CreateEffect(h)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_SET_BASE_POWER)
    e1:SetValue(f:GetPower())
    e1:SetReset(RESET_PHASE+PHASE_END)
    h:RegisterEffect(e1)  -- [まで] ターン終了時まで
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetOperation(function(e,tp)
    if e:GetHandler():GetPower()==8000 then Duel.EnaCharge(tp,1) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_ATTACK)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) or e:GetHandler():GetPower()~=12000 then return end
    if not (Duel.CanPayEna(tp,"{W}{W}{C}{C}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{W}{W}{C}{C}"),REASON_COST)
    Duel.SendToHand(tc)
  end)
  c:RegisterEffect(e3)
end
