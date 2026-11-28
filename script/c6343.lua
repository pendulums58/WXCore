-- WXK02-067 讃の遊　タケトンボ
-- 【常】：このターンにシグニが場から手札に戻っていた場合、このシグニのパワーは＋7000される。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】 어느 쪽 시그니든, 이 시그니가 나오기 전이어도(FAQ 1·2)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function() return Duel.GetBouncedCount()>=1 end)
  e1:SetValue(7000)
  c:RegisterEffect(e1)
end
