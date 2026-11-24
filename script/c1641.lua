-- WDK07-Y15 羅植　サンザカ
-- 【自】：このシグニがバニッシュされたとき、《白》《無》を支払ってもよい。そうした場合、このシグニをエナゾーンから場に出す。
local s,id=GetID()
function s.initial_effect(c)
  -- 이 시그니 자신을 코스트로 내면 낼 수 없다(FAQ 1)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BANISHED)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if not (h:IsLocation(LOCATION_ENA) and Duel.CanPayEna(tp,"{W}{C}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{W}{C}"),REASON_COST)
    if h:IsLocation(LOCATION_ENA) then Duel.PutOnField(h,tp) end
  end)
  c:RegisterEffect(e1)
end
