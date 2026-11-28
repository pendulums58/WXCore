-- WXK07-018 自縄自縛
-- このアーツの使用コストはあなたの場にあるシグニ１体につき《緑×1》減る。
-- あなたのシグニ１体と対戦相手のシグニ１体を対象とし、それらをそれぞれのチェックゾーンに置き、それらをダウン状態で場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp,eg)
    local a=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
    local b=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    for _,x in ipairs({a,b}) do
      if x and Duel.SendToCheck(x)>0 then Duel.PutOnField(x,x:GetOwner(),false,true) end
    end
  end)
  c:RegisterEffect(e1)
  aux.SetCostBy(e1,function(e,tp,base) return Duel.ReduceCost(base,"{G}",Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):GetCount()) end)
end
