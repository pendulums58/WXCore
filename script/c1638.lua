-- WDK07-Y12 羅植　ウメ
-- 【起】《ターン１回》エナゾーンから＜植物＞のシグニ３枚をトラッシュに置く：対戦相手のシグニ１体を対象とし、それをトラッシュに置く。
local s,id=GetID()
s.shoku=aux.ClassFilter(0,RACE_SHOKUBUTSU)  -- ＜植物＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.shoku,tp,LOCATION_ENA,0,nil)
    if chk==0 then return g:GetCount()>=3 end
    Duel.SendToTrash(Duel.SelectCards(tp,g,3,3),REASON_COST)
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToTrash(tc,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
end
