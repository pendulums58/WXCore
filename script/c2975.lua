-- WX18-015 ハート・アクセス
-- 対戦相手のセンタールリグが緑か黒の場合、このアーツの使用コストは《青×2》になる。
-- 対戦相手は手札を２枚捨てる。あなたはカードを２枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  aux.SetCostBy(e1,function(e,tp,base) if (function() local lc=Duel.GetMatchingGroup(nil,tp,0,LOCATION_LRIG,nil):GetFirst() return lc and (lc:IsColor(COLOR_GREEN) or lc:IsColor(COLOR_BLACK)) end)() then return "{U}{U}" end return base end)
  e1:SetOperation(function(e,tp)
    aux.Discard(1-tp,2)
    Duel.Draw(tp,2)
  end)
  c:RegisterEffect(e1)
end
