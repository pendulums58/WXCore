-- WX15-089 幻蟲　§Ｓアント§
-- 【常】：対戦相手の場にパワー10000以上のシグニがあるかぎり、このシグニの基本パワーは12000になる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePower(c,12000,function(e) return Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:GetPower()>=10000 end,e:GetHandlerPlayer(),0,LOCATION_SZONE,nil):GetCount()>0 end)
end
