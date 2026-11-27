-- WX02-054 小砲　スミス
-- 【常】：あなたの場に他の＜ウェポン＞のシグニがあるかぎり、このシグニの基本パワーは5000になる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePowerWhileClass(c,RACE_WEAPON,5000)
end
