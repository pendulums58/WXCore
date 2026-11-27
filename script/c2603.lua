-- WX13-025 フォービドゥン・ゲーム
-- このアーツを使用する際、手札から＜毒牙＞のシグニを２枚まで捨ててもよい。このアーツの使用コストは、この方法で捨てたシグニ１枚につき《黒×2》《無×1》減る。
-- 対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－12000する。その後、あなたのセンタールリグが＜ハナレ＞の場合、あなたのトラッシュからレベル３以下の＜毒牙＞のシグニ１枚を対象とし、それを場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local picked
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetMinCost(function(e,tp,base) return Duel.ReduceCost(base,"{B}{B}{C}",math.min(2,Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_DOKUGA)) end,tp,LOCATION_HAND,0,nil):GetCount())) end)
  e1:SetDeclare(function(e,tp)
    local base=Duel.GetUseCost()
    Duel.SetSelectCheck(function(g) return Duel.CanPayEna(tp,Duel.ReduceCost(base,"{B}{B}{C}",g:GetCount())) end)
    picked=Duel.SelectCards(tp,Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_DOKUGA)) end,tp,LOCATION_HAND,0,nil),0,2)
    Duel.SetUseCost(Duel.ReduceCost(base,"{B}{B}{C}",picked:GetCount()))
  end)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if picked and picked:GetCount()>0 then Duel.SendToTrash(picked,REASON_COST+REASON_DISCARD) end
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.AddPower(e,tc,-12000) end
    if (function() local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:IsLrigType(LRIG_HANARE) end)() then
      local x=Duel.SelectTarget(tp,function(c) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_DOKUGA)) end)(c) and c:GetLevel()<=3 end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
      if x then Duel.PutOnField(x,tp) end
    end
  end)
  c:RegisterEffect(e1)
end
