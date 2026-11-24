-- WD12-009 肆ノ遊　ジャグジム
-- 【自】：あなたのシグニ１体が効果によって場に出たとき、対戦相手のパワー15000以上のシグニ１体を対象とし、《緑》を支払ってもよい。そうした場合、それをバニッシュする。
-- 【自】：このシグニがあなたのエナゾーンから手札に移動したとき、あなたの手札からレベル４のシグニ１枚をダウン状態で場に出してもよい。
-- ライフバースト：対戦相手のパワー10000以上のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(s.con)
  e1:SetTarget(s.tg(15000))
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and Duel.CanPayEna(tp,"{G}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{G}"),REASON_COST)
    if tc:IsRelateToEffect(e) and tc:GetPower()>=15000 then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e1)
  -- 이 카드 자신도 낼 수 있다(FAQ)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_TO_HAND)
  e2:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_ENA) end)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:GetLevel()==4 end,tp,LOCATION_HAND,0,nil)
    local tc=Duel.SelectCards(tp,g,0,1):GetFirst()
    if tc and Duel.PutOnField(tc,tp) then Duel.Down(tc) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(s.tg(10000))
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:GetPower()>=10000 then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e3)
end
function s.con(e,tp,eg,ep,ev,re,r)
  local x=eg:GetFirst()
  return x and x:IsSigni() and x:GetControler()==tp and (r&REASON_EFFECT)~=0
end
function s.tg(pw)
  return function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()>=pw end,tp,0,LOCATION_SZONE,1,1,nil)
  end
end
