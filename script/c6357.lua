-- WXK02-081 小装　ファイアックス
-- 【常】：このターンにあなたが手札を１枚以上捨てていた場合、このシグニのパワーは＋5000される。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】 나오기 전이어도(FAQ 1)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return Duel.GetDiscardedCount(e:GetHandlerPlayer())>0 end)
  e1:SetValue(5000)
  c:RegisterEffect(e1)
end
