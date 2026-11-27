-- WX01-008 流星の巫女　タマヨリヒメ
-- 【常】：あなたの白のシグニのパワーを＋1000する。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_LRIG)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return x:IsSigni() and x:IsColor(COLOR_WHITE) end)
  e1:SetValue(1000)
  c:RegisterEffect(e1)
end
