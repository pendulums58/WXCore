-- WD01-006 ロココ・バウンダリー
-- 対戦相手のシグニを２体まで対象とし、それらを手札に戻す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(s.tg)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
-- 「まで」는 0체부터(용어집: 対象 例２). 상대 시그니가 1체여도 쓸 수 있다(FAQ 3)
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,0,2,nil)
end
function s.op(e,tp)
  for tc in Duel.GetTargets():Iter() do
    if tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end
end
