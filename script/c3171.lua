-- WX21-004 ママ♥５
-- 【自】：あなたのメインフェイズ開始時、あなたのデッキの一番上のカードをエナゾーンに置く。その後、あなたのエナゾーンから＜英知＞のシグニを１枚まで対象とし、それを手札に加える。
-- 【自】《ターン１回》：アタックフェイズの間、あなたの＜英知＞のシグニが場を離れたとき、あなたのエナゾーンからそのシグニと同じレベルの＜英知＞のシグニを１枚まで対象とし、それをダウン状態で場に出す。
-- 【起】《ターン１回》《アタックフェイズアイコン》《コインアイコン》：対戦相手のシグニ１体を対象とし、手札から＜英知＞のシグニを１枚捨てる。そうした場合、それをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_PHASE_START+PHASE_MAIN)
  e1:SetRange(LOCATION_LRIG)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
  e1:SetOperation(function(e,tp)
    Duel.EnaCharge(tp,1)
    local x=Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_EICHI)) end,tp,LOCATION_ENA,0,0,1,nil):GetFirst()
    if x then Duel.SendToHand(x) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_LEAVE_FIELD)
  e2:SetRange(LOCATION_LRIG)
  e2:SetCountLimit(1)
  e2:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return Duel.GetPhase()==PHASE_ATTACK and x:GetOwner()==tp and (function(x) return x:IsSigni() and (x:IsClass(0,RACE_EICHI)) end)(x) end)
  e2:SetOperation(function(e,tp,eg)
    local lv=eg:GetFirst():GetLevel()
    local x=Duel.SelectTarget(tp,function(c) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_EICHI)) end)(c) and c:GetLevel()==lv end,tp,LOCATION_ENA,0,0,1,nil):GetFirst()
    if x then Duel.PutOnField(x,tp,false,true) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetCountLimit(1)
  e3:SetCoinCost(1)
  e3:SetTiming(TIMING_ATTACK)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_EICHI)) end,tp,LOCATION_HAND,0,nil)
    if g:GetCount()==0 or Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_EFFECT+REASON_DISCARD)==0 then return end
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToTrash(tc,REASON_EFFECT) end
  end)
  c:RegisterEffect(e3)
end
