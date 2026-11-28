-- WXK04-089 幻水　マダラモリ
-- 【出】手札から＜水獣＞のシグニを１枚エナゾーンに置く：あなたのエナゾーンから＜水獣＞のシグニ１枚を対象とし、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local h=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsClass(0,RACE_SUIJU) end,tp,LOCATION_HAND,0,nil)
    if chk==0 then return h:GetCount()>0 end
    Duel.SendToEna(Duel.SelectCards(tp,h,1,1))
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_SUIJU) end,tp,LOCATION_ENA,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.SendToHand(tc)
    end
  end)
  c:RegisterEffect(e1)
end
