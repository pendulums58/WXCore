-- WX07-032 デス・パレード
-- このスペルを使用する際、あなたのアップ状態の＜悪魔＞のシグニを好きな数ダウンしてもよい。そうした場合、このスペルの使用コストはこの方法でダウンしたシグニ１体につき《黒×2》減る。
-- 対象のあなたのシグニ１体をバニッシュする。そうした場合、対象の対戦相手のシグニ１体をバニッシュする。その後、あなたのトラッシュから＜悪魔＞のシグニ１枚を対象とし、それを場に出し、あなたのトラッシュから＜悪魔＞のシグニ１枚を対象とし、それをライフクロスに加える。
-- ライフバースト：対戦相手のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
s.cut="{B}{B}"  -- 다운한 1체당 줄어드는 코스트
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
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    s.a=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
    s.b=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
  end)
  e1:SetOperation(function(e,tp)
    if s.a and s.a:IsRelateToEffect(e) and Duel.Banish(s.a)>0 and s.b and s.b:IsRelateToEffect(e) then Duel.Banish(s.b) end
    local x=Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_AKUMA)) end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    if x then Duel.PutOnField(x,tp) end
    local y=Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_AKUMA)) end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    if y then Duel.SendToLife(y) end
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
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e2)
end
function s.ups(tp) return Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_AKUMA)) end)(x) and x:IsUp() end,tp,LOCATION_SZONE,0,nil) end
