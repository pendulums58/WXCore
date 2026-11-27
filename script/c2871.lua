-- WX16-056 血槍の円卓　ガラハッド
-- 【出】手札から＜武勇＞のシグニを１枚捨てる：対戦相手のパワー7000以下のシグニ１体を対象とし、それをバニッシュする。
-- 【出】手札から《ライズアイコン》を持つシグニを１枚捨てる：対戦相手のパワー10000以下のシグニ１体を対象とし、それをバニッシュする。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(aux.DiscardCost(1,function(x) return x:IsSigni() and (x:IsClass(0,RACE_BUYU)) end))
  e1:SetTarget(aux.BanishPowerTarget(7000))
  e1:SetOperation(aux.BanishOp)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetCost(aux.DiscardCost(1,function(x) return x:IsSigni() and x:HasRiseIcon() end))
  e2:SetTarget(aux.BanishPowerTarget(10000))
  e2:SetOperation(aux.BanishOp)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e3)
end
