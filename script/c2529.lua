-- WX11-084 復讐の左魔　ティシポネ
-- 《クロスアイコン》《復讐の右魔　アレークト》か《復讐の右魔　メガイラ》の左
-- 【クロス常】：このシグニの基本パワーは8000になる。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddCross(c,2499,CROSS_LEFT)
  aux.AddCross(c,2530,CROSS_LEFT)
  -- [の間] 【クロス常】
  aux.BasePower(c,8000,function(e) return e:GetHandler():IsCross() end)
end
