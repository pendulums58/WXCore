-- WDK09-014 コードメイズ　オタル
-- 【自】：あなたのアタックフェイズ開始時、このターンに対戦相手のカードがあなたの効果によって４枚以上デッキに移動していた場合、カードを１枚引く。
-- 【自】：このシグニがアタックしたとき、このターンに対戦相手のカードがあなたの効果によって１枚以上デッキに移動していた場合、カードを１枚引く。
-- ライフバースト：カードを１枚引く。
-- 루리그 덱으로 돌아간 카드는 세지 않는다(FAQ 1)
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg,ep) return ep==tp and Duel.GetDeckMovedCount(tp)>=4 end)
  e1:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetCondition(function(e,tp) return Duel.GetDeckMovedCount(tp)>=1 end)
  e2:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e3)
end
