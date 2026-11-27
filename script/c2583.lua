-- WX13-002 救済の冥者　ハナレ
-- 【自】：あなたのメインフェイズ開始時、あなたのトラッシュからレベル３以下の＜毒牙＞のシグニ１枚を対象とし、それを場に出す。ターン終了時、それを場からトラッシュに置く。
-- 【起】エクシード１：あなたの＜毒牙＞のシグニ１体を対象とし、それをアップする。
-- 【起】《メインフェイズアイコン》《アタックフェイズアイコン》エクシード３：あなたのデッキの上からカードを３枚公開する。その中から好きな数の＜毒牙＞のシグニを場に出し、残りをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_PHASE_START+PHASE_MAIN)
  e1:SetRange(LOCATION_LRIG)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.SelectTarget(tp,function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_DOKUGA)) end)(x) and x:GetLevel()<=3 end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    if not (tc and Duel.PutOnField(tc,tp)) then return end
    -- 「ターン終了時、それを場からトラッシュに置く」
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_TURN_END)
    e1:SetCountLimit(1)
    e1:SetReset(RESET_PHASE+PHASE_END)
    e1:SetOperation(function() if tc:IsLocation(LOCATION_SZONE) then Duel.SendToTrash(tc,REASON_EFFECT) end end)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetExceedCost(1)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_DOKUGA)) end,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Up(tc) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetExceedCost(3)
  e3:SetTiming(TIMING_MAIN+TIMING_ATTACK)
  e3:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,aux.RevealCount(tp,3))
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    for x in Duel.SelectCards(tp,g:Filter(function(x) return x:IsSigni() and (x:IsClass(0,RACE_DOKUGA)) end,nil),0,3):Iter() do Duel.PutOnField(x,tp) end
    local rest=g:Filter(function(c) return c:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToTrash(rest,REASON_EFFECT) end
  end)
  c:RegisterEffect(e3)
end
