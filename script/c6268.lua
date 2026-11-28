-- WXK01-088 魔界の村襲い　アオオニ
-- 【常】：あなたの手札が１枚以下であるかぎり、このシグニのパワーは＋3000される。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) local tp=e:GetHandlerPlayer() return Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()<=1 end)
  e1:SetValue(3000)
  c:RegisterEffect(e1)
end
