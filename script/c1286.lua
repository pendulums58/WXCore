-- WD16-018 コードアート　Ｆ・Ｍ・Ｓ
-- 【起】《ダウン》 手札から＜電機＞のシグニを１枚捨てる：対戦相手は手札を１枚捨てる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsUp() and Duel.GetMatchingGroup(aux.ClassFilter(0,RACE_DENKI),tp,LOCATION_HAND,0,nil):GetCount()>0 end
    Duel.Down(e:GetHandler())
    Duel.SendToTrash(Duel.SelectDiscard(tp,1,1,aux.ClassFilter(0,RACE_DENKI)),REASON_COST+REASON_DISCARD)
  end)
  e1:SetOperation(function(e,tp) s.disc(1-tp,1) end)
  c:RegisterEffect(e1)
end
-- 「手札をＮ枚捨てる」: 모자라면 있는 만큼
function s.disc(p,n)
  n=math.min(n,Duel.GetMatchingGroup(nil,p,LOCATION_HAND,0,nil):GetCount())
  if n>0 then Duel.SendToTrash(Duel.SelectDiscard(p,n,n),REASON_EFFECT+REASON_DISCARD) end
end
