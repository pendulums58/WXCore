-- WXK07-071 羅菌　ビタミンB6
-- 【自】《ターン１回》：このシグニがアタックしたとき、このシグニに【チャーム】が付いている場合、《緑》を支払ってもよい。そうした場合、このシグニをアップする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e) return e:GetHandler():GetCharm()~=nil end)
  e1:SetOperation(function(e,tp,eg)
    if not (Duel.CanPayEna(tp,"{G}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{G}"),REASON_COST)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) then Duel.Up(h) end
  end)
  c:RegisterEffect(e1)
end
