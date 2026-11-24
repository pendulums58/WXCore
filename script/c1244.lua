-- WD13-020 小盾　ラウンド
-- 【常】：対戦相手のターンの間、このシグニの基本パワーは5000になる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePower(c,5000,function(e) return Duel.GetTurnPlayer()~=e:GetHandlerPlayer() end)
end
