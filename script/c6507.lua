-- WXK04-051 コードイート　ネバアイス
-- 【自】《ターン１回》：あなたのシグニ１体に【アクセ】が付いたとき、カードを１枚引き、手札を１枚捨てる。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ACCE)
  e1:SetRange(LOCATION_SZONE+LOCATION_ACCE)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg) local h=eg:GetFirst():GetAcceHost() return h and h:GetControler()==tp end)
  e1:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,1)
    aux.Discard(tp,1)
  end)
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e9)
end
