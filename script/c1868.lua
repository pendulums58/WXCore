-- WX01-065 羅石　エメラルダ
-- 【常】：あなたのターンの間、このシグニの基本パワーは18000になる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePower(c,18000,function(e) return Duel.GetTurnPlayer()==e:GetHandlerPlayer() end)
end
