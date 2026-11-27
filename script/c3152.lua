-- WX20-066 幻水　ギンクチ
-- 【自】：このシグニが対戦相手のシグニ１体をバニッシュしたとき、このシグニを場から手札に戻してもよい。そうした場合、カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BANISHED)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg) return eg:GetFirst():GetOwner()~=tp and Duel.GetBanisher()==e:GetHandler() end)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) and Duel.SelectYesNo(tp) and Duel.SendToHand(h)>0 then Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e1)
end
