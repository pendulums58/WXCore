-- WX08-028 ＲＥＣＫＬＥＳＳ
-- このスペルの使用コストはあなたの場にある＜電機＞のシグニ１体か対戦相手の場にある凍結状態のシグニ１体につき《青×1》減る。
-- 対戦相手の凍結状態のシグニ１体を対象とし、それをバニッシュする。カードを３枚引く。
-- ライフバースト：対戦相手のシグニ１体を対象とし、それをダウンし凍結する。あなたの場に＜電機＞のシグニがある場合、代わりにそれをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  aux.SetCostBy(e1,function(e,tp,base) return Duel.ReduceCost(base,"{U}",Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_DENKI)) end,tp,LOCATION_SZONE,0,nil):GetCount()+Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsFrozen() end,tp,0,LOCATION_SZONE,nil):GetCount()) end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsFrozen() end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
    Duel.Draw(tp,3)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then if Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_DENKI)) end,tp,LOCATION_SZONE,0,nil):GetCount()>0 then Duel.Banish(tc) else Duel.Down(tc) Duel.Freeze(tc) end end
  end)
  c:RegisterEffect(e2)
end
