-- WD08-016 サーバント　Ｔ
-- 【ガード】(카드 데이터) 【常】：【マルチエナ】
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 에나 존에서만
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_MULTI_ENA)
  e1:SetRange(LOCATION_ENA)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp) Duel.EnaCharge(tp,1) end)
  c:RegisterEffect(e2)
end
