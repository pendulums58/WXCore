-- WXK07-068 羅原　Pab
-- 【自】：このシグニがコストか効果によって場からトラッシュに置かれたとき、《赤》を支払ってもよい。そうした場合、カードを１枚引く。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TO_TRASH)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r) return e:GetHandler():IsPreviousLocation(LOCATION_SZONE) and (r&(REASON_EFFECT|REASON_COST))~=0 and (r&REASON_BANISH)==0 end)
  e1:SetOperation(function(e,tp,eg)
    if not (Duel.CanPayEna(tp,"{R}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{R}"),REASON_COST)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e9)
end
