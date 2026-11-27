-- WX16-033 ラスト・フェアエル
-- このスペルの使用コストは、あなたの場にある＜微菌＞のシグニ１体につき《黒×1》減り、対戦相手の場にある【ウィルス】１つにつき《黒×1》減る。
-- 対戦相手のすべてのシグニゾーンにある、すべてのカードをトラッシュに置きすべての【ウィルス】を取り除く。
-- ライフバースト：対戦相手のシグニ１体を対象とし、あなたのシグニ１体をバニッシュする。そうした場合、それをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  aux.SetCostBy(e1,function(e,tp,base) return Duel.ReduceCost(base,"{B}",Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_BIKIN)) end,tp,LOCATION_SZONE,0,nil):GetCount()+(function(p) local n=0 for _,z in ipairs(Duel.GetSigniZones(1-p)) do if Duel.HasVirus(z) then n=n+1 end end return n end)(tp)) end)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_SZONE+LOCATION_TRAP,nil)
    for x in Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil):Iter() do
      local ch=x:GetCharm()
      if ch then g:AddCard(ch) end
    end
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
    for _,z in ipairs(Duel.GetSigniZones(1-tp)) do Duel.RemoveVirus(z) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil)
    if g:GetCount()==0 or Duel.Banish(Duel.SelectCards(tp,g,1,1))==0 then return end
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToTrash(tc,REASON_EFFECT) end
  end)
  c:RegisterEffect(e2)
end
