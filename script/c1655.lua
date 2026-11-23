-- WDK08-L13 紅蓮の使い魔　アマテラス
-- 【常】：あなたの血晶武装状態のシグニは【ダブルクラッシュ】を得る。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 내 血晶武装状態 시그니. 이 시그니 자신도 된다(FAQ 2)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_DOUBLE_CRUSH)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SIGNI,0)
  e1:SetTarget(function(e,x) return x:IsBloodArmed() end)
  c:RegisterEffect(e1)
end
