-- WX18-017 三型金娘　緑姫
-- 【出】《緑》《緑》：《コインアイコン》《コインアイコン》《コインアイコン》《コインアイコン》を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{G}{G}")
  e1:SetOperation(function(e,tp)
    Duel.AddCoin(tp,4)
  end)
  c:RegisterEffect(e1)
end
