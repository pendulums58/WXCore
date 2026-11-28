-- WXK06-068 コードメイズ　ドバム
-- 【自】：あなたのアタックフェイズ開始時、このターンに対戦相手のカードがあなたの効果によって３枚以上デッキに移動していた場合、【エナチャージ２】をする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp and Duel.GetDeckMovedCount(tp)>=3 end)
  e1:SetOperation(aux.EnaChargeOp(2))
  c:RegisterEffect(e1)
end
