-- WDK08-Y15 幻水　アマケロ
-- 【自】：あなたが自分の効果によって手札からカードを１枚以上公開したとき、ターン終了時まで、このシグニのパワーを＋5000する。
--   （同時に２枚以上公開しても一度しか発動しない）
local s,id=GetID()
function s.initial_effect(c)
  -- 공개 한 번에 이벤트 한 번이라 여러 장이어도 한 번
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_REVEALED_FROM_HAND)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return ep==tp and rp==tp end)
  e1:SetOperation(function(e,tp)
    local c=e:GetHandler()
    if c:IsLocation(LOCATION_SZONE) then aux.AddPower(e,c,5000) end  -- [まで] ターン終了時まで
  end)
  c:RegisterEffect(e1)
end
