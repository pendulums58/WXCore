-- WX13-053 幻獣　ホトトギ
-- 【常】：このシグニのパワーはあなたのトラッシュにある＜空獣＞と＜地獣＞のシグニ１枚につき＋1000される。この効果は１０枚までしか適用されない。
-- 【常】：あなたのトラッシュに＜空獣＞のシグニが７枚以上あるかぎり、このシグニは対戦相手のアーツの効果を受けない。
-- 【常】：あなたのトラッシュに＜地獣＞のシグニが７枚以上あるかぎり、このシグニは【ランサー】を得る。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 셋
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetValue(function(e) return 1000*math.min(10,Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_KUJU) or x:IsClass(0,RACE_CHIJU)) end,e:GetHandlerPlayer(),LOCATION_TRASH,0,nil):GetCount()) end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EFFECT_IMMUNE)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e) return Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_KUJU)) end,e:GetHandlerPlayer(),LOCATION_TRASH,0,nil):GetCount()>=7 end)
  e2:SetValue(function(e,sc,sp) return sp~=e:GetHandlerPlayer() and sc:IsType(TYPE_ARTS) end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EFFECT_LANCER)
  e3:SetRange(LOCATION_SZONE)
  e3:SetCondition(function(e) return Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_CHIJU)) end,e:GetHandlerPlayer(),LOCATION_TRASH,0,nil):GetCount()>=7 end)
  c:RegisterEffect(e3)
end
