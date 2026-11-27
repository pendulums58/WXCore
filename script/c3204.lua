-- WX21-042 幻竜　＃アマルガ＃
-- 【出】：あなたのトラッシュから＜龍獣＞のシグニを２枚まで対象とし、それらをこのシグニの下に置く。
-- 【自】：このシグニがアタックしたとき、このシグニの下からカード１枚をトラッシュに置く。そうした場合、あなたのデッキの一番上のカードをエナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_RYUJU)) end,tp,LOCATION_TRASH,0,0,2,nil)
  end)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 and h:IsLocation(LOCATION_SZONE) then Duel.PutUnder(h,g) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetOperation(function(e,tp)
    local u=e:GetHandler():GetUnderGroup()
    if u:GetCount()>0 and Duel.SendToTrash(Duel.SelectCards(tp,u,1,1),REASON_EFFECT)>0 then Duel.EnaCharge(tp,1) end
  end)
  c:RegisterEffect(e2)
end
