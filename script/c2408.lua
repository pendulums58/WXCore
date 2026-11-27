-- WX10-035 光輝
-- このターン、あなたのシグニ１体がアタックしたとき、あなたのデッキの一番上のカードをエナゾーンに置く。
-- ライフバースト：あなたの場にあるシグニの数に１を加えた枚数のカードをデッキの上からエナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    -- [の間] 「このターン」
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_ATTACK)
    e1:SetCondition(function(e2,tp2,eg) local x=eg:GetFirst() return x:GetControler()==tp and x:IsSigni() end)
    e1:SetOperation(function() Duel.EnaCharge(tp,1) end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    Duel.EnaCharge(tp,Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):GetCount()+1)
  end)
  c:RegisterEffect(e2)
end
