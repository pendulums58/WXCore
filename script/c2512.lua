-- WX11-065 羅石　ロズオラ
-- 《クロスアイコン》《羅石　オロオラ》か《羅石　アクアオラ》の右
-- 【クロス常】：このシグニの基本パワーは8000になる。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddCross(c,2490,CROSS_RIGHT)
  aux.AddCross(c,2514,CROSS_RIGHT)
  -- [の間] 【クロス常】
  aux.BasePower(c,8000,function(e) return e:GetHandler():IsCross() end)
end
