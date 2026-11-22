-- WDK09-019 サーバント　Ｄ２
-- 【ガード】(카드 데이터) 【常】：【マルチエナ】
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 에나 존에서만
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_MULTI_ENA)
  e1:SetRange(LOCATION_ENA)
  c:RegisterEffect(e1)
end
