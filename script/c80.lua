-- WX12-Re13 龍炎の昇拳
-- 以下の２つから１つを選ぶ。
-- ①対象のあなたのシグニ１体をバニッシュする。そうした場合、対象のパワー8000以下のシグニ１体をバニッシュする。
-- ②対象のあなたのシグニ１体をバニッシュする。そうした場合、対戦相手のエナゾーンから対象の【マルチエナ】を持つカード１枚をトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1))[1])
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    s.a=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
    if e:GetLabel()==0 then
      s.b=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=8000 end,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,s.a):GetFirst()
    else
      s.b=Duel.SelectTarget(tp,function(x) return x:HasKeyword(EFFECT_MULTI_ENA) end,tp,0,LOCATION_ENA,1,1,nil):GetFirst()
    end
  end)
  e1:SetOperation(function(e,tp)
    if not (s.a and s.a:IsRelateToEffect(e)) or Duel.Banish(s.a)==0 then return end
    if not (s.b and s.b:IsRelateToEffect(e)) then return end
    if e:GetLabel()==0 then Duel.Banish(s.b) else Duel.SendToTrash(s.b,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
end
