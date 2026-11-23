-- WD03-008 ドロー・ツー
-- カードを２枚引く。(덱이 1장이면 1장만 뽑고 끝. FAQ 2)
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp) Duel.Draw(tp,2) end)
  c:RegisterEffect(e1)
end
