-- WX01-096 幻獣　ミケ
-- 【常】：あなたのエナゾーンにあるカードが対戦相手より２枚以上多いかぎり、このシグニの基本パワーは5000になる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePower(c,5000,function(e) local p=e:GetHandlerPlayer() return Duel.GetMatchingGroup(nil,p,LOCATION_ENA,0,nil):GetCount()-Duel.GetMatchingGroup(nil,p,0,LOCATION_ENA,nil):GetCount()>=2 end)
end
