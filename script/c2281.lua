-- WX08-035 弩砲　トーピード
-- 【常】：このシグニのパワーはあなたの場にある《クロスアイコン》を持つシグニ１体につき＋2000される。
-- 【自】：あなたのシグニが《ヘブン》したとき、《赤》《赤》を支払ってもよい。そうした場合、このシグニをアップする。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetValue(function(e) return 2000*Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:HasCrossIcon() end,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil):GetCount() end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_HEAVEN)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e,tp,eg,ep) return ep==tp end)
  e2:SetOperation(function(e,tp)
    if not (Duel.CanPayEna(tp,"{R}{R}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{R}{R}"),REASON_COST)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) then Duel.Up(h) end
  end)
  c:RegisterEffect(e2)
end
