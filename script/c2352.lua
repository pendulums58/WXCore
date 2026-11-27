-- WX09-028 コードアート　Ｃ・Ｌ
-- 【自】：対戦相手があなたのシグニの効果によって手札を１枚捨てたとき、対戦相手のシグニ１体を対象とし、《青》を支払ってもよい。そうした場合、それをバニッシュする。
-- 【出】：あなたのトラッシュからスペル１枚を対象とし、あなたのトラッシュにカード名に《Ｖ・Ａ・Ｃ》を含むカードがある場合、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TO_TRASH)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) local x=eg:GetFirst() if not (r&REASON_DISCARD~=0 and x:GetOwner()~=tp and re) then return false end local h=re:GetHandler() return h and h:IsSigni() and h:GetControler()==tp end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    if not (Duel.CanPayEna(tp,"{U}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{U}"),REASON_COST)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsType(TYPE_SPELL) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then if Duel.GetMatchingGroup(function(x) return x:IsCardName(1280) end,tp,LOCATION_TRASH,0,nil):GetCount()>0 then Duel.SendToHand(tc) end end
  end)
  c:RegisterEffect(e2)
end
