-- WX09-043 幻竜　パキケロ
-- 《クロスアイコン》 《幻竜　アンキロ》の左
-- 【クロス常】：このシグニの基本パワーは5000になる。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddCross(c,2350,CROSS_LEFT)
  -- [の間] 【クロス常】
  aux.BasePower(c,5000,function(e) return e:GetHandler():IsCross() end)
end
