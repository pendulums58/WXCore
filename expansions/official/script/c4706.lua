-- WXDi-D01-013 翠将　センノリキュウ
-- ライフバースト：【エナチャージ３】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_LIFEBURST)
  e1:SetOperation(function(e,tp) Duel.EnaCharge(tp,3) end)
  c:RegisterEffect(e1)
end
