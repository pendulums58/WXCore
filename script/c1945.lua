-- WX02-062 羅植　ミズアオイ
-- 【常】：あなたの場に他の＜植物＞のシグニがあるかぎり、このシグニの基本パワーは12000になる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePowerWhileClass(c,RACE_SHOKUBUTSU,12000)
end
