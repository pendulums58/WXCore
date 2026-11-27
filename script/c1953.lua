-- WX02-074 小悪の憂鬱　グリム
-- 【常】：あなたのトラッシュにカードが２枚以上あるかぎり、このシグニの基本パワーは5000になる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePower(c,5000,function(e) return Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),LOCATION_TRASH,0,nil):GetCount()>=2 end)
end
