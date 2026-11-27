-- WX13-004 枯樹生華
-- 対戦相手のターンの間、このアーツの使用コストは《緑×1》《黒×1》《無×3》になる。
-- 対戦相手のシグニ１体を対象とし、それをバニッシュする。あなたはそれのレベル１につきあなたのデッキの一番上のカードをエナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  aux.SetCostBy(e1,function(e,tp,base) return Duel.GetTurnPlayer()~=tp and "{G}{B}{C}{C}{C}" or base end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then local lv=tc:GetLevel()
        if Duel.Banish(tc)>0 then Duel.EnaCharge(tp,lv) end end
  end)
  c:RegisterEffect(e1)
end
