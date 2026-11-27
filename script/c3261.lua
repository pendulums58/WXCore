-- WX22-040 節句の踊火　ボンボリ
-- 【出】：あなたの場に白の＜美巧＞のシグニがある場合、あなたのデッキの一番上のカードをエナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    if Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_BIKOU)) end)(x) and x:IsColor(COLOR_WHITE) end,tp,LOCATION_SZONE,0,nil):GetCount()>0 then Duel.EnaCharge(tp,1) end
  end)
  c:RegisterEffect(e1)
end
