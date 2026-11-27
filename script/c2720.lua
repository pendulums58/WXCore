-- WX14-060 幻水　ナヨハギ
-- 【常】：対戦相手のターンの間、あなたの手札が６枚以上あるかぎり、このシグニの基本パワーは15000になり、対戦相手の効果を受けない。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePower(c,15000,function(e) local p=e:GetHandlerPlayer() return Duel.GetTurnPlayer()~=p and Duel.GetMatchingGroup(nil,p,LOCATION_HAND,0,nil):GetCount()>=6 end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_IMMUNE)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) local p=e:GetHandlerPlayer() return Duel.GetTurnPlayer()~=p and Duel.GetMatchingGroup(nil,p,LOCATION_HAND,0,nil):GetCount()>=6 end)
  e1:SetValue(function(e,sc,sp) return sp~=e:GetHandlerPlayer() end)
  c:RegisterEffect(e1)
end
