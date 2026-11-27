-- WX02-077 サーバント　Ｔ２
-- 【ガード】（このカードを手札から捨てることで、ルリグのアタックによるダメージを一度防ぐ）
-- 【常】：【マルチエナ】（エナコストを支払う際、このカードは好きな色１つとして支払える）
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 에나 존에서만
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_MULTI_ENA)
  e1:SetRange(LOCATION_ENA)
  c:RegisterEffect(e1)
end
