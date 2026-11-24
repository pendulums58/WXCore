-- WDK01-015 コードライド　ワゴン
-- 【ドライブ常】：このシグニのパワーは＋7000される。
-- （【ドライブ常】はそのシグニがドライブ状態であるかぎり有効である）
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【ドライブ常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return e:GetHandler():IsDrive() end)
  e1:SetValue(7000)
  c:RegisterEffect(e1)
end
