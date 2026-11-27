-- WX04-098 堕落の吐露　マイモン
-- 【常】：このシグニに【チャーム】が付いているかぎり、このシグニの基本パワーは10000になる。
-- （【チャーム】は裏向きでシグニに付き、１体に１枚までしか付けられない）
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePower(c,10000,function(e) return e:GetHandler():GetCharm()~=nil end)
end
