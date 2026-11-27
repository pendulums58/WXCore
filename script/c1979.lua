-- WX03-028 コードアート　Ｒ・Ｇ・Ｎ
-- 【常】：あなたが使用する青のアーツのコストは《無×1》減る。
-- 【常】：あなたのルリグデッキが０枚であるかぎり、このシグニの基本パワーは18000になる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_REDUCE_COST)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(1,0)
  e1:SetTarget(function(e,x) return x:IsType(TYPE_ARTS) and x:IsColor(COLOR_BLUE) end)
  e1:SetEnaCost("{C}")
  e1:SetValue(1)
  c:RegisterEffect(e1)
  -- [の間] 【常】 처리할 때의 장수(FAQ 1)
  aux.BasePower(c,18000,function(e) return Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),LOCATION_LDECK,0,nil):GetCount()==0 end)
end
