-- WX20-039-CB 丹乃遊　≡ハッカドール２号≡
-- 【出】：対戦相手のパワー5000以下のシグニ１体を対象とし、あなたの手札から赤ではないレベル３以下の＜遊具＞のシグニ１枚を場に出してもよい。そうした場合、その対戦相手のシグニをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=5000 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local x=Duel.SelectCards(tp,Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_YUGU)) end)(x) and not x:IsColor(COLOR_RED) and x:GetLevel()<=3 end,tp,LOCATION_HAND,0,nil),0,1):GetFirst()
    if not (x and Duel.PutOnField(x,tp)) then return end
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e1)
end
