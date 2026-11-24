-- WDK05-R15 国英の変動　エンヤス
-- 【自】《ターン１回》：あなたがカードを１枚引いたとき、ターン終了時まで、このシグニのパワーを＋5000する。
local s,id=GetID()
function s.initial_effect(c)
  -- 2장을 뽑으면 두 번 트리거한다(FAQ 1)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_DRAW_ONE)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg,ep) return ep==tp end)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) then aux.AddPower(e,h,5000) end  -- [まで] ターン終了時まで
  end)
  c:RegisterEffect(e1)
end
