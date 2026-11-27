-- WX12-Re01 ミルルン・ゼプト
-- 【常】：あなたの場にそれぞれ名前の異なる＜原子＞のシグニが３体あるかぎり、あなたのシグニのパワーを＋2000する。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_LRIG)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return x:IsSigni() end)
  e1:SetCondition(function(e) local seen,n={},0 for x in Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_GENSHI)) end,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil):Iter() do if not seen[x:GetCode()] then seen[x:GetCode()]=true n=n+1 end end return n>=3 end)
  e1:SetValue(2000)
  c:RegisterEffect(e1)
end
