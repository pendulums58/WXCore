-- WDK16-06H コードＶＬ　本間ひまわり
-- 【常】：あなたの場にカード名に《楓》を含むセンタールリグがいるかぎり、このシグニは「【自】：このシグニがアタックしたとき、対戦相手のパワー8000以下のシグニ１体を対象とし、それをバニッシュする。あなたの登録者数が１００万人を達成している場合、代わりに対戦相手のシグニ１体を対象とし、それをバニッシュする。」を得る。
-- ライフバースト：対戦相手のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  g:SetDescription(aux.Ability(id,0))
  g:SetCode(EVENT_ATTACK)
  g:SetOperation(function(e,tp)
    local big=Duel.GetSubscribers(tp)>=100
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and (big or x:GetPower()<=8000) end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.Banish(tc) end
  end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  -- [の間] 【常】 100만이면 파워 제한 없음
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_GRANT)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x)
    if x~=e:GetHandler() then return false end
    local lc=Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),LOCATION_LRIG,0,nil):GetFirst()
    return lc~=nil and aux.NameHas(lc,"楓")
  end)
  e1:SetLabelObject(g)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e2)
end
