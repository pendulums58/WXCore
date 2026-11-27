-- WX15-100 コードイート　ショロポ
-- 【常】：このシグニがアクセされているかぎり、このシグニの基本パワーは8000になる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePower(c,8000,function(e) return e:GetHandler():IsAcce() end)
end
