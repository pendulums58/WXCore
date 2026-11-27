-- WX16-059 鉞担の足柄　キンタロ
-- 【ライズ】あなたのレベル１の赤のシグニ１体の上に置く
-- 【常】：あなたのターンの間、このシグニの基本パワーは10000になる。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddRise(c,function(x) return x:IsSigni() and x:IsColor(COLOR_RED) and x:GetLevel()==1 end)
  -- [の間] 【常】
  aux.BasePower(c,10000,function(e) return Duel.GetTurnPlayer()==e:GetHandlerPlayer() end)
end
