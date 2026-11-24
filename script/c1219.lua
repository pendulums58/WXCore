-- WD12-006 神出鬼没
-- このアーツを使用する際、手札から＜遊具＞のシグニを１枚捨ててもよい。そうした場合、このアーツの使用コストは《緑×2》減る。
-- あなたのエナゾーンから緑のシグニ１枚を対象とし、それを場に出す。
local s,id=GetID()
s.cut="{G}{G}"  -- 버리면 줄어드는 코스트
function s.initial_effect(c)
  local picked  -- 선언 때 고른 카드. 확정되면 코스트로 버린다
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetMinCost(function(e,tp,base) return Duel.ReduceCost(base,s.cut,math.min(1,s.hand(tp):GetCount())) end)
  e1:SetDeclare(function(e,tp)
    local base=Duel.GetUseCost()
    Duel.SetSelectCheck(function(g) return Duel.CanPayEna(tp,Duel.ReduceCost(base,s.cut,g:GetCount())) end)
    picked=Duel.SelectCards(tp,s.hand(tp),0,1)
    Duel.SetUseCost(Duel.ReduceCost(base,s.cut,picked:GetCount()))
  end)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SendToTrash(picked,REASON_COST+REASON_DISCARD)
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_GREEN) end,tp,LOCATION_ENA,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.PutOnField(tc,tp) end
  end)
  c:RegisterEffect(e1)
end
function s.hand(tp) return Duel.GetMatchingGroup(aux.ClassFilter(0,RACE_YUGU),tp,LOCATION_HAND,0,nil) end
