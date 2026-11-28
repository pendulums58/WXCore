-- WXK04-047 血晶の収集
-- あなたのトラッシュから＜紅蓮＞のシグニ１枚を対象とし、それを手札に加える。その後、あなたのトラッシュからこの方法で手札に加えたシグニと同じ名前のシグニ１枚を対象とし、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_GUREN) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) or Duel.SendToHand(tc)==0 then return end
    local x=Duel.SelectTarget(tp,function(y) return y:IsSigni() and y:IsSameName(tc) end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    if x then Duel.SendToHand(x) end
  end)
  c:RegisterEffect(e1)
end
