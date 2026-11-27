-- WX18-052 幻獣　モズ
-- 【自】《ターン１回》：あなたのメインフェイズの間、あなたの＜空獣＞か＜地獣＞のシグニ１体が場に出たとき、このシグニをアップする。この能力はこのシグニがダウン状態の場合にしか発動しない。
-- 【起】《ダウン》：あなたのシグニ１体を対象とし、ターン終了時まで、それのパワーを＋4000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return Duel.GetTurnPlayer()==tp and Duel.GetPhase()==PHASE_MAIN and x:GetControler()==tp and x:IsSigni() and (x:IsClass(0,RACE_KUJU) or x:IsClass(0,RACE_CHIJU)) and not e:GetHandler():IsUp() end)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) then Duel.Up(h) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCost(aux.SelfDownCost)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,4000) end
  end)  -- [まで] ターン終了時まで
  c:RegisterEffect(e2)
end
