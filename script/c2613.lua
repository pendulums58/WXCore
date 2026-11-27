-- WX13-040 思索の体現　*シンカー*
-- 【自】：あなたが対戦相手のシグニ１体のアタックを無効にしたとき、対戦相手のシグニ１体を対象とし、《白》を支払い、トラッシュにあるこのカードをゲームから除外してもよい。そうした場合、それを手札に戻す。（この能力はこのシグニがトラッシュにある場合にしか発動しない）
local s,id=GetID()
function s.initial_effect(c)
  -- 트래시에서만(괄호)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_NEGATED)
  e1:SetRange(LOCATION_TRASH)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return rp==tp and Duel.GetTurnPlayer()~=tp end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    if not (Duel.CanPayEna(tp,"{W}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{W}"),REASON_COST)
    local h=e:GetHandler()
    if not (h:IsLocation(LOCATION_TRASH) and Duel.Exclude(h)>0) then return end
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e1)
end
