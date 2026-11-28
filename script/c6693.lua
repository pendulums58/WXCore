-- WXK06-078 幻竜　ドラーミー
-- 【自】：あなたのメインフェイズの間、このカードが手札かデッキからトラッシュに置かれたとき、あなたのセンタールリグが＜ウリス＞の場合、【エナチャージ１】をしてもよい。そうした場合、このメインフェイズを終了する。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TO_TRASH)
  e1:SetCondition(function(e,tp) local h=e:GetHandler() return (h:IsPreviousLocation(LOCATION_HAND) or h:IsPreviousLocation(LOCATION_MDECK)) and Duel.GetTurnPlayer()==tp and Duel.GetPhase()==PHASE_MAIN and (function() local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:IsLrigType(LRIG_URITH) end)() end)
  e1:SetOperation(function(e,tp,eg)
    if Duel.SelectYesNo(tp) then Duel.EnaCharge(tp,1) Duel.EndMainPhase() end
  end)
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e9)
end
