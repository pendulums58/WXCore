-- WXDi-D01-012 羅星　カメロパル
-- 【常】：あなたのエナゾーンにあるシグニが持つクラスが合計３種類以上あるかぎり、このシグニのパワーは＋４０００される。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(s.con)
  e1:SetValue(4000)
  c:RegisterEffect(e1)
end
function s.con(e)
  local tp=e:GetHandlerPlayer()
  return aux.ClassCount(Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_ENA,0,nil))>=3
end
