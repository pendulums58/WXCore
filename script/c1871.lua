-- WX01-068 羅石　コハク
-- 【常】：あなたのターンの間、このシグニの基本パワーは8000になる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePower(c,8000,function(e) return Duel.GetTurnPlayer()==e:GetHandlerPlayer() end)
end
