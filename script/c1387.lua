-- WD23-031-A 超罠　バナナン
-- 【トラップアイコン】：対戦相手のシグニを２体まで対象とし、それらをダウンする。
-- （対戦相手のシグニがアタックしたとき、その正面にシグニがない場合、そこにある【トラップ】を表向きにし《トラップアイコン》を発動してもよい。その後トラッシュに置く）
-- ライフバースト：対戦相手のシグニを２体まで対象とし、それらをダウンする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_TRAP)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,0,2,nil)
  end)
  e1:SetOperation(function(e,tp)
    for tc in Duel.GetTargets():Iter() do
      if tc:IsRelateToEffect(e) then Duel.Down(tc) end
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,0,2,nil)
  end)
  e2:SetOperation(function(e,tp)
    for tc in Duel.GetTargets():Iter() do
      if tc:IsRelateToEffect(e) then Duel.Down(tc) end
    end
  end)
  c:RegisterEffect(e2)
end
