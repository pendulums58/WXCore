-- WX02-047 虚構の愛情　シエル
-- 【常】：あなたの場に他の＜天使＞のシグニがあるかぎり、このシグニの基本パワーは8000になる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePowerWhileClass(c,RACE_TENSHI,8000)
end
