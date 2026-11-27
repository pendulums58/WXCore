-- WX16-017 リセットラップ
-- あなたの【トラップ】と＜トリック＞のシグニを好きな数対象とし、それらを場から手札に加える。その後、この方法で手札に加えた【トラップ】１つにつき手札からカード１枚を【トラップ】としてあなたのシグニゾーンに設置する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsLocation(LOCATION_TRAP) or (function(x) return x:IsSigni() and (x:IsClass(0,RACE_TRICK)) end)(x) end,tp,LOCATION_TRAP+LOCATION_SZONE,0,0,99,nil)
  end)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    local traps=g:Filter(function(x) return x:IsLocation(LOCATION_TRAP) end,nil):GetCount()
    if g:GetCount()>0 then Duel.SendToHand(g) end
    for _=1,traps do
      local h=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
      if h:GetCount()==0 then break end
      Duel.SetTrap(Duel.SelectCards(tp,h,1,1):GetFirst(),tp)
    end
  end)
  c:RegisterEffect(e1)
end
