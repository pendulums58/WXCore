-- WX13-012 立炎交差
-- 以下の２つから１つを選ぶ。
-- ①あなたのシグニ１体を対象とし、あなたのデッキから、それのクロス条件に含まれるすべてのシグニを１枚ずつ探して場に出し、デッキをシャッフルする。
-- ②対戦相手のシグニ１体を対象とし、あなたの場にクロス状態のシグニがある場合、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1))[1])
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if e:GetLabel()==0 then Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil) else Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil) end
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    if e:GetLabel()==1 then
      if Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsCross() end,tp,LOCATION_SZONE,0,nil):GetCount()>0 then Duel.Banish(tc) end
      return
    end
    for _,cid in ipairs(tc:GetCrossPartners()) do
      local x=aux.Search(tp,function(c) return c:IsCardName(cid) end,1):GetFirst()
      if x then Duel.PutOnField(x,tp) end
    end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
end
