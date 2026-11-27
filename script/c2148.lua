-- WX06-027 幻竜　ブラザウス
-- 【出】手札から＜龍獣＞のシグニを１枚捨てる：対戦相手のパワー8000以下のシグニ１体を対象とし、それをバニッシュする。この能力は対戦相手のエナゾーンにあるカードが４枚以下の場合にしか使用できない。
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(aux.DiscardCost(1,function(x) return x:IsSigni() and (x:IsClass(0,RACE_RYUJU)) end))
  e1:SetCondition(function(e,tp) return Duel.GetMatchingGroup(nil,tp,0,LOCATION_ENA,nil):GetCount()<=4 end)
  e1:SetTarget(aux.BanishPowerTarget(8000))
  e1:SetOperation(aux.BanishOp)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e2)
end
