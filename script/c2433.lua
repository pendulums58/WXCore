-- WX10-066 降星の炎岩
-- 対戦相手のレゾナ１体を対象とし、それをバニッシュする。
-- ライフバースト：どちらか１つを選ぶ。①対戦相手のパワー10000以下のシグニ１体を対象とし、それをバニッシュする。②対戦相手のレゾナ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsType(TYPE_RESONA) end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1))[1])
  end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if e:GetLabel()==0 then Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=10000 end,tp,0,LOCATION_SZONE,1,1,nil) else Duel.SelectTarget(tp,function(x) return x:IsType(TYPE_RESONA) end,tp,0,LOCATION_SZONE,1,1,nil) end
  end)
  e2:SetOperation(aux.BanishOp)
  c:RegisterEffect(e2)
end
