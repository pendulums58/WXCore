-- WX04-034 ＳＨＯＲＴ
-- 以下３つから１つを選ぶ。
-- ①対戦相手のシグニ１体を対象とし、手札から名前の異なる＜原子＞のシグニを２枚捨てる。そうした場合、それをバニッシュする。
-- ②対戦相手のシグニ２体を対象とし、手札からそれぞれ名前の異なる＜原子＞のシグニを４枚捨てる。そうした場合、それらをバニッシュする。
-- ③対戦相手のシグニ３体を対象とし、手札からそれぞれ名前の異なる＜原子＞のシグニを６枚捨てる。そうした場合、それらをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))+1) end)
  -- 1·2·3체를 대상으로 하고 그 2배를 버린다. 처리할 때 버리지 않아도 된다(FAQ 1)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local n=e:GetLabel()
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,n,n,nil)
  end)
  e1:SetOperation(function(e,tp)
    local n=e:GetLabel()
    Duel.SetSelectCheck(function(g)
      if g:GetCount()==0 then return true end
      local seen={}
      for x in g:Iter() do
        if seen[x:GetCode()] then return false end
        seen[x:GetCode()]=true
      end
      return g:GetCount()==2*n
    end)
    local g=Duel.SelectDiscard(tp,0,2*n,function(x) return x:IsSigni() and (x:IsClass(0,RACE_GENSHI)) end)
    if g:GetCount()<2*n or Duel.SendToTrash(g,REASON_EFFECT+REASON_DISCARD)<2*n then return end
    local tg=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if tg:GetCount()>0 then Duel.Banish(tg) end
  end)
  c:RegisterEffect(e1)
end
