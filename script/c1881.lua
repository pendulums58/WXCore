-- WX01-078 コードアート　Ｓ・Ｔ・Ｇ
-- 【常】：あなたの手札が対戦相手より２枚以上多いかぎり、このシグニの基本パワーは8000になる
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePower(c,8000,function(e) local p=e:GetHandlerPlayer() return Duel.GetMatchingGroup(nil,p,LOCATION_HAND,0,nil):GetCount()-Duel.GetMatchingGroup(nil,p,0,LOCATION_HAND,nil):GetCount()>=2 end)
end
