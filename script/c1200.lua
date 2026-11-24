-- WD10-013 爆砲　スタン
-- 《クロスアイコン》《小砲　グレネド》の左
-- 【クロス常】：このシグニの基本パワーは8000になる。
local s,id=GetID()
function s.initial_effect(c)
  -- 크로스 조건
  local e0=Effect.CreateEffect(c)
  e0:SetType(EFFECT_TYPE_SINGLE)
  e0:SetCode(EFFECT_CROSS)
  e0:SetValue(1202)
  e0:SetLabel(CROSS_LEFT)
  c:RegisterEffect(e0)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_SET_BASE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return e:GetHandler():IsCross() end)
  e1:SetValue(8000)
  c:RegisterEffect(e1)
end
