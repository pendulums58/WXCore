-- WX10-097 サーバント　Ｑ３
-- 【ガード】（このカードを手札から捨てることで、ルリグのアタックによるダメージを一度防ぐ）
-- 【常】：【マルチエナ】（エナコストを支払う際、このカードは好きな色１つとして支払える）
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_MULTI_ENA)
  e1:SetRange(LOCATION_ENA)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e2)
end
