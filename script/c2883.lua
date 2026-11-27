-- WX16-068 根英の平方　＃ルート＃
-- 【自】：このシグニの正面のシグニ１体がバニッシュされたとき、このシグニがアタック中でない場合、このシグニをアップする。
-- 【起】《ダウン》：あなたのシグニ１体を対象とし、ターン終了時まで、それのパワーを＋5000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BANISHED)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg)
    local h,x=e:GetHandler(),eg:GetFirst()
    return x:GetPreviousZone()==Duel.GetFrontZone(h:GetZone()) and not (Duel.GetPhase()==PHASE_ATTACK and h:HasAttacked() and Duel.GetTurnPlayer()==tp)
  end)
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
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,5000) end
  end)  -- [まで] ターン終了時まで
  c:RegisterEffect(e2)
end
