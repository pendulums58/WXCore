-- WX08-017 日進月歩
-- ターン終了時まで、あなたのすべてのシグニのパワーを＋5000する。その後、ターン終了時まで、あなたのパワー30000以上のすべてのシグニは「【常】：このシグニは対戦相手のアーツの効果を受けない。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    -- [まで] 처리할 때 장에 있는 시그니
    for tc in Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):Iter() do aux.AddPower(e,tc,5000) end
    for tc in Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:GetPower()>=30000 end,tp,LOCATION_SZONE,0,nil):Iter() do
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_IMMUNE)
      e1:SetValue(function(e,sc,sp) return sp~=e:GetHandlerPlayer() and sc:IsType(TYPE_ARTS) end)
      e1:SetReset(RESET_PHASE+PHASE_END)
      tc:RegisterEffect(e1)
    end
  end)
  c:RegisterEffect(e1)
end
