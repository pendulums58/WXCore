-- WX10-061 羅石　ファイゲート
-- 【常】：あなたの他のレベル３のシグニのパワーを＋3000する。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return x~=e:GetHandler() and x:IsSigni() and x:GetLevel()==3 end)
  e1:SetValue(3000)
  c:RegisterEffect(e1)
end
