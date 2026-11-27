-- WX05-069 鮮明な名宴　ポップ
-- 【常】：あなたのセンタールリグがレベル４以上であるかぎり、このシグニの基本パワーは10000になる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePower(c,10000,function(e) local lc=Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),LOCATION_LRIG,0,nil):GetFirst() return lc and lc:GetLevel()>=4 end)
end
