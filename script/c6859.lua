-- WXK08-073 炎魔の鞭刑　アンピエル
-- 【常】《ビートアイコン》［１枚以上］：このシグニのパワーは＋5000される。
-- （この能力はあなたの【ビート】が１枚以上であるかぎり有効になる）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(aux.BeatCon(function(g) return g:GetCount()>=1 end))
  e1:SetValue(5000)
  c:RegisterEffect(e1)
end
