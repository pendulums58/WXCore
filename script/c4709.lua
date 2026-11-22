-- WXDi-D01-016 羅石　アシレン
-- 【自】：このシグニがアタックしたとき、このシグニのパワーが１５０００以上の場合、対戦相手は手札を１枚捨てる。
-- ２００００以上の場合、代わりに対戦相手の手札を１枚見ないで選び、捨てさせる。
-- ライフバースト：対戦相手のシグニ１体を対象とし、それをダウンし凍結する。カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(s.aop)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetTarget(s.lbtg)
  e2:SetOperation(s.lbop)
  c:RegisterEffect(e2)
end
function s.aop(e,tp)
  local power=e:GetHandler():GetPower()
  if power>=20000 then
    local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil)
    Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_EFFECT+REASON_DISCARD)
  elseif power>=15000 then
    Duel.SendToTrash(Duel.SelectDiscard(1-tp,1,1),REASON_EFFECT+REASON_DISCARD)
  end
end
function s.lbtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end  -- 시그니가 없어도 뽑는다(FAQ 1)
  Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
end
function s.lbop(e,tp)
  local tc=Duel.GetFirstTarget()
  if tc and tc:IsRelateToEffect(e) then
    Duel.Down(tc)
    Duel.Freeze(tc)
  end
  Duel.Draw(tp,1)
end
