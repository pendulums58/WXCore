-- WX02-063 羅植　ハス
-- 【常】：あなたの場に他の＜植物＞のシグニがあるかぎり、このシグニの基本パワーは8000になる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePowerWhileClass(c,RACE_SHOKUBUTSU,8000)
end
