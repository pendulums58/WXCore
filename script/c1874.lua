-- WX01-071 羅石　サファイ
-- 【常】：あなたのターンの間、このシグニの基本パワーは5000になる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePower(c,5000,function(e) return Duel.GetTurnPlayer()==e:GetHandlerPlayer() end)
end
