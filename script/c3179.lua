-- WX21-014 千差万別
-- 対戦相手のシグニ１体を対象とし、それをエナゾーンに置く。それが赤か青のシグニの場合、追加であなたのデッキの一番上のカードをライフクロスに加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then local hit=tc:IsColor(COLOR_RED) or tc:IsColor(COLOR_BLUE)
        Duel.SendToEna(tc)
        if hit then local x=Duel.GetDecktopGroup(tp,1):GetFirst() if x then Duel.SendToLife(x) end end end
  end)
  c:RegisterEffect(e1)
end
