-- WX19-031 大盾　アキレウス
-- 【自】：あなたのセンタールリグがアタックしたとき、このシグニを場からトラッシュに置いてもよい。そうした場合、そのルリグをアップする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x:GetControler()==tp and x:IsType(TYPE_LRIG) end)
  e1:SetOperation(function(e,tp,eg)
    local h=e:GetHandler()
    if not (h:IsLocation(LOCATION_SZONE) and Duel.SelectYesNo(tp)) or Duel.SendToTrash(h,REASON_EFFECT)==0 then return end
    local x=eg:GetFirst()
    if x:IsLocation(LOCATION_LRIG) then Duel.Up(x) end
  end)
  c:RegisterEffect(e1)
end
