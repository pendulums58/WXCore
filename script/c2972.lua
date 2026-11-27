-- WX18-012 燐気応変
-- 対戦相手のセンタールリグが青か緑の場合、このアーツの使用コストは《赤×2》になる。
-- 対戦相手のパワー10000以下のシグニを２体まで対象とし、それらをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  aux.SetCostBy(e1,function(e,tp,base) if (function() local lc=Duel.GetMatchingGroup(nil,tp,0,LOCATION_LRIG,nil):GetFirst() return lc and (lc:IsColor(COLOR_BLUE) or lc:IsColor(COLOR_GREEN)) end)() then return "{R}{R}" end return base end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=10000 end,tp,0,LOCATION_SZONE,0,2,nil)
  end)
  e1:SetOperation(function(e,tp)
    for tc in Duel.GetTargets():Iter() do if tc:IsRelateToEffect(e) then Duel.Banish(tc) end end
  end)
  c:RegisterEffect(e1)
end
