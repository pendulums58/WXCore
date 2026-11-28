-- WXK02-099 処刑の執行　サンソン
-- 【常】：あなたのトラッシュに＜武勇＞のシグニが２枚以上あるかぎり、このシグニのパワーは＋3000される。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) local tp=e:GetHandlerPlayer() return Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsClass(0,RACE_BUYU) end,tp,LOCATION_TRASH,0,nil):GetCount()>=2 end)
  e1:SetValue(3000)
  c:RegisterEffect(e1)
end
