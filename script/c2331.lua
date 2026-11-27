-- WX09-004 スリリング・ドロー
-- 対戦相手のターンの間、このカードの使用コストは《青×3》になる。
-- カードを３枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  aux.SetCostBy(e1,function(e,tp,base) return Duel.GetTurnPlayer()~=tp and "{U}{U}{U}" or base end)
  e1:SetOperation(function(e,tp)
    Duel.Draw(tp,3)
  end)
  c:RegisterEffect(e1)
end
