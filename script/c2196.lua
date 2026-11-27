-- WX07-026 大火の轢断
-- このスペルを使用する際、あなたのアップ状態の＜ウェポン＞のシグニを好きな数ダウンしてもよい。そうした場合、このスペルの使用コストはこの方法でダウンしたシグニ１体につき《赤×2》減る。
-- 対戦相手のライフクロスを２枚までクラッシュする。
-- ライフバースト：対戦相手のシグニを、パワーの合計が8000以下になるように好きな数対象とし、それらをバニッシュする。
local s,id=GetID()
s.cut="{R}{R}"  -- 다운한 1체당 줄어드는 코스트
function s.initial_effect(c)
  local picked  -- 선언 때 고른 시그니. 확정되면 코스트로 다운한다
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
  e1:SetOperation(function(e,tp)
    Duel.Crush(1-tp,2)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetSelectCheck(function(g)
      local n=0
      for x in g:Iter() do n=n+x:GetPower() end
      return n<=8000
    end)
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,0,3,nil)
  end)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.Banish(g) end
  end)
  c:RegisterEffect(e2)
end
function s.ups(tp) return Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_WEAPON)) end)(x) and x:IsUp() end,tp,LOCATION_SZONE,0,nil) end
