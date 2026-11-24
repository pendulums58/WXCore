-- WDK03-014 幻怪　ティンベル
-- 【常】：あなたがコストの合計が３以上のアーツを使用する場合、それの使用コストは《緑×1》減る。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 카드에 적힌 코스트의 합계로 본다(FAQ 1)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_REDUCE_COST)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(1,0)
  e1:SetTarget(function(e,c) return c:IsType(TYPE_ARTS) and c:GetCostTotal()>=3 end)
  e1:SetEnaCost("{G}")
  e1:SetValue(1)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e2)
end
