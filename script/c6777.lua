-- WXK07-079 羅菌　パント
-- 【常】：このシグニに【チャーム】が付いているかぎり、このシグニのパワーは＋5000される。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return e:GetHandler():GetCharm()~=nil end)
  e1:SetValue(5000)
  c:RegisterEffect(e1)
end
