-- WX06-040 小拳　フィング
-- 【常】：あなたの場に他の＜アーム＞のシグニがあるかぎり、このシグニの基本パワーは5000になる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePower(c,5000,function(e) return Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_ARM)) end,e:GetHandlerPlayer(),LOCATION_SZONE,0,e:GetHandler()):GetCount()>0 end)
end
