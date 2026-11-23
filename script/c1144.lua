-- WD06-010 幻水　オクト
-- 【常】：あなたの場に他の＜水獣＞のシグニがあるかぎり、このシグニの基本パワーは12000になる。
local s,id=GetID()
function s.initial_effect(c)
  aux.BasePowerWhileClass(c,RACE_SUIJU,12000)  -- [の間] 【常】
end
