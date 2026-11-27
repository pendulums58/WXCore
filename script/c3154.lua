-- WX20-068 未英の観測　＃ウィグナー＃
-- 【出】英知＝７：あなたのエナゾーンから＜英知＞のシグニ１枚を対象とし、それを場に出す。
-- 【自】英知＝１１《ターン１回》：このシグニがアタックしたとき、あなたのカード名に《シュレデ》を含むすべてのシグニをアップする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCondition(aux.EichiCon(7))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_EICHI)) end,tp,LOCATION_ENA,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.PutOnField(tc,tp) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetCountLimit(1)
  e2:SetCondition(aux.EichiCon(11))
  e2:SetOperation(function(e,tp)
    for x in Duel.GetMatchingGroup(function(x) return x:IsSigni() and aux.NameHas(x,"シュレデ") end,tp,LOCATION_SZONE,0,nil):Iter() do Duel.Up(x) end
  end)
  c:RegisterEffect(e2)
end
