-- WX02-065 羅植　スベリア
-- 【常】：あなたの場に他の＜植物＞のシグニがあるかぎり、このシグニの基本パワーは5000になる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePowerWhileClass(c,RACE_SHOKUBUTSU,5000)
end
