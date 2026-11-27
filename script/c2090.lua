-- WX05-028 遅起の花咲　アフロディテ
-- 【自】：このシグニの正面の対戦相手のシグニがアタックしたとき、《白》を支払ってもよい。そうした場合、ターン終了時まで、このシグニのパワーを＋3000する。
-- 【自】：このシグニが手札以外から場に出たとき、対戦相手のシグニ１体を対象とし、《白》《白》を支払ってもよい。そうした場合、それをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg) return eg:GetFirst()==e:GetHandler():GetFrontCard() end)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if not (h:IsLocation(LOCATION_SZONE) and Duel.CanPayEna(tp,"{W}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{W}"),REASON_COST)
    aux.AddPower(e,h,3000)  -- [まで] ターン終了時まで
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetAbilityType(ABILITY_AUTO)
  e2:SetCondition(function(e) return not e:GetHandler():IsPreviousLocation(LOCATION_HAND) end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    if not (Duel.CanPayEna(tp,"{W}{W}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{W}{W}"),REASON_COST)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToTrash(tc,REASON_EFFECT) end
  end)
  c:RegisterEffect(e2)
end
