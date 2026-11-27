-- WX04-032 龍鳳の排炎
-- このスペルの使用コストはあなたの場にある＜龍獣＞のシグニ１体につき《赤×1》減る。
-- 対象の対戦相手のパワー10000以下のシグニ１体をバニッシュする。そうした場合、対戦相手のエナゾーンから対象のカード１枚をトラッシュに置く。
-- ライフバースト：対戦相手のエナゾーンから対象のカード１枚をトラッシュに置く。対戦相手のエナゾーンにあるカードが４枚以下の場合、対象のパワー10000以下のシグニ１体をバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  aux.SetCostBy(e1,function(e,tp,base) return Duel.ReduceCost(base,"{R}",Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_RYUJU)) end,tp,LOCATION_SZONE,0,nil):GetCount()) end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=10000 end,tp,0,LOCATION_SZONE,1,1,nil)
    Duel.SelectTarget(tp,nil,tp,0,LOCATION_ENA,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local sg,eg2
    for tc in Duel.GetTargets():Iter() do
      if tc:IsRelateToEffect(e) then
        if tc:IsLocation(LOCATION_ENA) then eg2=tc else sg=tc end
      end
    end
    if sg and Duel.Banish(sg)>0 and eg2 then Duel.SendToTrash(eg2,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,nil,tp,0,LOCATION_ENA,1,1,nil)
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=10000 end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local sg,eg2
    for tc in Duel.GetTargets():Iter() do
      if tc:IsRelateToEffect(e) then
        if tc:IsLocation(LOCATION_ENA) then eg2=tc else sg=tc end
      end
    end
    if eg2 then Duel.SendToTrash(eg2,REASON_EFFECT) end
    if sg and Duel.GetMatchingGroup(nil,tp,0,LOCATION_ENA,nil):GetCount()<=4 then Duel.Banish(sg) end
  end)
  c:RegisterEffect(e2)
end
