-- WX18-018 凶終隙末
-- 対戦相手のセンタールリグが白か黒の場合、このアーツの使用コストは《緑×2》になる。
-- 対戦相手のパワー12000以上のシグニを２体まで対象とし、それらをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  aux.SetCostBy(e1,function(e,tp,base) if (function() local lc=Duel.GetMatchingGroup(nil,tp,0,LOCATION_LRIG,nil):GetFirst() return lc and (lc:IsColor(COLOR_WHITE) or lc:IsColor(COLOR_BLACK)) end)() then return "{G}{G}" end return base end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()>=12000 end,tp,0,LOCATION_SZONE,0,2,nil)
  end)
  e1:SetOperation(function(e,tp)
    for tc in Duel.GetTargets():Iter() do if tc:IsRelateToEffect(e) then Duel.Banish(tc) end end
  end)
  c:RegisterEffect(e1)
end
