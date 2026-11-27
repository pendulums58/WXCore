-- WX04-050 非可視の現実　キュビ
-- 【起】《ダウン》：あなたのデッキを上から＜美巧＞のシグニがめくれるまで公開する。その後、そのシグニを手札に加え、公開された他のカードをシャッフルしてデッキの一番下に置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCost(aux.SelfDownCost)
  e1:SetOperation(function(e,tp)
    local n,g,hit=0,nil,nil
    repeat
      n=n+1
      g=Duel.GetDecktopGroup(tp,n)
      hit=g:Filter(function(x) return x:IsSigni() and (x:IsClass(0,RACE_BIKOU)) end,nil):GetFirst()
    until hit or g:GetCount()<n
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    if hit then Duel.SendToHand(hit) end
    local rest=g:Filter(function(x) return x~=hit end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(rest,true) end
  end)
  c:RegisterEffect(e1)
end
