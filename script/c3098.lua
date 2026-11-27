-- WX19-078 羅菌　ムンプス
-- 【常】：このシグニの正面の感染状態のシグニがバニッシュされる場合、エナゾーンに置かれる代わりにトラッシュに置かれる。
-- （【ウィルス】と同じシグニゾーンにあるシグニは感染状態である）
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_BANISH_TO_TRASH)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(0,LOCATION_SZONE)
  e1:SetTarget(function(e,x) return x:IsInfected() and x:GetZone()==Duel.GetFrontZone(e:GetHandler():GetZone()) end)
  c:RegisterEffect(e1)
end
