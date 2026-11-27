-- WX15-010 君熾殉名
-- ターン終了時まで、あなたのすべての＜武勇＞のシグニは「【常】：このシグニが次にバニッシュされる場合、バニッシュされない。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    -- [まで] 처리할 때 장에 있는 ＜武勇＞
    for tc in Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_BUYU)) end,tp,LOCATION_SZONE,0,nil):Iter() do
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_BANISH_ONCE)
      e1:SetReset(RESET_PHASE+PHASE_END)
      tc:RegisterEffect(e1)
    end
  end)
  c:RegisterEffect(e1)
end
