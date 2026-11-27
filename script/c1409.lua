-- WX11-035 極鎚　ミョルニル
-- 【自】：あなたの＜アーム＞のシグニ１体が場を離れたとき、あなたの手札からそのシグニより低いレベルを持つシグニ１枚を場に出してもよい。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_LEAVE_FIELD)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x~=e:GetHandler() and x:GetOwner()==tp and (function(x) return x:IsSigni() and (x:IsClass(0,RACE_ARM)) end)(x) end)
  e1:SetOperation(function(e,tp,eg)
    local lv=eg:GetFirst():GetLevel()
    local x=Duel.SelectCards(tp,Duel.GetMatchingGroup(function(c) return c:IsSigni() and c:GetLevel()<lv end,tp,LOCATION_HAND,0,nil),0,1):GetFirst()
    if x then Duel.PutOnField(x,tp) end
  end)
  c:RegisterEffect(e1)
end
