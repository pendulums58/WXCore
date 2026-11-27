-- WX07-062 羅原　Uup
-- 【常】：あなたの場に＜原子＞のシグニが３体あるかぎり、このシグニの基本パワーは9000になる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 자신 포함 3체
  aux.BasePower(c,9000,function(e) return Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_GENSHI)) end,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil):GetCount()>=3 end)
end
