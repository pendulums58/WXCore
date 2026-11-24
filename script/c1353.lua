-- WD22-030-G 惨之遊　†アナベル†
-- 【自】：このシグニが対戦相手のシグニ１体をバニッシュしたとき、《無》を支払ってもよい。そうした場合、このシグニを場からトラッシュに置く。その後、あなたのトラッシュからシグニ１枚を対象とし、それをダウン状態で場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_BANISHED)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg,ep) return ep~=tp and Duel.GetBanisher()==e:GetHandler() end)
  -- 방금 놓은 자신도 낼 수 있다(FAQ 1)
  e1:SetOperation(function(e,tp)
    if not (Duel.CanPayEna(tp,"{C}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{C}"),REASON_COST)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) then Duel.SendToTrash(h,REASON_EFFECT) end
    local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    if tc and Duel.PutOnField(tc,tp) then Duel.Down(tc) end
  end)
  c:RegisterEffect(e1)
end
