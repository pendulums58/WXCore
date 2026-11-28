-- SPK01-05 中装　カンショウ・バクヤ（パーティーパックVol.2）
-- 【自】：このシグニがライズされたとき、対戦相手のパワー8000以下のシグニ１体を対象とし、《赤》《赤》を支払ってもよい。そうした場合、それをバニッシュする。
-- 【出】：対戦相手のパワー3000以下のシグニ１体を対象とし、あなたのセンタールリグと対戦相手のセンタールリグのレベルが同じ場合、それをバニッシュする。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_RISEN)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=8000 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e) and Duel.CanPayEna(tp,"{R}{R}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{R}{R}"),REASON_COST)
    if tc:GetPower()<=8000 then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=3000 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    local oc=Duel.GetMatchingGroup(nil,tp,0,LOCATION_LRIG,nil):GetFirst()
    if tc and tc:IsRelateToEffect(e) and tc:GetPower()<=3000 and lc and oc and lc:GetLevel()==oc:GetLevel() then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e3)
end
