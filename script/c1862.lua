-- WX01-055 大盾　ライオット
-- 【常】：対戦相手のターンの間、このシグニの基本パワーは12000になる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePower(c,12000,function(e) return Duel.GetTurnPlayer()~=e:GetHandlerPlayer() end)
end
