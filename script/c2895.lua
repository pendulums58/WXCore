-- WX16-080 羅菌　クモカビ
-- 【自】：このシグニがバニッシュされたとき、対戦相手の感染状態のシグニ１体を対象とし、ターン終了時まで、それのパワーを－2000する。
-- （【ウィルス】と同じシグニゾーンにあるシグニは感染状態である）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BANISHED)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsInfected() end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-2000) end
  end)  -- [まで] ターン終了時まで
  c:RegisterEffect(e1)
end
