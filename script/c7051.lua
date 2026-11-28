-- WXK10-077 水壺の蒼天　エウロス
-- 【出】手札から＜天使＞のシグニを１枚捨てる：カードを１枚引く。
-- 【自】：このカードが手札からトラッシュに置かれたとき、《青》を支払ってもよい。そうした場合、カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(aux.DiscardCost(1,function(x) return x:IsSigni() and x:IsClass(0,RACE_TENSHI) end))
  e1:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_TO_TRASH)
  e2:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_HAND) end)
  e2:SetOperation(function(e,tp,eg)
    if not (Duel.CanPayEna(tp,"{U}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{U}"),REASON_COST)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e2)
end
