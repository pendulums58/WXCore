-- WX02-052 爆砲　ＭＰ５
-- 【常】：あなたの場に他の＜ウェポン＞のシグニがあるかぎり、このシグニの基本パワーは8000になる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePowerWhileClass(c,RACE_WEAPON,8000)
end
