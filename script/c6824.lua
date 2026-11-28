-- WXK08-038 コードＶＬ　家長むぎ
-- 【常】：あなたの登録者数が１００万人を達成しているかぎり、このシグニは対戦相手のルリグの効果を受けない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_IMMUNE)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return Duel.GetSubscribers(e:GetHandlerPlayer())>=100 end)
  e1:SetValue(function(e,sc,sp) return sp~=e:GetHandlerPlayer() and sc:IsType(TYPE_LRIG) end)
  c:RegisterEffect(e1)
end
