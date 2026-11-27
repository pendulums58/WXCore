-- WX02-051 轟砲　ランチャーギア
-- 【常】：あなたの場に他の＜ウェポン＞のシグニがあるかぎり、このシグニの基本パワーは12000になる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePowerWhileClass(c,RACE_WEAPON,12000)
end
