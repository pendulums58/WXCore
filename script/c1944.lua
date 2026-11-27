-- WX02-061 ＢＬＵＥＧＡＩＮ
-- あなたの場にある＜電機＞と＜水獣＞のシグニ１体につきカードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 처리할 때 센다(FAQ 2)
  e1:SetOperation(function(e,tp)
    local n=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_DENKI) or x:IsClass(0,RACE_SUIJU)) end,tp,LOCATION_SZONE,0,nil):GetCount()
    if n>0 then Duel.Draw(tp,n) end
  end)
  c:RegisterEffect(e1)
end
