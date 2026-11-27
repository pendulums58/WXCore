-- WX18-063 羅石　ニシキ
-- 【自】：各ターン終了時、このターンにあなたのライフクロスがクラッシュされていた場合、あなたのデッキの一番上のカードをエナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TURN_END)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp) return Duel.GetCrushedCount(tp)>0 end)
  e1:SetOperation(function(e,tp)
    Duel.EnaCharge(tp,1)
  end)
  c:RegisterEffect(e1)
end
