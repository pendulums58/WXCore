-- WX02-046 犠牲の微笑　キュアエル
-- 【常】：あなたの場に他の＜天使＞のシグニがあるかぎり、このシグニの基本パワーは12000になる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePowerWhileClass(c,RACE_TENSHI,12000)
end
