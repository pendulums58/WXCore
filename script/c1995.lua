-- WX03-046 打突
-- シグニ１体を対象とし、ターン終了時まで、それのパワーを＋5000する。その後、それのパワーが15000以上である場合、ターン終了時まで、それは【ランサー】を得る。
-- （このシグニがバトルで対戦相手のシグニをバニッシュしたとき、対戦相手のライフクロスを１枚クラッシュする）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
  end)
  -- [まで] 【ランサー】는 처리할 때 정한다(FAQ 1)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    aux.AddPower(e,tc,5000)
    if tc:GetPower()>=15000 then aux.GrantKeyword(e,tc,EFFECT_LANCER) end
  end)
  c:RegisterEffect(e1)
end
