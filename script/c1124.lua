-- WD03-014 コードアート　Ｒ・Ｆ・Ｒ
-- 【出】：カードを１枚引き、手札を１枚捨てる。(사이에 다른 행동을 끼울 수 없다. FAQ 4)
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
    aux.Discard(tp,1)
  end)
  c:RegisterEffect(e1)
end
