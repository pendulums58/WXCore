-- WX09-040 天右の書記　サンダルフォン
-- 《クロスアイコン》 《天左の書記　メタトロン》の右
-- 【クロス常】：このシグニの基本パワーは5000になる。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddCross(c,2348,CROSS_RIGHT)
  -- [の間] 【クロス常】
  aux.BasePower(c,5000,function(e) return e:GetHandler():IsCross() end)
end
