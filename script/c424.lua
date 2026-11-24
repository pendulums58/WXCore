-- WD15-007 炎志貫徹
-- このターン、あなたのシグニは、その正面のシグニのパワーが12000以上であるかぎり、【アサシン】を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    -- [の間] 「このターン」. 나중에 나온 시그니·나중에 조건을 채운 것도(FAQ 1·2)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_ASSASSIN)
    e1:SetTargetRange(LOCATION_SZONE,0)
    e1:SetTarget(function(e,x)
      local f=x:GetFrontCard()
      return f and f:GetPower()>=12000
    end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e1)
end
