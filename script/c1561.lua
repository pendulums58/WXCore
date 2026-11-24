-- WDK06-C06 フェイト・ストラグル
-- このアーツはあなたのトラッシュにカードが２０枚以上ある場合にしか使用できない。
-- 対戦相手のシグニを２体まで対象とし、それらをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 코스트를 내기 전에 본다(FAQ 2)
  e1:SetCondition(function(e,tp) return Duel.GetMatchingGroup(nil,tp,LOCATION_TRASH,0,nil):GetCount()>=20 end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,0,2,nil)
  end)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.Banish(g) end
  end)
  c:RegisterEffect(e1)
end
