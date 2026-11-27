-- WX12-Re05 ジェラシー・ゲイズ
-- 次の対戦相手のターンの間、対戦相手は手札からパワー12000以上のシグニを場に出せない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    -- [の間] 「次の対戦相手のターンの間」 패에서 파워 12000 이상 시그니를 낼 수 없다
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_PLAY)
    e1:SetTargetRange(0,LOCATION_HAND)
    e1:SetTarget(function(e,x) return x:IsSigni() and x:GetPower()>=12000 end)
    local now=Duel.GetTurnCount()
    e1:SetCondition(function() return Duel.GetTurnCount()==now+1 end)
    e1:SetReset(RESET_PHASE+PHASE_END,2)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e1)
end
