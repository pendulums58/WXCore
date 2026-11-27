-- WX13-044 羅石　ビスマス
-- 【自】：対戦相手がアーツを使用したとき、このシグニをバニッシュしてもよい。そうした場合、対戦相手のすべてのシグニをバニッシュする。（そのアーツのあとでこの能力は発動する。そのアーツでこのシグニが場を離れていた場合この効果は何もしない）
local s,id=GetID()
function s.initial_effect(c)
  -- 그 아츠 뒤에(괄호)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_USE_CARD)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg,ep) return ep~=tp and eg:GetFirst():IsType(TYPE_ARTS) end)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if not (h:IsLocation(LOCATION_SZONE) and Duel.SelectYesNo(tp)) or Duel.Banish(h)==0 then return end
    local g=Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil)
    if g:GetCount()>0 then Duel.Banish(g) end
  end)
  c:RegisterEffect(e1)
end
