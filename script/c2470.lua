-- WX11-015 絶体絶滅
-- あなたのセンタールリグが＜花代＞の場合、このアーツの使用コストは《赤×1》減る。
-- あなたは手札をすべて捨てる。その後、対戦相手のシグニ１体を対象とし、それをバニッシュする。あなたがこの方法で手札を３枚以上捨てた場合、追加で対戦相手のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  aux.SetCostBy(e1,function(e,tp,base) return (function() local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:IsLrigType(LRIG_HANAYO) end)() and Duel.ReduceCost(base,"{R}",1) or base end)
  e1:SetOperation(function(e,tp)
    local h=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
    local n=h:GetCount()>0 and Duel.SendToTrash(h,REASON_EFFECT+REASON_DISCARD) or 0
    local a=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if a then Duel.Banish(a) end
    if n>=3 then
      local b=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if b then Duel.Banish(b) end
    end
  end)
  c:RegisterEffect(e1)
end
