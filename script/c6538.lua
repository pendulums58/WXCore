-- WXK04-082 コードイート　ブルーワイハ
-- 【常】：このシグニに【アクセ】が付いているかぎり、このシグニのパワーは＋3000される。
-- 【常】：これにアクセされているシグニのパワーを＋3000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) local h=e:GetHandler() return Duel.GetMatchingGroup(function(a) return a:GetAcceHost()==h end,h:GetControler(),LOCATION_ACCE,0,nil):GetCount()>0 end)
  e1:SetValue(3000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  -- [の間] 【常】 이것이 붙은 시그니
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EFFECT_UPDATE_POWER)
  e2:SetRange(LOCATION_ACCE)
  e2:SetTargetRange(LOCATION_SZONE,0)
  e2:SetTarget(function(e,x) return x==e:GetHandler():GetAcceHost() end)
  e2:SetValue(3000)
  c:RegisterEffect(e2)
end
