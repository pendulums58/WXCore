-- WX17-Re01 シャボン・サクシード
-- あなたの＜天使＞のシグニ１体を対象とし、それをバニッシュする。そうした場合、あなたのデッキから＜天使＞のシグニ１枚を探して公開し、手札に加えるか場に出し、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI)) end,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) or Duel.Banish(tc)==0 then return end
    local x=aux.Search(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI)) end,1):GetFirst()
    if x then
      Duel.RevealCards(Group.CreateGroup(x))
      if Duel.SelectYesNo(tp) then Duel.PutOnField(x,tp) else Duel.SendToHand(x) end
    end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
end
