-- WX15-110 異血之遊　†ケンダマ†
-- 【出】：このシグニがシグニの効果によって場に出たとき、対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－1000する。
-- （パワーが０以下のシグニはルールによってバニッシュされる）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCondition(function(e,tp,eg,ep,ev,re) return re~=nil and re:GetHandler():IsSigni() end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-1000) end
  end)  -- [まで] ターン終了時まで
  c:RegisterEffect(e1)
end
