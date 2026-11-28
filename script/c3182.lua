-- WX21-017 導かれし使　リワト＝トレ
-- 【常】：このカードにグロウする際、手札から＜天使＞のシグニを２枚捨ててもよい。そうした場合、このカードにグロウするためのコストは《青×0》になる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 「＜天使＞を2枚捨ててもよい。そうした場合、グロウコストは0」
  local e0=Effect.CreateEffect(c)
  e0:SetType(EFFECT_TYPE_SINGLE)
  e0:SetCode(EFFECT_GROW_PROC)
  e0:SetMinCost(function(e,tp,base) if Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI)) end,tp,LOCATION_HAND,0,nil):GetCount()>=2 then return "" end return base end)
  e0:SetDeclare(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_TENSHI)) end,tp,LOCATION_HAND,0,nil)
    if g:GetCount()>=2 and (not Duel.CanPayEna(tp,Duel.GetUseCost()) or Duel.SelectYesNo(tp,e:GetHandler(),aux.Ability(id,0))) then
      Duel.SendToTrash(Duel.SelectCards(tp,g,2,2),REASON_COST+REASON_DISCARD)
      Duel.SetUseCost("")
    end
  end)
  c:RegisterEffect(e0)
end
