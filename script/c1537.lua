-- WDK-F03-12 師の遊　ケロパッチン
-- 【出】《白》他のシグニ１体を場からデッキの一番上に置く：対戦相手のシグニ１体を対象とし、それを手札に戻す。
local s,id=GetID()
function s.initial_effect(c)
  -- 코스트가 있으면 내지 않고 발동하지 않을 수 있다(FAQ 1). 상대 시그니가 없어도 쓸 수 있다(FAQ 2)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{W}")
  e1:SetCost(s.cost)
  e1:SetTarget(s.tg)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
function s.other(c,self) return c:IsSigni() and c~=self end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
  local g=Duel.GetMatchingGroup(s.other,tp,LOCATION_SZONE,0,nil,e:GetHandler())
  if chk==0 then return g:GetCount()>0 end
  Duel.SendToDeckPosition(Duel.SelectCards(tp,g,1,1),1)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
end
function s.op(e,tp)
  local tc=Duel.GetFirstTarget()
  if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
end
