-- WXK01-104 大罠　イシゴエ
-- 【自】：このカードがデッキからトラッシュに置かれたとき、あなたのメインフェイズの場合、このカードをトラッシュから場に出してもよい。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TO_TRASH)
  e1:SetCondition(function(e,tp) return e:GetHandler():IsPreviousLocation(LOCATION_MDECK) and Duel.GetTurnPlayer()==tp and Duel.GetPhase()==PHASE_MAIN end)
  e1:SetOperation(function(e,tp,eg)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_TRASH) and Duel.SelectYesNo(tp) then Duel.PutOnField(h,tp) end
  end)
  c:RegisterEffect(e1)
end
