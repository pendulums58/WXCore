-- WX16-030 理英の謎箱　＃シュレデ＃
-- 【自】：このシグニがアタックしたとき、あなたのエナゾーンから＜英知＞のシグニ１枚を対象とし、《緑》を支払ってもよい。そうした場合、それを場に出す。
-- 【自】英知＝１１：このシグニが対戦相手のライフクロス１枚をクラッシュしたとき、《緑》《緑》を支払ってもよい。そうした場合、あなたのデッキの一番上のカードをライフクロスに加える。
-- ライフバースト：あなたのライフクロスが２枚以下の場合、あなたのデッキの一番上のカードをライフクロスに加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_EICHI)) end,tp,LOCATION_ENA,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and Duel.CanPayEna(tp,"{G}") and Duel.SelectYesNo(tp) then
      Duel.SendToTrash(Duel.SelectEnaCost(tp,"{G}"),REASON_COST)
      Duel.PutOnField(tc,tp)
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_CRUSHED)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e,tp,eg,ep) return ep~=tp and Duel.GetCrusher()==e:GetHandler() and aux.EichiCon(11)(e) end)
  e2:SetOperation(function(e,tp)
    if Duel.CanPayEna(tp,"{G}{G}") and Duel.SelectYesNo(tp) then
      Duel.SendToTrash(Duel.SelectEnaCost(tp,"{G}{G}"),REASON_COST)
      local x=Duel.GetDecktopGroup(tp,1):GetFirst()
      if x then Duel.SendToLife(x) end
    end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    if Duel.GetMatchingGroup(nil,tp,LOCATION_LIFE,0,nil):GetCount()<=2 then local x=Duel.GetDecktopGroup(tp,1):GetFirst() if x then Duel.SendToLife(x) end end
  end)
  c:RegisterEffect(e3)
end
