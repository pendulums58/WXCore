-- WXK10-047 羅水植　マリモ
-- 【常】：あなたのエナゾーンに共通するクラスを持つシグニが５種類以上あるかぎり、このシグニのパワーは＋4000される。
-- 【自】：あなたの効果によってカード１枚があなたのエナゾーンに置かれたとき、ターン終了時まで、このシグニは【ランサー】を得る。
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) local g=Duel.GetMatchingGroup(Card.IsSigni,e:GetHandlerPlayer(),LOCATION_ENA,0,nil) for _,k in ipairs((function() local t,s={},{} for x in g:Iter() do for _,c in ipairs(x:GetClasses()) do if not s[c] then s[c]=true t[#t+1]=c end end end return t end)()) do local seen,n={},0 for x in g:Iter() do for _,c in ipairs(x:GetClasses()) do if c==k and not seen[x:GetCode()] then seen[x:GetCode()]=true n=n+1 end end end if n>=5 then return true end end return false end)
  e1:SetValue(4000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_TO_ENA)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) if rp~=tp or (r&REASON_EFFECT)==0 then return false end for x in eg:Iter() do if x:GetOwner()==tp then return true end end return false end)
  e2:SetOperation(function(e,tp,eg)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) then aux.GrantKeyword(e,h,EFFECT_LANCER) end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e9)
end
