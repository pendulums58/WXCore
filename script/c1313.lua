-- WD20-013 具英の角測　＃ブンドキ＃
-- 【自】英知=４：このシグニがアタックしたとき、カードを１枚引く。（あなたの場にある＜英知＞のシグニのレベルの合計がちょうど４であるかぎり有効になる）
-- 【自】英知=６：このシグニがアタックしたとき、あなたのデッキの一番上のカードをエナゾーンに置く。（あなたの場にある＜英知＞のシグニのレベルの合計がちょうど６であるかぎり有効になる）
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetCondition(aux.EichiCon(4))
  e1:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetCondition(aux.EichiCon(6))
  e2:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e3)
end
