-- WX22-019 遠矢の名手　≡アポロシン≡
-- 【常】：あなたの＜天使＞のシグニのパワーを＋2000する。
-- 【常】：このシグニは対戦相手の効果によってダウンしない。
-- 【自】：このシグニがバニッシュされたとき、このシグニよりパワーの低い対戦相手のシグニ１体を対象とし、それをバニッシュしてもよい。
-- 【出】：対戦相手のシグニ１体を対象とし、あなたの場に＜天使＞のシグニが３体ある場合、それをバニッシュする。
-- ライフバースト：対戦相手のパワー12000以下のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 둘
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI)) end)(x) end)
  e1:SetValue(2000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EFFECT_NO_DOWN_BY_OPP)
  e2:SetRange(LOCATION_SZONE)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_BANISHED)
  e3:SetOperation(function(e,tp)
    local p=e:GetHandler():GetPower()
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<p end,tp,0,LOCATION_SZONE,0,1,nil):GetFirst()
    if tc and Duel.SelectYesNo(tp) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e4:SetDescription(aux.Ability(id,3))
  e4:SetCode(EVENT_ON_PLAY)
  e4:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e4:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then if Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI)) end,tp,LOCATION_SZONE,0,nil):GetCount()>=3 then Duel.Banish(tc) end end
  end)
  c:RegisterEffect(e4)
  local e5=Effect.CreateEffect(c)
  e5:SetType(EFFECT_TYPE_LIFEBURST)
  e5:SetTarget(aux.BanishPowerTarget(12000))
  e5:SetOperation(aux.BanishOp)
  c:RegisterEffect(e5)
end
