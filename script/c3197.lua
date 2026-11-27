-- WX21-035 縛恋の煉獄
-- このスペルを使用する際、手札から赤と緑の＜龍獣＞のシグニを１枚ずつ捨ててもよい。そうした場合、このスペルの使用コストは《赤×0》になる。
-- 以下の４つから２つまで選ぶ。
-- ①対戦相手のエナゾーンから対戦相手のセンタールリグと共通する色を持たないカード１枚を対象とし、それをトラッシュに置く。
-- ②あなたのデッキの上からカードを２枚エナゾーンに置く。
-- ③対戦相手のパワー7000以下のシグニ１体を対象とし、それをバニッシュする。
-- ④対戦相手のパワー12000以上のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp)
    local r=Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_RYUJU)) end)(x) and x:IsColor(COLOR_RED) end,tp,LOCATION_HAND,0,nil)
    local g=Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_RYUJU)) end)(x) and x:IsColor(COLOR_GREEN) end,tp,LOCATION_HAND,0,nil)
    if r:GetCount()>0 and g:GetCount()>0 and Duel.SelectYesNo(tp) then
      local d=Duel.SelectCards(tp,r,1,1)
      d:Merge(Duel.SelectCards(tp,g:Filter(function(x) return not d:IsContains(x) end,nil),1,1))
      Duel.SendToTrash(d,REASON_COST+REASON_DISCARD)
      Duel.SetUseCost(Duel.ReduceCost(Duel.GetUseCost(),"{R}",9))
    end
  end)
  e1:SetOperation(function(e,tp)
    local m=0
    for _,i in ipairs(Duel.SelectModes(tp,1,2,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3))) do m=m|(1<<i) end
    if m&1~=0 then
      local lc=Duel.GetMatchingGroup(nil,tp,0,LOCATION_LRIG,nil):GetFirst()
      local x=Duel.SelectTarget(tp,function(c) return not lc or c:GetColor()&lc:GetColor()==0 end,tp,0,LOCATION_ENA,1,1,nil):GetFirst()
      if x then Duel.SendToTrash(x,REASON_EFFECT) end
    end
    if m&2~=0 then Duel.EnaCharge(tp,2) end
    if m&4~=0 then local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=7000 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() if tc then Duel.Banish(tc) end end
    if m&8~=0 then local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()>=12000 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() if tc then Duel.Banish(tc) end end
  end)
  c:RegisterEffect(e1)
end
