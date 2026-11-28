-- WXK08-057 コードＶＬ　矢車りね
-- 【出】：対戦相手のシグニ１体を対象とし、ターン終了時まで、それは能力を失う。あなたの登録者数が８０万人を達成している場合、代わりにターン終了時まで、対戦相手のすべてのシグニは能力を失う。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local g=Duel.GetSubscribers(tp)>=80 and Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil) or Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    for x in g:Iter() do
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_LOSE_ABILITY)
      e1:SetReset(RESET_PHASE+PHASE_END)
      x:GrantEffect(e1)
    end
  end)
  c:RegisterEffect(e1)
end
