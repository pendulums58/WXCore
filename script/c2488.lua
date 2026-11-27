-- WX11-039 ラビリンス・ロマンス
-- このスペルの使用コストはあなたの場にある＜迷宮＞のシグニ１体につき《白×1》減る。
-- 対戦相手のすべてのシグニをデッキに戻し、対戦相手は自分のデッキをシャッフルする。その後、対戦相手は自分の手札からシグニを３枚まで場に出す。
-- ライフバースト：対戦相手のシグニ１体を対象とし、それをデッキに戻し、対戦相手は自分のデッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  aux.SetCostBy(e1,function(e,tp,base) return Duel.ReduceCost(base,"{W}",Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_MEIKYU)) end,tp,LOCATION_SZONE,0,nil):GetCount()) end)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil)
    if g:GetCount()>0 then Duel.SendToDeckShuffle(g,1-tp) end
    local h=Duel.SelectCards(1-tp,Duel.GetMatchingGroup(Card.IsSigni,1-tp,LOCATION_HAND,0,nil),0,3)
    for x in h:Iter() do Duel.PutOnField(x,1-tp) end
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
    if tc and tc:IsRelateToEffect(e) then Duel.SendToDeckShuffle(tc,1-tp) end
  end)
  c:RegisterEffect(e2)
end
