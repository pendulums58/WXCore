-- WDK04-006 いっしょにあーや！
-- 【常】：あなたのセンタールリグは以下の能力を得る。
-- 【自】：対戦相手のセンタールリグがアタックしたとき、対戦相手は偶数か奇数かを宣言する。あなたのデッキの上からシグニがめくれるまで公開する。この方法で公開されたシグニのレベルが宣言と異なる場合、そのアタックを無効にする。公開されたカードをシャッフルしてデッキの一番下に置く。
local s,id=GetID()
function s.initial_effect(c)
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  g:SetDescription(aux.Ability(id,1))
  g:SetCode(EVENT_ATTACK)
  g:SetRange(LOCATION_LRIG)
  g:SetCondition(function(e,tp,eg,ep) return ep~=tp and eg:GetFirst():IsLocation(LOCATION_LRIG) end)
  g:SetOperation(s.op)
  -- [の間] 【常】 센터 루리그가 얻는다. 그로우해도 계속된다(FAQ 1)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_GRANT)
  e1:SetRange(LOCATION_KEY)
  e1:SetTargetRange(LOCATION_LRIG,0)
  e1:SetLabelObject(g)
  c:RegisterEffect(e1)
end
-- 시그니가 나오지 않으면 무효가 되지 않고, 섞어서 덱으로(FAQ 3·4). 아무 레벨로나 칠 수 있으면 반대로 친다(FAQ 5)
function s.op(e,tp)
  local even=Duel.SelectOption(1-tp,aux.Stringid(id,0),aux.Stringid(id,1))==0
  local n,g,hit=0,nil,nil
  repeat
    n=n+1
    g=Duel.GetDecktopGroup(tp,n)
    hit=g:Filter(Card.IsSigni,nil):GetFirst()
  until hit or g:GetCount()<n
  if g:GetCount()==0 then return end
  Duel.RevealCards(g)
  if hit and (hit:HasKeyword(EFFECT_ANY_LEVEL) or (hit:GetLevel()%2==0)~=even) then Duel.NegateAttack() end
  Duel.SendToDeckBottom(g,true)
end
