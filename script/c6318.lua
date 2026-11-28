-- WXK02-042 仁の遊　　ヨミフダ
-- 【自】：このシグニがアタックしたとき、対戦相手のレベル２以下のシグニ１体を対象とし、このターンにシグニが場から手札に戻っていた場合、それを手札に戻す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  -- 몇 체 돌아갔든 1번(FAQ 3)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=2 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      if Duel.GetBouncedCount()>=1 then Duel.SendToHand(tc) end
    end
  end)
  c:RegisterEffect(e1)
end
