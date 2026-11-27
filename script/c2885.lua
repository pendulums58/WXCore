-- WX16-070 仕英の文章　＃シゴト＃
-- 【自】：このシグニがアタックしたとき、ターン終了時まで、このシグニのレベルを＋１するか＋２してもよい。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp)
    local m=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))
    local h=e:GetHandler()
    if m==2 or not h:IsLocation(LOCATION_SZONE) then return end
    local e1=Effect.CreateEffect(h)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_LEVEL)
    e1:SetValue(m+1)
    e1:SetReset(RESET_PHASE+PHASE_END)
    h:RegisterEffect(e1)
  end)
  c:RegisterEffect(e1)
end
