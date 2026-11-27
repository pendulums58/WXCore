-- WX01-040 羅石　オリハルク
-- 【出】：対戦相手のパワー3000以下のシグニ１体を対象とし、それをバニッシュする。
-- ライフバースト：対戦相手のパワー5000以下のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(aux.BanishPowerTarget(3000))
  e1:SetOperation(aux.BanishOp)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetTarget(aux.BanishPowerTarget(5000))
  e2:SetOperation(aux.BanishOp)
  c:RegisterEffect(e2)
end
