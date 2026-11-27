-- WX02-032 羅石　オパーラル
-- 【出】手札から＜鉱石＞か＜宝石＞のシグニを１枚捨てる：パワー7000以下のシグニ１体を対象とし、それをバニッシュする。
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(aux.DiscardCost(1,function(x) return x:IsSigni() and (x:IsClass(0,RACE_KOUSEKI) or x:IsClass(0,RACE_HOUSEKI)) end))
  -- 「対戦相手の」가 없으니 내 시그니도 된다
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=7000 end,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(aux.BanishOp)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e2)
end
