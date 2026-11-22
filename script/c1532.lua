-- WDK-F03-03 若月の巫女　タマヨリヒメ
-- 【出】《コインアイコン》：カードを１枚引く。
-- 코스트가 있으면 내지 않고 발동하지 않을 수 있다(FAQ 1)
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCoinCost(1)
  e1:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e1)
end
