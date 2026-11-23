-- WDK08-Y13 幻水　カババン
-- 【自】：このカードがあなたの効果によって手札から公開されたとき、あなたのシグニ１体を対象とし、
--   手札から《幻水　カババン》を１枚捨ててもよい。そうした場合、ターン終了時まで、それのパワーを＋5000する。
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
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
-- 「捨ててもよい。そうした場合」. 버리는 카드는 자신이어도 된다
function s.op(e,tp)
  local tc=Duel.GetFirstTarget()
  if not (tc and tc:IsRelateToEffect(e)) then return end
  local g=Duel.GetMatchingGroup(function(x) return x:IsSameName(e:GetHandler()) end,tp,LOCATION_HAND,0,nil)
  if g:GetCount()==0 or not Duel.SelectYesNo(tp) then return end
  Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_COST+REASON_DISCARD)
  aux.AddPower(e,tc,5000)  -- [まで] ターン終了時まで
end
