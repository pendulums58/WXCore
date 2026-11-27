-- WX10-077 幻獣　ハシビロ
-- 【出】：あなたのシグニ１体を対象とし、ターン終了時まで、それのパワーを２倍にする。（そのシグニのパワーと同じ値だけパワーを＋（プラス）する）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,tc:GetPower()) end
  end)  -- [まで] 「２倍」 = 그 파워만큼 ＋(괄호)
  c:RegisterEffect(e1)
end
