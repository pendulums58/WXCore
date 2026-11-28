-- PR-K068 祝福の五光（ウィクリスマスパーティー 参加賞）
-- このスペルの使用コストは対戦相手のコイン１枚につき《赤×1》減る。
-- 以下の２つから１つを選ぶ。
-- ①対戦相手のシグニ１体を対象とし、それをバニッシュする。そうした場合、カードを１枚引くか【エナチャージ１】をする。
-- ②カードを５枚引く。対戦相手はあなたの手札を２枚見ないで選び、あなたはそれらを捨てる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if e:GetLabel()==0 then Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil) end
  end)
  e1:SetOperation(function(e,tp)
    if e:GetLabel()==0 then
      local tc=Duel.GetFirstTarget()
      if not (tc and tc:IsRelateToEffect(e) and Duel.Banish(tc)>0) then return end
      if Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))==0 then Duel.Draw(tp,1) else Duel.EnaCharge(tp,1) end
    else
      Duel.Draw(tp,5)
      local h=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
      if h:GetCount()>0 then Duel.SendToTrash(Duel.SelectCards(1-tp,h,math.min(2,h:GetCount()),math.min(2,h:GetCount())),REASON_EFFECT+REASON_DISCARD) end
    end
  end)
  c:RegisterEffect(e1)
  aux.SetCostBy(e1,function(e,tp,base) return Duel.ReduceCost(base,"{R}",Duel.GetCoin(1-tp)) end)
end
