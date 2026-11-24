-- WDK03-015 幻怪　イッタンモメン
-- 【常】：あなたのルリグトラッシュにアーツがあるかぎり、このシグニのパワーは＋5000される。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_ARTS) end,e:GetHandlerPlayer(),LOCATION_LTRASH,0,nil):GetCount()>=1 end)
  e1:SetValue(5000)
  c:RegisterEffect(e1)
end
