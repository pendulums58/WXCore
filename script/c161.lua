-- WX01-001 太陽の巫女　タマヨリヒメ
-- 【起】《白》手札から白のシグニを１枚捨てる：対戦相手のシグニ１体を対象とし、それを手札に戻す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_LRIG)
  e1:SetEnaCost("{W}")
  -- 【マルチエナ】는 에나에서만이라 패의 카드는 그 색이다(FAQ 2)
  e1:SetCost(aux.DiscardCost(1,function(x) return x:IsSigni() and x:IsColor(COLOR_WHITE) end))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e1)
end
