-- WX04-078 コードアート　Ｒ・Ｐ・Ｇ
-- 【常】：対戦相手の場に凍結状態のシグニがあるかぎり、このシグニの基本パワーは10000になる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePower(c,10000,function(e) return Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsFrozen() end,e:GetHandlerPlayer(),0,LOCATION_SZONE,nil):GetCount()>0 end)
end
