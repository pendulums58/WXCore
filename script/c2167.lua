-- WX06-049 幻獣　ウォンバ
-- 【常】：あなたの場に他の＜空獣＞か＜地獣＞のシグニがあるかぎり、このシグニの基本パワーは5000になる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePower(c,5000,function(e) return Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_KUJU) or x:IsClass(0,RACE_CHIJU)) end,e:GetHandlerPlayer(),LOCATION_SZONE,0,e:GetHandler()):GetCount()>0 end)
end
