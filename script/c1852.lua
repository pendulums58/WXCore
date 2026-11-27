-- WX01-042 断罪の轢断
-- 対戦相手のライフクロス１枚をクラッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    Duel.Crush(1-tp,1)
  end)
  c:RegisterEffect(e1)
end
