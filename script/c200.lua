-- WD16-009 ドント・エスケープ
-- 対戦相手のシグニ１体を対象とし、それをダウンする。あなたのセンタールリグが青で、あなたのライフクロスが２枚以下の場合、代わりに対戦相手のシグニを２体まで対象とし、それらをダウンする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    local two=lc and lc:IsColor(COLOR_BLUE) and Duel.GetMatchingGroup(nil,tp,LOCATION_LIFE,0,nil):GetCount()<=2
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,two and 0 or 1,two and 2 or 1,nil)
  end)
  e1:SetOperation(function(e,tp)
    for tc in Duel.GetTargets():Iter() do
      if tc:IsRelateToEffect(e) then Duel.Down(tc) end
    end
  end)
  c:RegisterEffect(e1)
end
