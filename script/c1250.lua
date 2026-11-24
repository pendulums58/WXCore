-- WD14-009 デビル・トゥ・デビル
-- あなたのエナゾーンから＜悪魔＞のシグニを好きな数対象とし、それらをトラッシュに置いてもよい。その後、この方法でトラッシュに置いたシグニ１枚につきあなたのトラッシュから＜悪魔＞のシグニ１枚を対象とし、それらを場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,aux.ClassFilter(0,RACE_AKUMA),tp,LOCATION_ENA,0,0,99,nil)
  end)
  -- 코스트로 낸 에나는 세지 않는다(FAQ 1). 원래 트래시에 있던 카드도 낼 수 있다(FAQ 2)
  e1:SetOperation(function(e,tp)
    local n=Duel.SendToTrash(Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil),REASON_EFFECT)
    n=math.min(n,Duel.GetMatchingGroup(aux.ClassFilter(0,RACE_AKUMA),tp,LOCATION_TRASH,0,nil):GetCount())  -- 「1장당 1장」이라 있는 만큼
    if n==0 then return end
    for tc in Duel.SelectTarget(tp,aux.ClassFilter(0,RACE_AKUMA),tp,LOCATION_TRASH,0,n,n,nil):Iter() do Duel.PutOnField(tc,tp) end
  end)
  c:RegisterEffect(e1)
end
