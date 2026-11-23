-- WD01-018 噴流する知識
-- カードを１枚引く。
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  -- 덱이 1장이면 뽑은 뒤 리프레시(FAQ 1, 룰 처리)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp) Duel.EnaCharge(tp,1) end)
  c:RegisterEffect(e2)
end
