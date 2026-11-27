-- WX15-060 食激
-- このスペルの使用コストはあなたの場にあるアクセされている＜調理＞のシグニ１体につき《緑×1》減る。
-- 対象のあなたのシグニ１体よりパワーの低い対象の対戦相手のシグニ１体をバニッシュする。そうした場合、あなたのデッキの一番上のカードをエナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  aux.SetCostBy(e1,function(e,tp,base) return Duel.ReduceCost(base,"{G}",Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_CHOURI)) end)(x) and x:IsAcce() end,tp,LOCATION_SZONE,0,nil):GetCount()) end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    s.a=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
    s.b=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
  end)
  e1:SetOperation(function(e,tp)
    -- 자기 시그니가 떠나도 그 파워(마지막 정보)로 비교한다(FAQ 2)
    if not (s.b and s.b:IsRelateToEffect(e)) or not s.a then return end
    if s.b:GetPower()<s.a:GetPower() and Duel.Banish(s.b)>0 then Duel.EnaCharge(tp,1) end
  end)
  c:RegisterEffect(e1)
end
