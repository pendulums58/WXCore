-- WX17-065 幻蟲　§タカアシ§
-- 【自】：このカードが手札からトラッシュに置かれたとき、対戦相手のシグニを２体まで対象とし、それらを凍結する。
-- （凍結されたシグニは次の自分のアップフェイズにアップしない）
-- ライフバースト：対戦相手のシグニを２体まで対象とし、それらをダウンし凍結する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TO_TRASH)
  e1:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_HAND) end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,0,2,nil)
  end)
  e1:SetOperation(function(e,tp)
    for x in Duel.GetTargets():Iter() do if x:IsRelateToEffect(e) then Duel.Freeze(x) end end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,0,2,nil)
  end)
  e2:SetOperation(function(e,tp)
    for x in Duel.GetTargets():Iter() do if x:IsRelateToEffect(e) then Duel.Down(x) Duel.Freeze(x) end end
  end)
  c:RegisterEffect(e2)
end
