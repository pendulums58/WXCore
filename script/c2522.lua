-- WX11-075 幻獣　アクティックス
-- 《クロスアイコン》《幻獣　アクティルフ》か《幻獣　アクティヘア》の右
-- 【クロス常】：このシグニの基本パワーは8000になる。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddCross(c,2495,CROSS_RIGHT)
  aux.AddCross(c,2525,CROSS_RIGHT)
  -- [の間] 【クロス常】
  aux.BasePower(c,8000,function(e) return e:GetHandler():IsCross() end)
end
