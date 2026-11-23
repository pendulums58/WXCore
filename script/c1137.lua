-- WD06-001 エルドラ＝マークⅣ´
-- 【自】：あなたのライフバーストが発動したとき、カードを１枚引く。
-- 【自】：あなたのライフクロスにカード１枚が加えられたとき、対戦相手のシグニ１体を対象とし、《青》《青》《青》を支払ってもよい。そうした場合、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_LIFEBURST)
  e1:SetRange(LOCATION_LRIG)
  e1:SetCondition(function(e,tp,eg,ep) return ep==tp end)
  e1:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e1)
  -- 1장마다 트리거한다. 패에서 더해져도(FAQ 2), 순서만 바꾼 것은 아니다(WD06-007 FAQ 2)
  -- 지불은 트리거한 뒤 처리할 때라 그 사이 에나에 간 카드로도 낼 수 있다(FAQ 4)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_LIFE_ADDED)
  e2:SetRange(LOCATION_LRIG)
  e2:SetCondition(function(e,tp,eg,ep) return ep==tp end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(s.op)
  c:RegisterEffect(e2)
end
function s.op(e,tp)
  local tc=Duel.GetFirstTarget()
  if not (tc and Duel.CanPayEna(tp,"{U}{U}{U}") and Duel.SelectYesNo(tp)) then return end
  Duel.SendToTrash(Duel.SelectEnaCost(tp,"{U}{U}{U}"),REASON_COST)
  if tc:IsRelateToEffect(e) then Duel.Banish(tc) end
end
