-- WX01-073 落星の炎球
-- 対戦相手のパワー15000以下のシグニ１体を対象とし、それをバニッシュする。
-- ライフバースト：対戦相手のパワー10000以下のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(aux.BanishPowerTarget(15000))
  e1:SetOperation(aux.BanishOp)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetTarget(aux.BanishPowerTarget(10000))
  e2:SetOperation(aux.BanishOp)
  c:RegisterEffect(e2)
end
