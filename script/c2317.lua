-- WX08-071 奏演の右音　クラリネ
-- 《クロスアイコン》《奏演の音左　フルート》の右
-- 【クロス常】：このシグニの基本パワーは5000になる。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddCross(c,2290,CROSS_RIGHT)
  -- [の間] 【クロス常】
  aux.BasePower(c,5000,function(e) return e:GetHandler():IsCross() end)
end
