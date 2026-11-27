-- WX01-089 幻獣　クロ
-- 【常】：あなたのエナゾーンにあるカードが対戦相手より４枚以上多いかぎり、このシグニの基本パワーは12000になる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePower(c,12000,function(e) local p=e:GetHandlerPlayer() return Duel.GetMatchingGroup(nil,p,LOCATION_ENA,0,nil):GetCount()-Duel.GetMatchingGroup(nil,p,0,LOCATION_ENA,nil):GetCount()>=4 end)
end
