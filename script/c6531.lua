-- WXK04-075 紅蓮の使い魔　キマ
-- 【起】《ダウン》：このターン、次にあなたが【出】能力を発動する場合、それの発動コストは《赤×1》減る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  -- 「次に【出】能力を発動する場合、それの発動コストは《赤×1》減る」는 아직
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCost(aux.SelfDownCost)
  e1:SetOperation(function(e,tp,eg)
    
  end)
  c:RegisterEffect(e1)
end
