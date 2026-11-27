-- WX20-004 一心轟体
-- このアーツを使用する際、手札から＜精武＞のシグニを２枚まで捨ててもよい。このアーツの使用コストは、この方法で捨てたシグニ１枚につき《赤×1》《無×1》減る。
-- 対戦相手のシグニを２体まで対象とし、それらをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsClass(SYS_SEIBU,0) end,tp,LOCATION_HAND,0,nil)
    local k=0
    if g:GetCount()>0 and Duel.SelectYesNo(tp) then
      local d=Duel.SelectCards(tp,g,1,2)
      k=d:GetCount()
      Duel.SendToTrash(d,REASON_COST+REASON_DISCARD)
    end
    local c=Duel.GetUseCost()
    for _=1,k do c=Duel.ReduceCost(c,"{R}",1) c=Duel.ReduceCost(c,"{C}",1) end
    Duel.SetUseCost(c)
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,0,2,nil)
  end)
  e1:SetOperation(function(e,tp)
    for x in Duel.GetTargets():Iter() do if x:IsRelateToEffect(e) then Duel.Banish(x) end end
  end)
  c:RegisterEffect(e1)
end
