-- WDK15-002 ナナシ　其ノ参ノ報
-- 【出】《黒》：《コインアイコン》《コインアイコン》を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{B}")
  e1:SetOperation(function(e,tp)
    Duel.AddCoin(tp,2)
  end)
  c:RegisterEffect(e1)
end
