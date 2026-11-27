-- WX22-048 アイン＝バジリスク
-- 【出】：対戦相手のシグニ１体を対象とし、このシグニがトラッシュから場に出た場合、ターン終了時まで、それのパワーを－2000する。この効果によってそのシグニのパワーが０以下になった場合、このシグニをバニッシュする。
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
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e) and e:GetHandler():IsPreviousLocation(LOCATION_TRASH)) then return end
    aux.AddPower(e,tc,-2000)  -- [まで]
    local h=e:GetHandler()
    if tc:GetPower()<=0 and h:IsLocation(LOCATION_SZONE) then Duel.Banish(h) end
  end)
  c:RegisterEffect(e1)
end
