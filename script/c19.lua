-- WX09-Re13 硝煙の気焔
-- 対象のあなたのシグニ１体をバニッシュする。そうした場合、対象の対戦相手のパワー10000以下のシグニ１体をバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    s.a=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
    s.b=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=10000 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
  end)
  e1:SetOperation(function(e,tp)
    if s.a and s.a:IsRelateToEffect(e) and Duel.Banish(s.a)>0 and s.b and s.b:IsRelateToEffect(e) then Duel.Banish(s.b) end
  end)
  c:RegisterEffect(e1)
end
