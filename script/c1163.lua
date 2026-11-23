-- WD07-014 コードアンチ　モア
-- 【常】：あなたの場に他の＜古代兵器＞のシグニがあるかぎり、このシグニの基本パワーは8000になる。
local s,id=GetID()
function s.initial_effect(c)
  aux.BasePowerWhileClass(c,RACE_KODAIHEIKI,8000)  -- [の間] 【常】
end
