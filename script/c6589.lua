-- WXK05-047 ムゲン
-- 【常】：あなたの場にキーが２枚以上ないかぎり、このシグニはアタックできない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】 (키가 2장일 일이 없어 항상 어택할 수 없다: 키 존이 하나)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_CANNOT_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),LOCATION_KEY,0,nil):GetCount()<2 end)
  c:RegisterEffect(e1)
end
