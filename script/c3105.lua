-- WX20-005 レース・トルネード
-- あなたの場に＜精生＞のシグニがある場合、このアーツの使用コストは《青×1》減る。
-- あなたの手札が対戦相手より少ない場合、カードを３枚引く。その後、いずれかのプレイヤーの手札が６枚以上ある場合、対戦相手のシグニ１体を対象とし、それをデッキの一番上に置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  aux.SetCostBy(e1,function(e,tp,base) if Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsClass(SYS_SEISEI,0) end,tp,LOCATION_SZONE,0,nil):GetCount()>0 then return Duel.ReduceCost(base,"{U}",1) end return base end)
  e1:SetOperation(function(e,tp)
    local hand=function(p) return Duel.GetMatchingGroup(nil,p,LOCATION_HAND,0,nil):GetCount() end
    if hand(tp)<hand(1-tp) then Duel.Draw(tp,3) end
    if hand(tp)>=6 or hand(1-tp)>=6 then
      local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if tc then Duel.SendToDeckPosition(tc,1) end
    end
  end)
  c:RegisterEffect(e1)
end
