-- WX09-034 コードアンチ　ロポリス
-- 【常】：あなたの場にカード名に《パルテノ》か《パルべック》を含むシグニがあるかぎり、このシグニのパワーは＋5000される。
-- 【常】：あなたのトラッシュにカード名に《パルテノ》か《パルべック》を含むシグニがあるかぎり、このシグニのパワーは＋5000される。
-- 【自】：このシグニがアタックしたとき、対戦相手のシグニ１体を対象とし、このシグニのパワーが20000以上の場合、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 둘. aux.NAMES["パルテノ"]에 《パルべック》도 들어 있다
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetValue(function(e) local p=e:GetHandlerPlayer() local v=0 if Duel.GetMatchingGroup(function(x) return x:IsSigni() and aux.NameHas(x,"パルテノ") end,p,LOCATION_SZONE,0,nil):GetCount()>0 then v=v+5000 end if Duel.GetMatchingGroup(function(x) return x:IsSigni() and aux.NameHas(x,"パルテノ") end,p,LOCATION_TRASH,0,nil):GetCount()>0 then v=v+5000 end return v end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_ATTACK)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then if e:GetHandler():GetPower()>=20000 then Duel.Banish(tc) end end
  end)
  c:RegisterEffect(e2)
end
