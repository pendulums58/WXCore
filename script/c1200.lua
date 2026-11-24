-- WD10-013 爆砲　スタン
-- 《クロスアイコン》《小砲　グレネド》の左
-- 【クロス常】：このシグニの基本パワーは8000になる。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddCross(c,1202,CROSS_LEFT)
  -- [の間] 【常】
  aux.BasePower(c,8000,function(e) return e:GetHandler():IsCross() end)
end
