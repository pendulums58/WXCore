-- WX10-027 リング・ドロー
-- カードを１枚引く。
-- 【自】：あなたのレゾナ１体が場に出たとき、《無》を支払ってもよい。そうした場合、このカードをあなたのルリグトラッシュからルリグデッキに戻す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetRange(LOCATION_LTRASH)
  e2:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x:GetControler()==tp and x:IsType(TYPE_RESONA) end)
  e2:SetOperation(function(e,tp)
    if not (Duel.CanPayEna(tp,"{C}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{C}"),REASON_COST)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_LTRASH) then Duel.SendToLrigDeck(h) end
  end)
  c:RegisterEffect(e2)
end
