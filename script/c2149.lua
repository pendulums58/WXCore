-- WX06-028 炎機の歯車
-- このカードはあなたのライフクロスが対戦相手より少ない場合にしか使用できない。
-- 対戦相手の、パワー12000以下のシグニ１体とパワー10000以下のシグニ１体を対象とし、それらをバニッシュする。
-- ライフバースト：カードを２枚引く。あなたのライフクロス１枚をクラッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCondition(function(e,tp) return Duel.GetMatchingGroup(nil,tp,LOCATION_LIFE,0,nil):GetCount()<Duel.GetMatchingGroup(nil,tp,0,LOCATION_LIFE,nil):GetCount() end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local a=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=12000 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    Duel.SelectTarget(tp,function(x) return x~=a and (function(x) return x:IsSigni() and x:GetPower()<=10000 end)(x) end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.Banish(g) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,2)
    Duel.Crush(tp,1)
  end)
  c:RegisterEffect(e2)
end
