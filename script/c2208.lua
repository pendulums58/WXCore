-- WX07-039 羅原　Uuo
-- 【自】：このシグニがバニッシュされたとき、このシグニの正面にあったシグニ１体を対象とし、《青》《青》を支払ってもよい。そうした場合、それをバニッシュする。
-- 【起】《青》《青》：対戦相手のシグニ１体を対象とし、あなたの＜原子＞のシグニ３体をバニッシュする。そうした場合、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BANISHED)
  e1:SetOperation(function(e,tp)
    -- 있던 존의 정면 존의 시그니
    local fz=Duel.GetFrontZone(e:GetHandler():GetPreviousZone())
    local x=fz and Duel.GetMatchingGroup(function(c) return c:GetZone()==fz end,tp,0,LOCATION_SIGNI,nil):GetFirst()
    if not x then return end
    if not (Duel.CanPayEna(tp,"{U}{U}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{U}{U}"),REASON_COST)
    Duel.Banish(x)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetEnaCost("{U}{U}")
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_GENSHI)) end,tp,LOCATION_SZONE,0,nil)
    if g:GetCount()<3 then return end
    if Duel.Banish(Duel.SelectCards(tp,g,3,3))<3 then return end
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e2)
end
