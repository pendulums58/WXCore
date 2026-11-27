-- WX07-060 絶対の炎武
-- 対戦相手のパワー2000以下のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(aux.BanishPowerTarget(2000))
  e1:SetOperation(aux.BanishOp)
  c:RegisterEffect(e1)
end
