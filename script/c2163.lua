-- WX06-045 コードアート　Ｈ・Ｍ・Ｆ
-- 【常】：あなたの場に他の＜電機＞のシグニがあるかぎり、このシグニの基本パワーは8000になる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePower(c,8000,function(e) return Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_DENKI)) end,e:GetHandlerPlayer(),LOCATION_SZONE,0,e:GetHandler()):GetCount()>0 end)
end
