-- WX11-055 運命の右糸　ラケシス
-- 《クロスアイコン》《運命の左糸　クロト》か《運命の左糸　アトロポス》の右
-- 【クロス常】：このシグニの基本パワーは8000になる。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddCross(c,2486,CROSS_RIGHT)
  aux.AddCross(c,2507,CROSS_RIGHT)
  -- [の間] 【クロス常】
  aux.BasePower(c,8000,function(e) return e:GetHandler():IsCross() end)
end
