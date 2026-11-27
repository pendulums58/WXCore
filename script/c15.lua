-- WX01-018 アンチ・スペル
-- スペル１つを対象とし、それの効果を打ち消す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    Duel.NegateSpell()
  end)
  c:RegisterEffect(e1)
end
