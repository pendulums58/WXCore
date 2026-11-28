-- WDK15-012 弩書　ジャパコカビ
-- 【起】《ダウン》このシグニの下からカード１枚をトラッシュに置く：対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－12000する。
-- （パワーが０以下のシグニはルールによってバニッシュされる）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local h=e:GetHandler()
    if chk==0 then return h:GetUnderGroup():GetCount()>0 and aux.SelfDownCost(e,tp,eg,ep,ev,re,r,rp,0) end
    aux.SelfDownCost(e,tp,eg,ep,ev,re,r,rp,1)
    Duel.SendToTrash(Duel.SelectCards(tp,h:GetUnderGroup(),1,1),REASON_COST)
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-12000) end
  end)  -- [まで] ターン終了時まで
  c:RegisterEffect(e1)
end
