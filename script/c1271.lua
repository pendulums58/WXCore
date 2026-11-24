-- WD15-018 幻竜　ナイルワニ
-- 【出】：対戦相手のパワー5000以下のシグニ１体を対象とし、対戦相手のエナゾーンに対戦相手のセンタールリグと共通する色を持たないカードがある場合、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(aux.BanishPowerTarget(5000))
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e) and s.low(tc)) then return end
    if Duel.GetMatchingGroup(s.filter(tp),tp,0,LOCATION_ENA,nil):GetCount()>0 then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e1)
end
function s.low(c) return c:IsSigni() and c:GetPower()<=5000 end
-- 상대 센터 루리그와 공통되는 색이 없다. 무색은 색이 없으므로 늘 해당한다(【マルチエナ】여도)
function s.filter(tp)
  local lc=Duel.GetMatchingGroup(nil,tp,0,LOCATION_LRIG,nil):GetFirst()
  return function(x) return (x:GetColor() & (lc and lc:GetColor() or 0))==0 end
end
