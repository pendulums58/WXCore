-- WD11-013 幻蟲　モンチョウ
-- 【出】：対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－1000する。
-- 【自】：このシグニが場を離れたとき、対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－1000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(s.opptg)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-1000) end  -- [まで] ターン終了時まで
  end)
  c:RegisterEffect(e1)
  -- 에나 페이즈에 에나로 보내도 장을 떠난 것이다
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_LEAVE_FIELD)
  e2:SetTarget(s.opptg)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-1000) end  -- [まで] ターン終了時まで
  end)
  c:RegisterEffect(e2)
end
function s.opptg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
end
