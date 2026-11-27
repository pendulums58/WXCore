-- WX21-059 ＬＯＵＰＥ
-- あなたの＜原子＞のシグニ２体を対象とし、それらをバニッシュする。この方法でシグニを２体バニッシュした場合、あなたのデッキからバニッシュしたシグニのレベルの合計と同じレベルの＜原子＞のシグニ１枚を探して場に出し、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_GENSHI)) end,tp,LOCATION_SZONE,0,2,2,nil)
  end)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()<2 then return end
    local sum=0
    for x in g:Iter() do sum=sum+x:GetLevel() end
    if Duel.Banish(g)<2 then return end
    local x=aux.Search(tp,function(c) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_GENSHI)) end)(c) and c:GetLevel()==sum end,1):GetFirst()
    if x then Duel.PutOnField(x,tp) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
end
