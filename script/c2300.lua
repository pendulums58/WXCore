-- WX08-054 羅石　クリソコ
-- 【常】：あなたの場に＜鉱石＞か＜宝石＞のシグニが合計３体あるかぎり、このシグニの基本パワーは14000になる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 자신 포함 3체
  aux.BasePower(c,14000,function(e) return Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_KOUSEKI) or x:IsClass(0,RACE_HOUSEKI)) end,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil):GetCount()>=3 end)
end
