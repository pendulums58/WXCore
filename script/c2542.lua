-- WX12-013 ドロー・ディソルブ
-- このアーツの使用コストはあなたのルリグトラッシュに青のアーツがある場合《無×1》減り、黒のアーツがある場合《無×1》減る。
-- あなたのセンタールリグのレベル１につきカードを１枚引く。その後、ターン終了時まで、対戦相手のすべてのシグニのパワーをあなたの手札１枚につき－2000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  aux.SetCostBy(e1,function(e,tp,base)
    local n=0
    for _,col in ipairs({COLOR_BLUE,COLOR_BLACK}) do
      if Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_ARTS) and x:IsColor(col) end,tp,LOCATION_LTRASH,0,nil):GetCount()>0 then n=n+1 end
    end
    return Duel.ReduceCost(base,"{C}",n)
  end)
  e1:SetOperation(function(e,tp)
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    if lc then Duel.Draw(tp,lc:GetLevel()) end
    local n=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()
    -- [まで] 처리할 때 장에 있는 시그니
    if n>0 then for tc in Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil):Iter() do aux.AddPower(e,tc,-2000*n) end end
  end)
  c:RegisterEffect(e1)
end
