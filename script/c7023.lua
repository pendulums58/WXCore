-- WXK10-049 食菌　イースト
-- 【自】《ターン１回》：このシグニにカード１枚が付いたとき、【エナチャージ１】をする。
-- 【自】：このシグニがアタックしたとき、このシグニにカードが付いている場合、ターン終了時まで、このシグニは【ランサー】を得る。
-- （【アクセ】や【チャーム】はシグニに付く）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  -- 「このシグニにカード１枚が付いたとき」(【アクセ】·【チャーム】)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ACCE)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg) return eg:GetFirst():GetAcceHost()==e:GetHandler() end)
  e1:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetOperation(function(e,tp,eg)
    local h=e:GetHandler()
    local has=h:GetCharm()~=nil or Duel.GetMatchingGroup(function(x) return x:GetAcceHost()==h end,tp,LOCATION_ACCE,0,nil):GetCount()>0
    if has and h:IsLocation(LOCATION_SZONE) then aux.GrantKeyword(e,h,EFFECT_LANCER) end
  end)
  c:RegisterEffect(e2)
end
