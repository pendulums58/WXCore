-- PR-K076 大装　ネメシス（カードゲーマー vol.51 付録）
-- 【自】：このシグニがバニッシュされたとき、対戦相手のシグニ１体を対象とし、《黒》を支払ってもよい。そうした場合、それをバニッシュする。
-- 【起】《黒》このシグニを場からトラッシュに置く：あなたのシグニ１体を対象とし、ターン終了時まで、それのパワーを＋3000し、それは「【自】：このシグニがアタックしたとき、対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーをこのシグニのパワーと同じだけ－（マイナス）する。」を得る。
-- ライフバースト：このターンにアタックした対戦相手のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BANISHED)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e) and Duel.CanPayEna(tp,"{B}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{B}"),REASON_COST)
    Duel.Banish(tc)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetEnaCost("{B}")
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_SZONE) end
    Duel.SendToTrash(e:GetHandler(),REASON_COST)
  end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    aux.AddPower(e,tc,3000)  -- [まで] ターン終了時まで
    local g=Effect.CreateEffect(e:GetHandler())
    g:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    g:SetDescription(aux.Ability(id,1))
    g:SetCode(EVENT_ATTACK)
    g:SetOperation(function(e2,tp2)
      local x=Duel.SelectTarget(tp2,Card.IsSigni,tp2,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if x then aux.AddPower(e2,x,-e2:GetHandler():GetPower()) end
    end)
    g:SetReset(RESET_PHASE+PHASE_END)
    tc:GrantEffect(g)
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:HasAttacked() end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e3)
end
