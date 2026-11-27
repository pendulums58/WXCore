-- WX14-058 小炎　フレイスロ二等兵
-- 【常】：あなたの場にレベル３以上のカード名に《フレイスロ》を含むシグニがあるかぎり、このシグニの基本パワーは10000になる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePower(c,10000,function(e) return Duel.GetMatchingGroup(function(x) return x:IsSigni() and aux.NameHas(x,"フレイスロ") and x:GetLevel()>=3 end,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil):GetCount()>0 end)
end
