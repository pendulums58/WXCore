-- WX07-070 幻獣　ハリネズ
-- 【常】：あなたの場に＜空獣＞か＜地獣＞のシグニが合計３体あるかぎり、このシグニの基本パワーは6000になる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 자신 포함 3체
  aux.BasePower(c,6000,function(e) return Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_KUJU) or x:IsClass(0,RACE_CHIJU)) end,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil):GetCount()>=3 end)
end
