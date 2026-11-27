-- WX02-049 博愛の集束　サニエル
-- 【常】：あなたの場に他の＜天使＞のシグニがあるかぎり、このシグニの基本パワーは5000になる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePowerWhileClass(c,RACE_TENSHI,5000)
end
