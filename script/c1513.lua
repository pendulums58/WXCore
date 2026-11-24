-- WDK02-013 魔界の粘形　アーマードスライム
-- 【常】：あなたの手札が１枚以下であるかぎり、このシグニのパワーは＋4000される。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),LOCATION_HAND,0,nil):GetCount()<=1 end)
  e1:SetValue(4000)
  c:RegisterEffect(e1)
end
