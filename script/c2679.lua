-- WX14-015 三型藹々娘　緑姫
-- 【出】：あなたの場にある＜植物＞のシグニ１体につきあなたのデッキの一番上のカードをエナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local n=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_SHOKUBUTSU)) end,tp,LOCATION_SZONE,0,nil):GetCount()
    if n>0 then Duel.EnaCharge(tp,n) end
  end)
  c:RegisterEffect(e1)
end
