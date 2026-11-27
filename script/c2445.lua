-- WX10-083 壱ノ遊　アヤトリ
-- 【自】：あなたの他のシグニ１体が効果によって場に出たとき、このシグニをアップする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r) local x=eg:GetFirst() return x~=e:GetHandler() and x:GetControler()==tp and x:IsSigni() and r&REASON_EFFECT~=0 end)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) then Duel.Up(h) end
  end)
  c:RegisterEffect(e1)
end
