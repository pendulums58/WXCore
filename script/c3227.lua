-- WX21-071 ワイズ・スパーク
-- このスペルを使用する際、手札から青と黒の＜電機＞のシグニを１枚ずつ捨ててもよい。そうした場合、このスペルの使用コストは《黒×0》になる。
-- 対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－8000する。この効果によってそのシグニのパワーが０以下になった場合、カードを１枚引き、対戦相手は手札を１枚捨てる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp)
    local b=Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_DENKI)) end)(x) and x:IsColor(COLOR_BLUE) end,tp,LOCATION_HAND,0,nil)
    local k=Duel.GetMatchingGroup(function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_DENKI)) end)(x) and x:IsColor(COLOR_BLACK) end,tp,LOCATION_HAND,0,nil)
    if b:GetCount()>0 and k:GetCount()>0 and Duel.SelectYesNo(tp) then
      local d=Duel.SelectCards(tp,b,1,1)
      d:Merge(Duel.SelectCards(tp,k:Filter(function(x) return not d:IsContains(x) end,nil),1,1))
      Duel.SendToTrash(d,REASON_COST+REASON_DISCARD)
      Duel.SetUseCost(Duel.ReduceCost(Duel.GetUseCost(),"{B}",9))
    end
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    aux.AddPower(e,tc,-8000)  -- [まで]
    if tc:GetPower()<=0 then Duel.Draw(tp,1) aux.Discard(1-tp,1) end
  end)
  c:RegisterEffect(e1)
end
