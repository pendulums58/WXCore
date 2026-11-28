-- WXK09-043 切願の蒼天　アルペイオス
-- 【出】手札から＜天使＞のシグニを３枚エナゾーンに置く：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsClass(0,RACE_TENSHI) end,tp,LOCATION_HAND,0,nil)
    if chk==0 then return g:GetCount()>=3 end
    Duel.SendToEna(Duel.SelectCards(tp,g,3,3))
  end)
  e1:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e1)
end
