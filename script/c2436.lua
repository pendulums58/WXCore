-- WX10-074 肆ノ遊　ツナヒキ
-- 【自】：あなたのシグニ１体がダウン状態で場に出たとき、そのシグニをアップする。（このシグニがダウン状態で場に出たときも発動する）
local s,id=GetID()
function s.initial_effect(c)
  -- 자신이 다운 상태로 나와도(괄호)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x:GetControler()==tp and x:IsSigni() and not x:IsUp() end)
  e1:SetOperation(function(e,tp,eg)
    local x=eg:GetFirst()
    if x:IsLocation(LOCATION_SZONE) then Duel.Up(x) end
  end)
  c:RegisterEffect(e1)
end
