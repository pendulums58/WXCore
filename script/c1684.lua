-- WDK09-012 コードメイズ　パブロペ
-- 【起】《青》《青》《ダウン》：対戦相手のシグニ１体を対象とし、それをデッキの上から三番目に置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetRange(LOCATION_SZONE)
  e1:SetEnaCost("{U}{U}")
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsUp() end
    Duel.Down(e:GetHandler())
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  -- 덱이 1장이면 맨 아래에(FAQ 1)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToDeckPosition(tc,3) end
  end)
  c:RegisterEffect(e1)
end
