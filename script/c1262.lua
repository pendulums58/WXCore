-- WD15-001 百折不灯　遊月・肆
-- 【自】：あなたの＜龍獣＞のシグニ１体が場に出たとき、対戦相手のシグニ１体を対象とし、《赤》《赤》を支払ってもよい。そうした場合、それをバニッシュする。
-- 【出】：対戦相手のシグニ１体を対象とし、あなたのデッキの上からカードを２枚トラッシュに置く。その中に＜龍獣＞のシグニが１枚以上ある場合、それをバニッシュする。２枚以上ある場合、ターン終了時まで、このルリグは【ダブルクラッシュ】を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetRange(LOCATION_LRIG)
  e1:SetCondition(function(e,tp,eg)
    local x=eg:GetFirst()
    return x and x:IsSigni() and x:IsClass(0,RACE_RYUJU) and x:GetControler()==tp
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and Duel.CanPayEna(tp,"{R}{R}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{R}{R}"),REASON_COST)
    if tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e1)
  -- 2장이면 둘 다 한다(FAQ 2). 덱이 1장이면 그 1장만(FAQ 3)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,2)
    Duel.SendToTrash(g,REASON_EFFECT)
    local n=g:Filter(function(x) return x:IsLocation(LOCATION_TRASH) and x:IsSigni() and x:IsClass(0,RACE_RYUJU) end,nil):GetCount()
    local tc,h=Duel.GetFirstTarget(),e:GetHandler()
    if n>=1 and tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
    if n>=2 and h:IsLocation(LOCATION_LRIG) then s.double(e,h) end
  end)
  c:RegisterEffect(e2)
end
-- [まで] ターン終了時まで
function s.double(e,tc)
  local e1=Effect.CreateEffect(e:GetHandler())
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_DOUBLE_CRUSH)
  e1:SetReset(RESET_PHASE+PHASE_END)
  tc:GrantEffect(e1)
end
