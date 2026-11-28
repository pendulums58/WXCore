-- WXK05-052 羅植　クレマチス
-- 【出】：対戦相手のシグニを２体まで対象とし、このシグニと同じシグニゾーンに【シード】がある場合、次のターンの間、それらは「【常】：アタックできない。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,0,2,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local h=e:GetHandler()
    local z=h:GetZone()
    if not (z and Duel.GetMatchingGroup(function(x) return x:GetZone()==z end,tp,LOCATION_SEED,0,nil):GetCount()>0) then return end
    local now=Duel.GetTurnCount()
    for tc in Duel.GetTargets():Iter() do
      if tc:IsRelateToEffect(e) then
        -- [まで] 「次のターンの間」
        local e1=Effect.CreateEffect(h)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CANNOT_ATTACK)
        e1:SetCondition(function() return Duel.GetTurnCount()==now+1 end)
        e1:SetReset(RESET_PHASE+PHASE_END,2)
        tc:GrantEffect(e1)
      end
    end
  end)
  c:RegisterEffect(e1)
end
