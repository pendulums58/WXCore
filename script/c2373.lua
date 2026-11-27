-- WX09-052 羅植　ユウガオ
-- 《クロスアイコン》 《羅植　アサガオ》の右
-- 【クロス常】：このシグニの基本パワーは5000になる。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddCross(c,2357,CROSS_RIGHT)
  -- [の間] 【クロス常】
  aux.BasePower(c,5000,function(e) return e:GetHandler():IsCross() end)
end
