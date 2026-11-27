-- WX12-033 幻獣　ソウリュウ
-- 【常】：あなたの場にカード名に《セイリュ》を含むシグニがあるかぎり、あなたのシグニの基本パワーを15000にする。
-- 【常】：あなたのトラッシュにカード名に《セイリュ》を含むカードがあるかぎり、このシグニは【ランサー】を得る。
-- 【常】：対戦相手の効果によって、あなたの＜空獣＞と＜地獣＞のシグニのパワーは増減しない。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 셋
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_SET_BASE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return x:IsSigni() end)
  e1:SetCondition(function(e) return Duel.GetMatchingGroup(function(x) return aux.NameHas(x,"セイリュ") end,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil):GetCount()>0 end)
  e1:SetValue(15000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EFFECT_LANCER)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e) return Duel.GetMatchingGroup(function(x) return aux.NameHas(x,"セイリュ") end,e:GetHandlerPlayer(),LOCATION_TRASH,0,nil):GetCount()>0 end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_FIELD)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EFFECT_NO_OPP_POWER_CARD)
  e3:SetRange(LOCATION_SZONE)
  e3:SetTargetRange(LOCATION_SZONE,0)
  e3:SetTarget(function(e,x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_KUJU) or x:IsClass(0,RACE_CHIJU)) end)(x) end)
  c:RegisterEffect(e3)
end
