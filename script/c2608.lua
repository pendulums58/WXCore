-- WX13-034 幻獣神　マンモ
-- 【常】：あなたのルリグデッキが０枚であるかぎり、このシグニは対戦相手のアーツの効果を受けない。
-- 【常】：あなたのシグニは「【自】：このシグニがアタックしたとき、自身よりパワーの低い対戦相手のシグニ１体を対象とし、それをバニッシュする。」を得る。
-- ライフバースト：対戦相手のパワー10000以上のシグニ１体を対象とし、あなたのデッキの一番上のカードをエナゾーンに置き、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 둘
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_IMMUNE)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),LOCATION_LDECK,0,nil):GetCount()==0 end)
  e1:SetValue(function(e,sc,sp) return sp~=e:GetHandlerPlayer() and sc:IsType(TYPE_ARTS) end)
  c:RegisterEffect(e1)
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  g:SetDescription(aux.Ability(id,1))
  g:SetCode(EVENT_ATTACK)
  g:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local p=e:GetHandler():GetPower()
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<p end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  g:SetOperation(aux.BanishOp)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetCode(EFFECT_GRANT)
  e2:SetRange(LOCATION_SZONE)
  e2:SetTargetRange(LOCATION_SIGNI,0)
  e2:SetTarget(function(e,x) return x:IsSigni() end)
  e2:SetLabelObject(g)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()>=10000 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    Duel.EnaCharge(tp,1)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e3)
end
