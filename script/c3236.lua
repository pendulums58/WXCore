-- WX22-011 一層の一掃　アン＝フォース
-- 【自】：あなたのアタックフェイズ開始時、対戦相手のシグニ１体を対象とし、あなたの場に緑と白の＜美巧＞のシグニがある場合、それを手札に戻す。
-- 【自】《ターン１回》：あなたの＜美巧＞のシグニ１体がバニッシュされたとき、あなたのデッキの一番上のカードをエナゾーンに置く。
-- 【起】《アタックフェイズアイコン》エクシード４：対戦相手のすべてのシグニを手札に戻す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_LRIG)
  e1:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local has=function(col) return Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_BIKOU)) end)(x) and x:IsColor(col) end,tp,LOCATION_SZONE,0,nil):GetCount()>0 end
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and has(COLOR_GREEN) and has(COLOR_WHITE) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_BANISHED)
  e2:SetRange(LOCATION_LRIG)
  e2:SetCountLimit(1)
  e2:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x:GetOwner()==tp and (function(x) return x:IsSigni() and (x:IsClass(0,RACE_BIKOU)) end)(x) end)
  e2:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetExceedCost(4)
  e3:SetTiming(TIMING_ATTACK)
  e3:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e3)
end
