-- WX15-091 幻蟲　§Ｃアント§
-- 【常】：対戦相手の場にパワー3000以上のシグニがあるかぎり、このシグニの基本パワーは5000になる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePower(c,5000,function(e) return Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:GetPower()>=3000 end,e:GetHandlerPlayer(),0,LOCATION_SZONE,nil):GetCount()>0 end)
end
