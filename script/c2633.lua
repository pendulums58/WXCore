-- WX13-062 巨弓　ハラダヌ
-- 【出】：対戦相手のレベル２以下のシグニ１体を対象とし、あなたの場にカード名に《弓》を含むシグニが３体ある場合、それを手札に戻す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=2 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then if Duel.GetMatchingGroup(function(x) return x:IsSigni() and aux.NameHas(x,"弓") end,tp,LOCATION_SZONE,0,nil):GetCount()>=3 then Duel.SendToHand(tc) end end
  end)
  c:RegisterEffect(e1)
end
