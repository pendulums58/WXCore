-- WX16-047 羅菌　クロカビ
-- 【自】：対戦相手のアタックフェイズ開始時、ターン終了時まで、対戦相手の感染状態のすべてのシグニは「【常】：可能ならばアタックしなければならない。」を得る。
-- （この能力はアタックフェイズにアーツや能力を使用する前に発動する）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()~=tp end)
  e1:SetOperation(function(e,tp)
    -- [まで] 그때 감염 상태인 시그니
    for tc in Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsInfected() end,tp,0,LOCATION_SZONE,nil):Iter() do
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_MUST_ATTACK)
      e1:SetReset(RESET_PHASE+PHASE_END)
      tc:RegisterEffect(e1)
    end
  end)
  c:RegisterEffect(e1)
end
