-- WX06-002 ピンチ・ディフェンス
-- 対戦相手のセンタールリグ１体を対象とし、ターン終了時まで、それは「【常】：アタックできない。」を得る。あなたのセンタールリグが白で、あなたのライフクロスが２枚以下の場合、代わりに対戦相手のセンタールリグ１体とシグニ１体を対象とし、ターン終了時まで、それらは「【常】：アタックできない。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 조건을 채우면 루리그와 시그니 둘 다(FAQ 1)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,nil,tp,0,LOCATION_LRIG,1,1,nil)
    if (function() local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst() return lc and lc:IsColor(COLOR_WHITE) and Duel.GetMatchingGroup(nil,tp,LOCATION_LIFE,0,nil):GetCount()<=2 end)() then Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil) end
  end)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    -- [まで] ターン終了時まで
    for tc in g:Iter() do aux.GrantKeyword(e,tc,EFFECT_CANNOT_ATTACK) end
  end)
  c:RegisterEffect(e1)
end
