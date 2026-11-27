-- WX01-082 コードアート　Ｆ・Ａ・Ｎ
-- 【常】：あなたの手札が対戦相手より多いかぎり、このシグニの基本パワーは5000になる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePower(c,5000,function(e) local p=e:GetHandlerPlayer() return Duel.GetMatchingGroup(nil,p,LOCATION_HAND,0,nil):GetCount()-Duel.GetMatchingGroup(nil,p,0,LOCATION_HAND,nil):GetCount()>=1 end)
end
