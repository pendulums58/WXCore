-- WXK05-015 ドント・ラッシュ
-- 対戦相手のセンタールリグが緑か黒の場合、このアーツの使用コストは《青×2》になる。
-- 対戦相手のシグニを２体まで対象とし、それらをダウンし凍結する。
-- （凍結されたシグニは次の自分のアップフェイズにアップしない）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,0,2,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    for x in Duel.GetTargets():Iter() do if x:IsRelateToEffect(e) then Duel.Down(x) Duel.Freeze(x) end end
  end)
  c:RegisterEffect(e1)
  aux.SetCostBy(e1,function(e,tp,base) local oc=Duel.GetMatchingGroup(nil,tp,0,LOCATION_LRIG,nil):GetFirst() if oc and (oc:IsColor(COLOR_GREEN) or oc:IsColor(COLOR_BLACK)) then return "{U}{U}" end return base end)
end
