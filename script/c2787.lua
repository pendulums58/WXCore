-- WX15-071 折刀の円卓　ケイ
-- 【起】《ダウン》：対戦相手のパワー5000以下のシグニ１体を対象とし、それをバニッシュする。この能力はあなたの場に《ライズアイコン》を持つシグニがある場合にしか使用できない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCost(aux.SelfDownCost)
  e1:SetCondition(function(e,tp) return Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:HasRiseIcon() end,tp,LOCATION_SZONE,0,nil):GetCount()>0 end)
  e1:SetTarget(aux.BanishPowerTarget(5000))
  e1:SetOperation(aux.BanishOp)
  c:RegisterEffect(e1)
end
