-- SP27-013 幻怪　ベンザイテン（セレクターズパック vol.19）
-- 【常】：対戦相手は場にあるシグニの【起】能力を使用できない。
-- （効果を受けないシグニの能力も使用できない）
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 효과를 받지 않는 시그니도(카드 주석). 트래시의 것은 쓸 수 있다(FAQ 2)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_DISABLE_ABILITY)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(0,LOCATION_SZONE)
  e1:SetTarget(function(e,x) return x:IsSigni() end)
  e1:SetValue(ABILITY_IGNITION)
  c:RegisterEffect(e1)
end
