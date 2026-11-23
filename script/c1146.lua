-- WD06-012 幻水　パール
-- 【常】：あなたの場に他の＜水獣＞のシグニがあるかぎり、このシグニの基本パワーは8000になる。
local s,id=GetID()
function s.initial_effect(c)
  aux.BasePowerWhileClass(c,RACE_SUIJU,8000)  -- [の間] 【常】
end
