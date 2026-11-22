-- WDK-F03-11 師の遊　ユキダルマ
-- 【自】《ターン１回》：あなたのシグニ１体が場から手札に戻ったとき、対戦相手のシグニ１体を対象とし、《白》を支払ってもよい。そうした場合、それを手札に戻す。
-- 【出】：このシグニがデッキから場に出た場合、カードを１枚引くか【エナチャージ１】をする。
-- ライフバースト：対戦相手のレベル４以下のシグニ１体を対象とし、それを手札に戻す。
local s,id=GetID()
function s.initial_effect(c)
  -- 자기 자신이 패로 돌아갈 때도 트리거한다(FAQ 2). 《白》를 내지 않아도 이 턴에는 다시 트리거하지 않는다(FAQ 1)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TO_HAND)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1)
  e1:SetCondition(s.retcon)
  e1:SetTarget(s.bouncetg)
  e1:SetOperation(s.retop)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_MDECK) end)
  e2:SetOperation(s.playop)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(s.lbtg)
  e3:SetOperation(s.bounceop)
  c:RegisterEffect(e3)
end
function s.retcon(e,tp,eg)
  local c=eg:GetFirst()
  return c:GetOwner()==tp and c:IsPreviousLocation(LOCATION_SZONE) and c:IsSigni()
end
function s.bouncetg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingTarget(Card.IsSigni,tp,0,LOCATION_SZONE,1,nil) end
  Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
end
function s.retop(e,tp)
  if not (Duel.CanPayEna(tp,"{W}") and Duel.SelectYesNo(tp)) then return end
  Duel.SendToTrash(Duel.SelectEnaCost(tp,"{W}"),REASON_COST)
  s.bounceop(e,tp)
end
function s.bounceop(e,tp)
  local tc=Duel.GetFirstTarget()
  if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
end
function s.playop(e,tp)
  if Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))==0 then
    Duel.Draw(tp,1)
  else
    Duel.EnaCharge(tp,1)
  end
end
function s.lv4(c) return c:IsSigni() and c:GetLevel()<=4 end
function s.lbtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.SelectTarget(tp,s.lv4,tp,0,LOCATION_SZONE,1,1,nil)
end
