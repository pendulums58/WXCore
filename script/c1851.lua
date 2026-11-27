-- WX01-041 轟砲　オルドナンス
-- 【起】《ダウン》：対戦相手のパワー7000以下のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCost(aux.SelfDownCost)
  e1:SetTarget(aux.BanishPowerTarget(7000))
  e1:SetOperation(aux.BanishOp)
  c:RegisterEffect(e1)
end
