-- WX02-006 ブラック・デザイア
-- あなたのトラッシュにカードが２５枚以上ある場合、すべてのシグニをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 처리할 때 센다. 코스트로 놓인 카드도(FAQ 2). 내 시그니도(FAQ 1)
  e1:SetOperation(function(e,tp)
    if Duel.GetMatchingGroup(nil,tp,LOCATION_TRASH,0,nil):GetCount()<25 then return end
    local g=Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
    if g:GetCount()>0 then Duel.Banish(g) end
  end)
  c:RegisterEffect(e1)
end
