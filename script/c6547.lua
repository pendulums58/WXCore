-- WXK04-091 幻水　ウパルパ
-- 【自】：あなたが自分の効果によって手札からカードを１枚以上公開したとき、ターン終了時まで、このシグニのパワーを＋5000する。（同時に２枚以上公開しても一度しか発動しない）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  -- 한 번에 여러 장이어도 1번(카드 주석)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_REVEALED_FROM_HAND)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return ep==tp and rp==tp end)
  e1:SetOperation(function(e,tp,eg)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) then aux.AddPower(e,h,5000) end
  end)
  c:RegisterEffect(e1)
end
