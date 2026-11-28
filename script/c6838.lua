-- WXK08-052 爆書　グラング
-- 【自】：このシグニがアタックしたとき、対戦相手のシグニ１体を対象とし、このシグニの下にあるカード１枚をトラッシュに置いてもよい。そうした場合、ターン終了時まで、それのパワーを－3000する。
-- （パワーが０以下のシグニはルールによってバニッシュされる）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      local g=e:GetHandler():GetUnderGroup()
      if g:GetCount()>0 and Duel.SelectYesNo(tp) and Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_EFFECT)>0 then aux.AddPower(e,tc,-3000) end
    end
  end)
  c:RegisterEffect(e1)
end
