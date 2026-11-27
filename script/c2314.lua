-- WX08-068 弦階の疑惑　ラダブラ
-- 【常】：あなたの場に＜美巧＞のシグニが３体あるかぎり、このシグニの基本パワーは14000になる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 자신 포함 3체
  aux.BasePower(c,14000,function(e) return Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_BIKOU)) end,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil):GetCount()>=3 end)
end
