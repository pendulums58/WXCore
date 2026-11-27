-- WX16-Re09 保湿成分
-- アンコール －《無》
-- （アンコールコストを追加で支払って使用してもよい。そうした場合、これは追加で「このカードをルリグデッキに戻す。」を得る）
-- あなたのシグニ１体を対象とし、ターン終了時まで、それのパワーを＋3000し、それは「【常】：対戦相手のターンの間、このシグニは対戦相手の効果を受けない。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetEncoreCost("{C}")
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    aux.AddPower(e,tc,3000)  -- [まで]
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_IMMUNE)
    e1:SetValue(function(e2,sc,sp) return Duel.GetTurnPlayer()~=tp and sp~=tp end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e1)
  end)
  c:RegisterEffect(e1)
end
