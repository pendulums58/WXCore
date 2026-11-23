-- WD06-014 幻水　コザメ
-- 【常】：あなたの場に他の＜水獣＞のシグニがあるかぎり、このシグニの基本パワーは5000になる。
local s,id=GetID()
function s.initial_effect(c)
  aux.BasePowerWhileClass(c,RACE_SUIJU,5000)  -- [の間] 【常】
end
