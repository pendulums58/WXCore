-- WDK08-Y12 幻水　ダンクルテウス
-- 【自】：このカードがあなたの効果によって手札から公開されたとき、対戦相手のシグニ１体を対象とし、
--   《緑》《緑》《無》《無》を支払い、手札から《幻水　ダンクルテウス》を１枚捨ててもよい。そうした場合、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  -- 패에 있을 때 트리거하고 발동한다(FAQ 1)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_REVEALED_FROM_HAND)
  e1:SetRange(LOCATION_HAND)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return rp==tp end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
-- 「支払い…捨ててもよい。そうした場合」: 둘 다 할 수 있을 때만 고른다. 버리는 카드는 자신이어도 된다
function s.op(e,tp)
  local tc=Duel.GetFirstTarget()
  if not (tc and tc:IsRelateToEffect(e)) then return end
  local g=Duel.GetMatchingGroup(function(x) return x:IsSameName(e:GetHandler()) end,tp,LOCATION_HAND,0,nil)
  if g:GetCount()==0 or not Duel.CanPayEna(tp,"{G}{G}{C}{C}") or not Duel.SelectYesNo(tp) then return end
  Duel.SendToTrash(Duel.SelectEnaCost(tp,"{G}{G}{C}{C}"),REASON_COST)
  Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_COST+REASON_DISCARD)
  Duel.Banish(tc)
end
