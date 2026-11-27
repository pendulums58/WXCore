-- WX13-085 フィア＝カリ
-- 【自】：対戦相手のシグニ１体がバニッシュされたとき、ターン終了時まで、このシグニのパワーを＋5000する。
-- 【自】：このシグニがアタックしたとき、対戦相手のシグニ１体を対象とし、このシグニのパワーが20000以上の場合、ターン終了時まで、それのパワーを－10000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BANISHED)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg) return eg:GetFirst():GetOwner()~=tp end)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) then aux.AddPower(e,h,5000) end  -- [まで]
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then if e:GetHandler():GetPower()>=20000 then aux.AddPower(e,tc,-10000) end end
  end)
  c:RegisterEffect(e2)
end
