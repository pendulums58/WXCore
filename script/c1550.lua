-- WDK06-R12 極装　トンファー
-- 【出】《赤》《赤》：このターンにあなたが手札を１枚以上捨てていた場合、カードを２枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{R}{R}")
  e1:SetOperation(function(e,tp)
    if Duel.GetDiscardedCount(tp)>=1 then Duel.Draw(tp,2) end
  end)
  c:RegisterEffect(e1)
end
