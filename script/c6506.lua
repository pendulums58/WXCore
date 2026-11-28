-- WXK04-050 コードイート　ブルジャム
-- 【常】：これにアクセされているシグニは「【常】：このシグニは対戦相手のルリグの効果を受けない。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  -- [の間] 【常】 이것이 붙은 시그니
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_IMMUNE)
  e1:SetRange(LOCATION_ACCE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return x==e:GetHandler():GetAcceHost() end)
  e1:SetValue(function(e,sc,sp) return sp~=e:GetHandlerPlayer() and sc:IsType(TYPE_LRIG) end)
  c:RegisterEffect(e1)
end
