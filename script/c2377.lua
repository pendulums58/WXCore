-- WX09-056 コードアンチ　クトガ
-- 《クロスアイコン》 《コードアンチ　ニャルラト》の左
-- 【クロス常】：このシグニの基本パワーは5000になる。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddCross(c,2360,CROSS_LEFT)
  -- [の間] 【クロス常】
  aux.BasePower(c,5000,function(e) return e:GetHandler():IsCross() end)
end
