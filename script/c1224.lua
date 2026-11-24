-- WD12-011 参ノ遊　シーソー
-- 【自】《ターン１回》：あなたのシグニ１体が効果によって場に出たとき、カードを１枚引く。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetCondition(s.con)
  e1:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e2)
end
function s.con(e,tp,eg,ep,ev,re,r)
  local x=eg:GetFirst()
  return x and x:IsSigni() and x:GetControler()==tp and (r&REASON_EFFECT)~=0
end
