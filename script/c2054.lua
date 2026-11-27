-- WX04-083 ＰＲＥＣＩＯＵＳ
-- カードを５枚引き、手札を２枚捨てる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    Duel.Draw(tp,5)
    aux.Discard(tp,2)
  end)
  c:RegisterEffect(e1)
end
