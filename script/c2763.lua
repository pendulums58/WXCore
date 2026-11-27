-- WX15-027 スプレッド・デス
-- 対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－7000する。そのシグニが感染状態の場合、代わりに－12000する。
-- （【ウィルス】と同じシグニゾーンにあるシグニは感染状態である）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,tc:IsInfected() and -12000 or -7000) end
  end)  -- [まで]
  c:RegisterEffect(e1)
end
