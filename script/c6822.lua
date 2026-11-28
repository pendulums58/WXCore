-- WXK08-036 コードＶＬ　雪汝
-- 【常】：あなたの場に他の＜電機＞のシグニがあるかぎり、このシグニは対戦相手のシグニの効果によってバニッシュされない。（シグニとのバトルやパワーが０以下になった場合はバニッシュされる）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】 상대 시그니의 효과로 바니시되지 않는다
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_BANISH_IMMUNE)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) local h=e:GetHandler() return Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_DENKI) end)(x) and x~=h end,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil):GetCount()>0 end)
  e1:SetValue(function(e,sc,sp) return sp~=e:GetHandlerPlayer() and sc:IsSigni() end)
  c:RegisterEffect(e1)
end
