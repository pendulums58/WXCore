-- WX01-066 羅石　ルビル
-- 【常】：あなたのターンの間、このシグニの基本パワーは12000になる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePower(c,12000,function(e) return Duel.GetTurnPlayer()==e:GetHandlerPlayer() end)
end
