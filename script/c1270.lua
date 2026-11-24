-- WD15-017 幻竜　グリアナ
-- 【常】：対戦相手のエナゾーンにあるカードが３枚以下であるかぎり、このシグニの基本パワーは8000になる。
-- 【起】《ダウン》：対戦相手のエナゾーンから対戦相手のセンタールリグと共通する色を持たないカード１枚を対象とし、それをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  aux.BasePower(c,8000,function(e) return Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),0,LOCATION_ENA,nil):GetCount()<=3 end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCost(aux.SelfDownCost)
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
