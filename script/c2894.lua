-- WX16-079 羅菌　コロナウ
-- 【自】：このシグニが感染状態のシグニ１体をバニッシュしたとき、カードを１枚引く。
-- （【ウィルス】と同じシグニゾーンにあるシグニは感染状態である）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BANISHED)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg) return Duel.GetBanisher()==e:GetHandler() and eg:GetFirst():IsPreviousInfected() end)
  e1:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e1)
end
