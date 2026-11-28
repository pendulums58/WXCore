-- WXEX1-67 大罠　ウォークウォーター
-- 【自】：このシグニがアタックしたとき、【トラップ】の数以下のレベルを持つ対戦相手のシグニ１体を対象とし、《青》を支払ってもよい。そうした場合、それを手札に戻す。
-- 【起】【トラップ】であるこのカードを公開する：この【トラップ】と同じシグニゾーンにシグニがない場合、この【トラップ】を表向きにしてシグニにする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local n=Duel.GetMatchingGroup(nil,tp,LOCATION_TRAP,LOCATION_TRAP,nil):GetCount()
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=n end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) or not Duel.CanPayEna(tp,"{U}") or not Duel.SelectYesNo(tp) then return end
    local g=Duel.SelectEnaCost(tp,"{U}")
    if g:GetCount()>0 and Duel.SendToTrash(g,REASON_COST)>0 then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_TRAP)
  e2:SetOperation(function(e,tp)
    local h=e:GetHandler()
    Duel.RevealCards(h)
    Duel.PutOnField(h,tp)
  end)
  c:RegisterEffect(e2)
end
