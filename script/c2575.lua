-- WX12-049 ＩＮＳＩＧＨＴ
-- あなたの場に青の＜電機＞のシグニがある場合、このスペルの使用コストは《青×1》減り、黒の＜電機＞のシグニがある場合、《黒×1》減る。
-- あなたのデッキの上からカードを３枚見る。その中からカード１枚を手札に加え、残りを好きな順番でデッキの一番下に置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  aux.SetCostBy(e1,function(e,tp,base)
    if Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_DENKI)) end)(x) and x:IsColor(COLOR_BLUE) end,tp,LOCATION_SZONE,0,nil):GetCount()>0 then base=Duel.ReduceCost(base,"{U}",1) end
    if Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_DENKI)) end)(x) and x:IsColor(COLOR_BLACK) end,tp,LOCATION_SZONE,0,nil):GetCount()>0 then base=Duel.ReduceCost(base,"{B}",1) end
    return base
  end)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    local x=Duel.SelectCards(tp,g,1,1)
    Duel.SendToHand(x)
    local rest=g:Filter(function(c) return c:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(Duel.SelectOrder(tp,rest),false) end
  end)
  c:RegisterEffect(e1)
end
