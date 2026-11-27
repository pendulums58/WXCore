-- WX15-103 コードイート　ギョウズ
-- 【常】：このシグニがアクセされているかぎり、このシグニの基本パワーは5000になる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePower(c,5000,function(e) return e:GetHandler():IsAcce() end)
end
