-- WD15-016 幻竜　ティラノ
-- 【起】《ダウン》：対戦相手のパワー8000以下のシグニ１体を対象とし、それをバニッシュする。この能力は対戦相手のエナゾーンにあるカードが４枚以下の場合にしか使用できない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),0,LOCATION_ENA,nil):GetCount()<=4 end)
  e1:SetCost(aux.SelfDownCost)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and s.filter(tc) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e1)
end
function s.filter(c) return c:IsSigni() and c:GetPower()<=8000 end
