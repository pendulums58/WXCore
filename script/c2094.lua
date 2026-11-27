-- WX05-032 弩砲　アヴェンジャー
-- 【起】手札から＜ウェポン＞のシグニを１枚捨てる：対戦相手のパワー8000以下のシグニ１体を対象とし、それをバニッシュする。
-- 【起】手札から＜ウェポン＞のシグニを３枚捨てる：対戦相手のライフクロス１枚をクラッシュする。この効果でクラッシュされたカードのライフバーストは発動しない。
-- ライフバースト：対戦相手のパワー10000以下のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCost(aux.DiscardCost(1,function(x) return x:IsSigni() and (x:IsClass(0,RACE_WEAPON)) end))
  e1:SetTarget(aux.BanishPowerTarget(8000))
  e1:SetOperation(aux.BanishOp)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCost(aux.DiscardCost(3,function(x) return x:IsSigni() and (x:IsClass(0,RACE_WEAPON)) end))
  e2:SetOperation(function(e,tp)
    Duel.Crush(1-tp,1,false,true)
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(aux.BanishPowerTarget(10000))
  e3:SetOperation(aux.BanishOp)
  c:RegisterEffect(e3)
end
