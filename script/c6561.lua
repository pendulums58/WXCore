-- WXK05-018 先制結界
-- 対戦相手のセンタールリグが白か黒の場合、このアーツの使用コストは《緑×2》になる。
-- あなたのエナゾーンから緑のシグニを２枚まで対象とし、それらを場に出す。それらの【出】能力は発動しない。【エナチャージ３】をする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_GREEN) end,tp,LOCATION_ENA,0,0,2,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    for x in Duel.GetTargets():Iter() do if x:IsRelateToEffect(e) then Duel.PutOnField(x,tp,true) end end
    Duel.EnaCharge(tp,3)
  end)
  c:RegisterEffect(e1)
  aux.SetCostBy(e1,function(e,tp,base) local oc=Duel.GetMatchingGroup(nil,tp,0,LOCATION_LRIG,nil):GetFirst() if oc and (oc:IsColor(COLOR_WHITE) or oc:IsColor(COLOR_BLACK)) then return "{G}{G}" end return base end)
end
