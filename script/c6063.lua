-- WXEX1-29 幻視の大天使　ラミエル
-- 【自】：対戦相手のシグニ１体が場からトラッシュに置かれたとき、あなたのターンの場合、【エナチャージ１】をする。
-- 【自】：このシグニがアタックしたとき、あなたのセンタールリグと共通する色を持つ対戦相手のシグニ１体を対象とし、それをトラッシュに置く。
-- 【出】：対戦相手のシグニ１体を対象とし、あなたの場に＜天使＞のシグニが３体ある場合、それをトラッシュに置く。
-- ライフバースト：対戦相手のシグニ１体を対象とし、それをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TO_TRASH)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg)
    return Duel.GetTurnPlayer()==tp and eg:Filter(function(x) return x:IsSigni() and x:GetOwner()==1-tp and (x:GetPreviousLocation()&LOCATION_SZONE)~=0 end,nil):GetCount()>0
  end)
  e1:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    local lcol=lc and lc:GetColor() or 0
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:GetColor()&lcol)~=0 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToTrash(tc,REASON_EFFECT) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_ON_PLAY)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    if Duel.GetMatchingGroup(aux.ClassFilter(0,RACE_TENSHI),tp,LOCATION_SZONE,0,nil):GetCount()<3 then return end
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToTrash(tc,REASON_EFFECT) end
  end)
  c:RegisterEffect(e3)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e9:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToTrash(tc,REASON_EFFECT) end
  end)
  c:RegisterEffect(e9)
end
