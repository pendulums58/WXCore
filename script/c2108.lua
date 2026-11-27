-- WX05-047 大剣　レヴァテイン
-- 【自】：このシグニが対戦相手のレベル４のシグニとバトルしたとき、その対戦相手のシグニをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BATTLE)
  e1:SetCondition(function(e,tp) local x=Duel.GetBattleOpponent() return x and x:GetControler()~=tp and x:GetLevel()==4 end)
  e1:SetOperation(function(e,tp)
    local x=Duel.GetBattleOpponent()
    if x and x:IsLocation(LOCATION_SZONE) then Duel.Banish(x) end
  end)
  c:RegisterEffect(e1)
end
