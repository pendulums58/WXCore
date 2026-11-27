-- WX15-090 幻蟲　§Ｗアント§
-- 【常】：対戦相手の場にパワー7000以上のシグニがあるかぎり、このシグニの基本パワーは8000になる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePower(c,8000,function(e) return Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:GetPower()>=7000 end,e:GetHandlerPlayer(),0,LOCATION_SZONE,nil):GetCount()>0 end)
end
