-- WDK16-02H 樋口楓　レベル３
-- 【出】：登録者数を２０万人得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    Duel.AddSubscribers(tp,20)
  end)
  c:RegisterEffect(e1)
end
