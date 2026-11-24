-- WD10-013 爆砲　スタン
-- 《クロスアイコン》《小砲　グレネド》の左
-- 【クロス常】：このシグニの基本パワーは8000になる。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddCross(c,1202,CROSS_LEFT)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_SET_BASE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return e:GetHandler():IsCross() end)
  e1:SetValue(8000)
  c:RegisterEffect(e1)
end
