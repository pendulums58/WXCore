-- WXK01-055 魔海の船員　ティーチ
-- 【自】：このカードが手札からトラッシュに置かれたとき、あなたの手札が２枚以下であなたのメインフェイズの場合、このシグニをトラッシュから場に出してもよい。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TO_TRASH)
  e1:SetCondition(function(e,tp) return e:GetHandler():IsPreviousLocation(LOCATION_HAND) and Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()<=2 and Duel.GetTurnPlayer()==tp and Duel.GetPhase()==PHASE_MAIN end)
  e1:SetOperation(function(e,tp,eg)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_TRASH) and Duel.SelectYesNo(tp) then Duel.PutOnField(h,tp) end
  end)
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e9)
end
