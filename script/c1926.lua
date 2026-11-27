-- WX02-038 幻獣　キジ
-- 【出】手札から＜空獣＞か＜地獣＞のシグニを１枚捨てる：あなたのデッキの上からカードを２枚エナゾーンに置く。
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(aux.DiscardCost(1,function(x) return x:IsSigni() and (x:IsClass(0,RACE_KUJU) or x:IsClass(0,RACE_CHIJU)) end))
  e1:SetOperation(aux.EnaChargeOp(2))
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e2)
end
