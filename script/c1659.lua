-- WDK08-L17 紅蓮の使い魔　セルディッド
-- 【自】《ターン１回》：あなたのシグニ１体が血晶武装状態になったとき、カードを１枚引き、手札を１枚捨てる。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  -- 이미 血晶武装状態인 시그니를 다시 血晶武装해도 트리거하지 않는다(FAQ 3)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BLOOD_ARMED)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg,ep) return ep==tp end)
  e1:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
    Duel.SendToTrash(Duel.SelectDiscard(tp,1,1),REASON_EFFECT+REASON_DISCARD)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e2)
end
