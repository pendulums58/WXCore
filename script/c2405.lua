-- WX10-031 炎斬の巨刀
-- あなたの場に＜アーム＞と＜ウェポン＞のシグニがある場合、このスペルの使用コストは《白×1》《赤×1》減る。
-- 対象の対戦相手のシグニ１体を手札に戻し、対象の対戦相手のシグニ１体をバニッシュする。
-- ライフバースト：手札を１枚捨てる。その後、そのカードが＜アーム＞のシグニの場合、対戦相手のシグニ１体を対象とし、それを手札に戻す。＜ウェポン＞のシグニの場合、対戦相手のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  aux.SetCostBy(e1,function(e,tp,base)
    if Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_ARM)) end,tp,LOCATION_SZONE,0,nil):GetCount()>0 and Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_WEAPON)) end,tp,LOCATION_SZONE,0,nil):GetCount()>0 then return Duel.ReduceCost(Duel.ReduceCost(base,"{W}",1),"{R}",1) end
    return base
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    s.a=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    s.b=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x~=s.a end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
  end)
  e1:SetOperation(function(e,tp)
    if s.a and s.a:IsRelateToEffect(e) then Duel.SendToHand(s.a) end
    if s.b and s.b:IsRelateToEffect(e) then Duel.Banish(s.b) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
    if g:GetCount()==0 then return end
    local x=Duel.SelectCards(tp,g,1,1):GetFirst()
    if Duel.SendToTrash(x,REASON_EFFECT+REASON_DISCARD)==0 then return end
    if (function(x) return x:IsSigni() and (x:IsClass(0,RACE_ARM)) end)(x) then local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() if tc then Duel.SendToHand(tc) end end
    if (function(x) return x:IsSigni() and (x:IsClass(0,RACE_WEAPON)) end)(x) then local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() if tc then Duel.Banish(tc) end end
  end)
  c:RegisterEffect(e2)
end
