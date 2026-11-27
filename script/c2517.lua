-- WX11-070 コードアート　Ｃ・Ｍ・Ｃ
-- 《クロスアイコン》《コードアート　Ｍ・Ｋ・Ｅ》か《コードアート　Ｖ・Ｒ・Ｃ》の左
-- 【クロス常】：このシグニの基本パワーは8000になる。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddCross(c,2492,CROSS_LEFT)
  aux.AddCross(c,2519,CROSS_LEFT)
  -- [の間] 【クロス常】
  aux.BasePower(c,8000,function(e) return e:GetHandler():IsCross() end)
end
