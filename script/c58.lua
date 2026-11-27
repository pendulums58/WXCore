-- WX02-066 豊潤
-- あなたの場にある＜空獣＞と＜地獣＞と＜植物＞のシグニ１体につきあなたのデッキの一番上のカードをエナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 처리할 때 센다(FAQ 2)
  e1:SetOperation(function(e,tp)
    local n=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_KUJU) or x:IsClass(0,RACE_CHIJU) or x:IsClass(0,RACE_SHOKUBUTSU)) end,tp,LOCATION_SZONE,0,nil):GetCount()
    if n>0 then Duel.EnaCharge(tp,n) end
  end)
  c:RegisterEffect(e1)
end
