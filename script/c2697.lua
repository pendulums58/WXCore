-- WX14-036 羅石　ルオライト
-- 【常】：対戦相手のセンタールリグがレベル４以上であるかぎり、このシグニの基本パワーは12000になる。
-- 【常】：対戦相手のセンタールリグがレベル５であるかぎり、このシグニは【アサシン】を得る。
-- （【アサシン】を持つシグニがアタックすると正面のシグニとバトルをせず対戦相手にダメージを与える）
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 둘
  aux.BasePower(c,12000,function(e) local lc=Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),0,LOCATION_LRIG,nil):GetFirst() return lc and lc:GetLevel()>=4 end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EFFECT_ASSASSIN)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) local lc=Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),0,LOCATION_LRIG,nil):GetFirst() return lc and lc:GetLevel()==5 end)
  c:RegisterEffect(e1)
end
