-- WX08-039 コードアート　Ｍ・Ｍ
-- 【自】《ターン１回》：対戦相手のシグニ１体が凍結状態になったとき、対戦相手は手札を１枚捨てる。
-- 【起】《青》《ダウン》：対戦相手のシグニ１体を対象とし、それをバニッシュする。この能力は対戦相手の手札が０枚の場合にしか使用できない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_FROZEN)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg) return eg:GetFirst():GetControler()~=tp end)
  e1:SetOperation(function(e,tp)
    aux.Discard(1-tp,1)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetEnaCost("{U}")
  e2:SetCost(aux.SelfDownCost)
  e2:SetCondition(function(e,tp) return Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil):GetCount()==0 end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e2)
end
