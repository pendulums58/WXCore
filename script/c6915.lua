-- WXK09-042 伝播の蒼天　オケアノス
-- 【自】：このシグニがアタックしたとき、対戦相手のシグニ１体を対象とし、あなたのトラッシュに＜天使＞のシグニが５枚以上ある場合、《青》を支払ってもよい。そうした場合、ターン終了時まで、それのパワーを－3000する。
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
    if not (tc and tc:IsRelateToEffect(e) and Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsClass(0,RACE_TENSHI) end,tp,LOCATION_TRASH,0,nil):GetCount()>=5) then return end
    if not (Duel.CanPayEna(tp,"{U}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{U}"),REASON_COST)
    aux.AddPower(e,tc,-3000)
  end)
  c:RegisterEffect(e1)
end
