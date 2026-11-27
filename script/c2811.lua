-- WX15-099 コードイート　シウマイ
-- 【常】：このシグニがアクセされているかぎり、このシグニの基本パワーは12000になる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePower(c,12000,function(e) return e:GetHandler():IsAcce() end)
end
