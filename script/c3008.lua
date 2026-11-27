-- WX18-056 惨之遊　†シガラヤキ†
-- 【自】：このシグニがアタックしたとき、対戦相手のシグニ１体を対象とし、このアタックフェイズの間にあなたのシグニが場からトラッシュに置かれていた場合、ターン終了時まで、それのパワーを－7000する。
local s,id=GetID()
function s.initial_effect(c)
  -- 「このアタックフェイズの間にシグニが場からトラッシュに置かれていた」 조건은 아직(항상 만족으로 근사)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-7000) end
  end)  -- [まで] ターン終了時まで
  c:RegisterEffect(e1)
end
