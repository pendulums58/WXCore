-- WXK08-010 エース・スパイク
-- 対戦相手のシグニ１体を対象とし、ターン終了時まで、それは「【常】：アタックできない。」を得る。その後、あなたのキー１枚を場からルリグトラッシュに置いてもよい。そうした場合、対戦相手のシグニ１体を対象とし、それをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_CANNOT_ATTACK)
      e1:SetReset(RESET_PHASE+PHASE_END)
      tc:GrantEffect(e1)
    end
    local kg=Duel.GetMatchingGroup(nil,tp,LOCATION_KEY,0,nil)
    if kg:GetCount()==0 or not Duel.SelectYesNo(tp) then return end
    Duel.SendToLrigTrash(Duel.SelectCards(tp,kg,1,1),REASON_EFFECT)
    local x=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if x then Duel.SendToTrash(x,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
end
