-- SPK25-03 金愛の使者　サシェ・クロワス
-- 【出】手札を1枚捨てる：《コインアイコン》を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(aux.DiscardCost(1))
  e1:SetOperation(function(e,tp) Duel.AddCoin(tp,1) end)
  c:RegisterEffect(e1)
end
