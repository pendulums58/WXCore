-- WX13-094 アイン＝ニネトキリ
-- 【自】：対戦相手のシグニ１体がバニッシュされたとき、ターン終了時まで、このシグニのパワーを＋3000する。
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
    if h:IsLocation(LOCATION_SZONE) then aux.AddPower(e,h,3000) end  -- [まで]
  end)
  c:RegisterEffect(e1)
end
