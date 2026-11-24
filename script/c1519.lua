-- WDK04-001 再来の駄姫　グズ子
-- 【自】：このルリグがアタックしたとき、あなたの場に《いっしょにあーや！》がいる場合、《黒》《黒》を支払ってもよい。そうした場合、このターン、対戦相手は手札から《ガードアイコン》を持つカードを追加で１枚捨てないかぎり【ガード】ができない。
-- 【出】：あなたのトラッシュからシグニ１枚を対象とし、それを手札に加える。
-- 【起】《ターン１回》《メインフェイズアイコン》《アタックフェイズアイコン》《黒×0》：あなたのデッキの一番上のカードをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp)
    if Duel.GetMatchingGroup(function(x) return x:IsCardName(1022) end,tp,LOCATION_KEY,0,nil):GetCount()==0 then return end
    if not (Duel.CanPayEna(tp,"{B}{B}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{B}{B}"),REASON_COST)
    -- [の間] 「このターン」
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_GUARD_EXTRA)
    e1:SetTargetRange(0,1)
    e1:SetValue(1)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetTiming(TIMING_MAIN+TIMING_ATTACK)
  e3:SetCountLimit(1)
  e3:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,1)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
  end)
  c:RegisterEffect(e3)
end
