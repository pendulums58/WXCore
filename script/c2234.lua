-- WX07-065 ＦＲＥＥＺＥ　ＴＨＲＯＵＧＨ
-- このスペルの使用コストは対戦相手の場にある凍結状態のシグニ１体につき《青×1》減る。
-- ターン終了時まで、あなたのすべてのシグニは「【常】：このシグニの正面のシグニが凍結状態であるかぎり、【アサシン】を持つ。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  aux.SetCostBy(e1,function(e,tp,base) return Duel.ReduceCost(base,"{U}",Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsFrozen() end,tp,0,LOCATION_SZONE,nil):GetCount()) end)
  e1:SetOperation(function(e,tp)
    -- [まで] 처리할 때 장에 있는 시그니. 【アサシン】는 정면이 동결된 동안만
    for tc in Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):Iter() do
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_ASSASSIN)
      e1:SetCondition(function(e) local f=e:GetHandler():GetFrontCard() return f and f:IsFrozen() end)
      e1:SetReset(RESET_PHASE+PHASE_END)
      tc:RegisterEffect(e1)
    end
  end)
  c:RegisterEffect(e1)
end
