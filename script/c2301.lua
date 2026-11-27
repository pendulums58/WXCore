-- WX08-055 轟砲　プラスボム
-- 【出】手札から《クロスアイコン》を持つシグニを１枚捨てる：対戦相手のパワー8000以下のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(aux.DiscardCost(1,function(x) return x:IsSigni() and x:HasCrossIcon() end))
  e1:SetTarget(aux.BanishPowerTarget(8000))
  e1:SetOperation(aux.BanishOp)
  c:RegisterEffect(e1)
end
