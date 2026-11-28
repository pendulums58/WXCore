-- WXK04-076 コードイート　アイスオレン
-- 【起】《ダウン》：対戦相手のシグニ１体を対象とし、それをデッキの一番上に置く。この能力はこのシグニに【アクセ】が付いている場合にしか使用できない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCost(aux.SelfDownCost)
  e1:SetCondition(function(e,tp) local h=e:GetHandler() return Duel.GetMatchingGroup(function(a) return a:GetAcceHost()==h end,h:GetControler(),LOCATION_ACCE,0,nil):GetCount()>0 end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.SendToDeckPosition(tc,1)
    end
  end)
  c:RegisterEffect(e1)
end
