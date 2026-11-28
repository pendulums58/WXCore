-- WXK03-062 魔海の略奪　ロバーツ
-- 【常】：対戦相手の手札があなたより２枚以上多いかぎり、このシグニのパワーは＋4000され、このシグニは対戦相手のシグニの効果を受けない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) local tp=e:GetHandlerPlayer() return Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil):GetCount()>=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()+2 end)
  e1:SetValue(4000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e2:SetDescription(aux.Ability(id,0))
  e2:SetCode(EFFECT_IMMUNE)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e) local tp=e:GetHandlerPlayer() return Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil):GetCount()>=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()+2 end)
  e2:SetValue(function(e,sc,sp) return sp~=e:GetHandlerPlayer() and sc:IsSigni() end)
  c:RegisterEffect(e2)
end
