-- WX22-003 クトゥル・アビス
-- 対象の対戦相手のシグニ１体をトラッシュに置く。ターン終了時まで、対象の対戦相手のセンタールリグ１体は「【常】：アタックできない。」を得る。あなたのトラッシュから対象のシグニ１枚を場に出す。それの【出】能力は発動しない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    s.a=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    s.b=Duel.SelectTarget(tp,nil,tp,0,LOCATION_LRIG,1,1,nil):GetFirst()
    s.c=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
  end)
  e1:SetOperation(function(e,tp)
    if s.a and s.a:IsRelateToEffect(e) then Duel.SendToTrash(s.a,REASON_EFFECT) end
    if s.b and s.b:IsRelateToEffect(e) then local tc=s.b
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CANNOT_ATTACK)
    e1:SetReset(RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e1)
    end
    if s.c and s.c:IsRelateToEffect(e) then Duel.PutOnField(s.c,tp,true) end
  end)
  c:RegisterEffect(e1)
end
