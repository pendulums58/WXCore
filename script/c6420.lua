-- WXK03-046 大罠　ケンノミ
-- 【出】：対戦相手のシグニ１体を対象とし、あなたの場にレベルが奇数のシグニが３体ある場合、《黒》を支払ってもよい。そうした場合、ターン終了時まで、それのパワーを－12000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    if Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:GetLevel()%2==1 end,tp,LOCATION_SZONE,0,nil):GetCount()<3 then return end
    if not (Duel.CanPayEna(tp,"{B}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{B}"),REASON_COST)
    aux.AddPower(e,tc,-12000)
  end)
  c:RegisterEffect(e1)
end
