-- WX01-054 極盾　イギス
-- 【常】：対戦相手のターンの間、このシグニの基本パワーは18000になる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePower(c,18000,function(e) return Duel.GetTurnPlayer()~=e:GetHandlerPlayer() end)
end
