-- WX11-056 コードメイズ　ギンカク
-- 《クロスアイコン》《コードメイズ　キンカク》か《コードメイズ　ヒウンカ》の左
-- 【クロス常】：このシグニの基本パワーは8000になる。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddCross(c,2487,CROSS_LEFT)
  aux.AddCross(c,2508,CROSS_LEFT)
  -- [の間] 【クロス常】
  aux.BasePower(c,8000,function(e) return e:GetHandler():IsCross() end)
end
