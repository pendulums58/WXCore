-- WD02-015 轟音の火柱
-- 対戦相手のパワー5000以下のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(aux.BanishPowerTarget(5000))
  e1:SetOperation(aux.BanishOp)
  c:RegisterEffect(e1)
end
-- 지금 파워를 본다(FAQ 1)
