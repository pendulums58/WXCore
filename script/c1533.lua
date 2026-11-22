-- WDK-F03-07 クリン・バウンダリー
-- あなたの＜遊具＞のシグニを２体まで対象とし、それらを手札に戻す。その後、この方法で手札に戻したシグニ１体につき対戦相手のシグニ１体を対象とし、それらを手札に戻す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(s.tg)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
function s.toy(c) return c:IsSigni() and c:IsClass("遊具") end
-- 상대 시그니가 없어도 쓸 수 있다. 내 시그니는 0~2체(FAQ 1·2)
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.SelectTarget(tp,s.toy,tp,LOCATION_SZONE,0,0,2,nil)
end
function s.op(e,tp)
  local n=0
  for tc in Duel.GetTargets():Iter() do
    if tc:IsRelateToEffect(e) and Duel.SendToHand(tc)>0 and tc:IsLocation(LOCATION_HAND) then n=n+1 end
  end
  if n==0 then return end
  local g=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,n,n,nil)
  if g:GetCount()>0 then Duel.SendToHand(g) end
end
