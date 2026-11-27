-- WX18-026 バッド・チョイス
-- 対戦相手のセンタールリグが白か赤の場合、このアーツの使用コストは《黒×2》になる。
-- あなたのトラッシュから黒のシグニを２枚まで対象とし、それらを場に出す。それらの【出】能力は発動しない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  aux.SetCostBy(e1,function(e,tp,base) if (function() local lc=Duel.GetMatchingGroup(nil,tp,0,LOCATION_LRIG,nil):GetFirst() return lc and (lc:IsColor(COLOR_WHITE) or lc:IsColor(COLOR_RED)) end)() then return "{B}{B}" end return base end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_BLACK) end,tp,LOCATION_TRASH,0,0,2,nil)
  end)
  e1:SetOperation(function(e,tp)
    for x in Duel.GetTargets():Iter() do if x:IsRelateToEffect(e) then Duel.PutOnField(x,tp,true) end end
  end)
  c:RegisterEffect(e1)
end
