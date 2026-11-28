-- WXK04-026 羅植姫　スイレン
-- 【自】：このシグニがアタックしたとき、対戦相手のシグニ１体を対象とし、あなたのエナゾーンに＜植物＞のシグニが５種類以上ある場合、《白》を支払ってもよい。そうした場合、それを手札に戻す。
-- 【自】：このシグニが開花したとき、ターン終了時まで、対戦相手のシグニ１体は能力を失う。
-- ライフバースト：対戦相手のシグニ１体を対象とし、それを手札に戻す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e) and (function() local t,n={},0 for x in Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsClass(0,RACE_SHOKUBUTSU) end,tp,LOCATION_ENA,0,nil):Iter() do if not t[x:GetCode()] then t[x:GetCode()]=true n=n+1 end end return n end)()>=5) then return end
    if not (Duel.CanPayEna(tp,"{W}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{W}"),REASON_COST)
    Duel.SendToHand(tc)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_BLOOM)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if not tc then return end
    -- [まで] ターン終了時まで
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_LOSE_ABILITY)
    e1:SetReset(RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e1)
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e9:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.SendToHand(tc)
    end
  end)
  c:RegisterEffect(e9)
end
