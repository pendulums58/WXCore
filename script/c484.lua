-- WD15-014 幻竜　ヴイーヴル
-- 【出】：対戦相手のエナゾーンから対戦相手のセンタールリグと共通する色を持たないカード１枚を対象とし、それをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,s.filter(tp),tp,0,LOCATION_ENA,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToTrash(tc,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
end
-- 상대 센터 루리그와 공통되는 색이 없다. 무색은 색이 없으므로 늘 해당한다(【マルチエナ】여도)
function s.filter(tp)
  local lc=Duel.GetMatchingGroup(nil,tp,0,LOCATION_LRIG,nil):GetFirst()
  return function(x) return (x:GetColor() & (lc and lc:GetColor() or 0))==0 end
end
