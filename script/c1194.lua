-- WD10-006 縦横無塵
-- このアーツを使用する際、手札から＜ウェポン＞のシグニを２枚まで捨ててもよい。このアーツの使用コストは、この方法で捨てたシグニ１枚につき《赤×2》《無×1》減る。
-- 対戦相手のパワー12000以下のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
s.weapon=aux.ClassFilter(0,RACE_WEAPON)
s.cut="{R}{R}{C}"  -- 버린 1장당 줄어드는 코스트
function s.initial_effect(c)
  local picked  -- 선언 때 고른 카드. 확정되면 코스트로 버린다(FAQ 1)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetMinCost(function(e,tp,base) return Duel.ReduceCost(base,s.cut,math.min(2,s.hand(tp):GetCount())) end)
  e1:SetDeclare(function(e,tp)
    local base=Duel.GetUseCost()
    Duel.SetSelectCheck(function(g) return Duel.CanPayEna(tp,Duel.ReduceCost(base,s.cut,g:GetCount())) end)
    picked=Duel.SelectCards(tp,s.hand(tp),0,2)
    Duel.SetUseCost(Duel.ReduceCost(base,s.cut,picked:GetCount()))
  end)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SendToTrash(picked,REASON_COST+REASON_DISCARD)
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and s.filter(tc) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e1)
end
function s.hand(tp) return Duel.GetMatchingGroup(s.weapon,tp,LOCATION_HAND,0,nil) end
function s.filter(c) return c:IsSigni() and c:GetPower()<=12000 end
