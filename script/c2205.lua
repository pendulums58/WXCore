-- WX07-036 弩炎　フレイスロ少佐
-- 【自】：あなたの＜ウェポン＞のシグニが効果によって対戦相手のシグニ１体をバニッシュしたとき、ターン終了時まで、このシグニは【ダブルクラッシュ】を得る。
local s,id=GetID()
function s.initial_effect(c)
  -- 효과에 의한 것만. 배틀은 아니다(FAQ 1·2)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BANISHED)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) local x=eg:GetFirst() if r&REASON_EFFECT==0 or x:GetOwner()==tp or not re then return false end local h=re:GetHandler() return h and h:GetControler()==tp and (function(x) return x:IsSigni() and (x:IsClass(0,RACE_WEAPON)) end)(h) end)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) then aux.GrantKeyword(e,h,EFFECT_DOUBLE_CRUSH) end  -- [まで]
  end)
  c:RegisterEffect(e1)
end
