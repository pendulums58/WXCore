-- WX17-046 割英の半斬　＃ニトウブン＃
-- 【出】英知＝３：あなたのエナゾーンからレベル３以下の＜英知＞のシグニ１枚を対象とし、それを場に出す。
-- 【自】英知＝７：このシグニがシグニ１体をバニッシュしたとき、バニッシュしたシグニと同じパワーを持つ対戦相手のシグニ１体を対象とし、それをバニッシュする。
-- 【自】英知＝１１：このシグニがアタックしたとき、このシグニと同じパワーを持つ他のすべてのシグニをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCondition(aux.EichiCon(3))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_EICHI)) end)(x) and x:GetLevel()<=3 end,tp,LOCATION_ENA,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.PutOnField(tc,tp) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_BANISHED)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e,tp,eg) return Duel.GetBanisher()==e:GetHandler() and aux.EichiCon(7)(e) end)
  e2:SetOperation(function(e,tp,eg)
    local p=eg:GetFirst():GetPower()
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()==p end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_ATTACK)
  e3:SetCondition(aux.EichiCon(11))
  e3:SetOperation(function(e,tp)
    local h=e:GetHandler()
    local p=h:GetPower()
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:GetPower()==p end,tp,LOCATION_SZONE,LOCATION_SZONE,h)
    if g:GetCount()>0 then Duel.Banish(g) end
  end)
  c:RegisterEffect(e3)
end
