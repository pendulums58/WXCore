-- WD21-020 磊落の選択
-- あなたの＜宇宙＞のシグニ１体を対象とし、それをバニッシュする。そうした場合、あなたのデッキの上からシグニがめくれるまで公開し、公開したカードをシャッフルし、デッキの一番下に置く。
-- その後、この方法で公開したシグニがレベル１の場合、カードを１枚引く。レベル２の場合、あなたのデッキの一番上のカードをエナゾーンに置く。レベル３の場合、対戦相手は手札を１枚捨てる。レベル４以上の場合、あなたのトラッシュから＜宇宙＞のシグニ１枚を対象とし、それを手札に加える。
local s,id=GetID()
s.uchu=aux.ClassFilter(0,RACE_UCHU)  -- ＜宇宙＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,s.uchu,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
function s.op(e,tp)
  local tc=Duel.GetFirstTarget()
  if not (tc and tc:IsRelateToEffect(e) and Duel.Banish(tc)>0) then return end
  local n,g,hit=0,nil,nil
  repeat
    n=n+1
    g=Duel.GetDecktopGroup(tp,n)
    hit=g:Filter(Card.IsSigni,nil):GetFirst()
  until hit or g:GetCount()<n
  if g:GetCount()==0 then return end
  Duel.RevealCards(g)
  Duel.SendToDeckBottom(g,true)
  if not hit then return end  -- 시그니가 없으면 섞어서 끝(FAQ 1)
  local lv=aux.RefLevel(tp,hit)
  if lv==1 then
    Duel.Draw(tp,1)
  elseif lv==2 then
    Duel.EnaCharge(tp,1)
  elseif lv==3 then
    aux.Discard(1-tp,1)
  elseif lv>=4 then
    local x=Duel.SelectTarget(tp,s.uchu,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    if x then Duel.SendToHand(x) end
  end
end
