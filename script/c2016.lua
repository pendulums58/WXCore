-- WX04-036 再誕
-- あなたの＜美巧＞のシグニを好きな数対象とし、それらをバニッシュする。その後、あなたのデッキからこの方法でバニッシュした数と同じ枚数の＜美巧＞のシグニを探して場に出し、デッキをシャッフルする。
-- ライフバースト：あなたのデッキの上からカードを３枚公開する。その中からすべての＜美巧＞のシグニを手札に加え、残りをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_BIKOU)) end,tp,LOCATION_SZONE,0,0,3,nil)
  end)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    local n=g:GetCount()>0 and Duel.Banish(g) or 0
    if n==0 then return end
    Duel.SetSelectCheck(function(sg) return Duel.CanPutAll(sg,tp) end)
    for x in aux.Search(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_BIKOU)) end,n):Iter() do Duel.PutOnField(x,tp) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,aux.RevealCount(tp,3))
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    local b=g:Filter(function(x) return x:IsSigni() and (x:IsClass(0,RACE_BIKOU)) end,nil)
    local rest=g:Filter(function(x) return not b:IsContains(x) end,nil)
    if b:GetCount()>0 then Duel.SendToHand(b) end
    if rest:GetCount()>0 then Duel.SendToTrash(rest,REASON_EFFECT) end
  end)
  c:RegisterEffect(e2)
end
