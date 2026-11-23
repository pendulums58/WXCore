-- WD07-015 コードアンチ　クレイ
-- 【常】：あなたの場に他の＜古代兵器＞のシグニがあるかぎり、このシグニの基本パワーは5000になる。
local s,id=GetID()
function s.initial_effect(c)
  aux.BasePowerWhileClass(c,RACE_KODAIHEIKI,5000)  -- [の間] 【常】
end
