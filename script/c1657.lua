-- WDK08-L15 紅蓮の使い魔　コノハナサクヤ
-- 【常】：このシグニは血晶武装状態であるかぎり、【アサシン】を得る。
-- 【自】：このシグニがアタックしたとき、対戦相手のパワー1000以下のシグニ１体を対象とし、《赤》を支払ってもよい。そうした場合、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 血晶武装状態인 동안
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_ASSASSIN)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return e:GetHandler():IsBloodArmed() end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=1000 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    if not (Duel.CanPayEna(tp,"{R}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{R}"),REASON_COST)
    Duel.Banish(tc)
  end)
  c:RegisterEffect(e2)
end
