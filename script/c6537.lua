-- WXK04-081 コードイート　カキゴーリ
-- 【自】：対戦相手のターン終了時、このシグニに【アクセ】が付いている場合、対戦相手は手札を１枚捨てる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TURN_END)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()~=tp end)
  e1:SetOperation(function(e,tp,eg)
    local h=e:GetHandler()
    if Duel.GetMatchingGroup(function(a) return a:GetAcceHost()==h end,tp,LOCATION_ACCE,0,nil):GetCount()>0 then aux.Discard(1-tp,1) end
  end)
  c:RegisterEffect(e1)
end
