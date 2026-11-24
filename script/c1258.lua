-- WD14-018 悪魔の乗り手　サロス
-- 【常】：あなたの場に他の＜悪魔＞のシグニがあるかぎり、このシグニの基本パワーは8000になる。
local s,id=GetID()
function s.initial_effect(c)
  aux.BasePowerWhileClass(c,RACE_AKUMA,8000)
end
