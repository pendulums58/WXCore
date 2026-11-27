-- WX15-078 羅星　≡シリウス≡
-- 【常】：対戦相手の場にシグニが３体あるかぎり、このシグニの基本パワーは8000になる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePower(c,8000,function(e) return Duel.GetMatchingGroup(Card.IsSigni,e:GetHandlerPlayer(),0,LOCATION_SZONE,nil):GetCount()>=3 end)
end
