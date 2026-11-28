-- WXK08-059 コードＶＬ　轟京子
-- 【自】：対戦相手のターンの間、このシグニがバニッシュされたとき、あなたの手札からレベル１の＜電機＞のシグニ１枚を場に出してもよい。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BANISHED)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()~=tp end)
  e1:SetOperation(function(e,tp,eg)
    local h=Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_DENKI) end)(x) and x:GetLevel()==1 end,tp,LOCATION_HAND,0,nil)
    if h:GetCount()>0 and Duel.SelectYesNo(tp) then Duel.PutOnField(Duel.SelectCards(tp,h,1,1):GetFirst(),tp) end
  end)
  c:RegisterEffect(e1)
end
