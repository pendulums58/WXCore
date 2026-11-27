-- WX19-048 中盾　ティンベー
-- 【常】：対戦相手のターンの間、カード名に《盾》を含むあなたのシグニは対戦相手のシグニの効果を受けない。
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_IMMUNE)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return aux.NameHas(x,"盾") end)
  e1:SetValue(function(e,sc,sp) return Duel.GetTurnPlayer()~=e:GetHandlerPlayer() and sp~=e:GetHandlerPlayer() and sc:IsSigni() end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e2)
end
