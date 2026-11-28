-- WXK07-011 焼者必遂
-- このアーツの使用コストはあなたの場にあるシグニ１体につき《赤×1》減る。
-- 対戦相手のパワー10000以下のシグニ１体を対象とし、それをバニッシュする。その後、対戦相手のエナゾーンからカード１枚を対象とし、それをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=10000 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.Banish(tc) end
    local en=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ENA,1,1,nil):GetFirst()
    if en then Duel.SendToTrash(en,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
  aux.SetCostBy(e1,function(e,tp,base) return Duel.ReduceCost(base,"{R}",Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):GetCount()) end)
end
