-- WX20-034-CB 偉智の遊　*ハッカドール１号*
-- 【出】：あなたの手札から白ではないレベル３以下の＜遊具＞のシグニ１枚を場に出してもよい。そうした場合、カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local x=Duel.SelectCards(tp,Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_YUGU)) end)(x) and not x:IsColor(COLOR_WHITE) and x:GetLevel()<=3 end,tp,LOCATION_HAND,0,nil),0,1):GetFirst()
    if x and Duel.PutOnField(x,tp) then Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e1)
end
