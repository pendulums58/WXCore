-- WX01-087 幻獣　ケットシー
-- 【常】：あなたのエナゾーンにあるカードが対戦相手より５枚以上多いかぎり、このシグニの基本パワーは18000になる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePower(c,18000,function(e) local p=e:GetHandlerPlayer() return Duel.GetMatchingGroup(nil,p,LOCATION_ENA,0,nil):GetCount()-Duel.GetMatchingGroup(nil,p,0,LOCATION_ENA,nil):GetCount()>=5 end)
end
