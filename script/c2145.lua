-- WX06-024 シャボン・サドゥン
-- このスペルを使用する際、あなたのアップ状態の＜天使＞のシグニを好きな数ダウンしてもよい。このスペルの使用コストはこの方法でダウンしたシグニ１体につき《無×2》減る。
-- 対戦相手のシグニ１体を対象とし、それをトラッシュに置く。
-- ライフバースト：対戦相手のシグニ１体を対象とし、それをダウンする。あなたの場に＜天使＞のシグニがある場合、代わりにそれをトラッシュに置く。
local s,id=GetID()
s.cut="{C}{C}"  -- 다운한 1체당 줄어드는 코스트
function s.initial_effect(c)
  local picked  -- 선언 때 고른 천사. 확정되면 코스트로 다운한다(FAQ 1·4)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetMinCost(function(e,tp,base) return Duel.ReduceCost(base,s.cut,s.ups(tp):GetCount()) end)
  e1:SetDeclare(function(e,tp)
    local base=Duel.GetUseCost()
    Duel.SetSelectCheck(function(g) return Duel.CanPayEna(tp,Duel.ReduceCost(base,s.cut,g:GetCount())) end)
    picked=Duel.SelectCards(tp,s.ups(tp),0,5)
    Duel.SetUseCost(Duel.ReduceCost(base,s.cut,picked:GetCount()))
  end)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if picked and picked:GetCount()>0 then Duel.Down(picked,REASON_COST) end
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToTrash(tc,REASON_EFFECT) end
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
    if tc and tc:IsRelateToEffect(e) then if Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI)) end,tp,LOCATION_SZONE,0,nil):GetCount()>0 then Duel.SendToTrash(tc,REASON_EFFECT) else Duel.Down(tc) end end
  end)
  c:RegisterEffect(e2)
end
function s.ups(tp) return Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI)) end)(x) and x:IsUp() end,tp,LOCATION_SZONE,0,nil) end
