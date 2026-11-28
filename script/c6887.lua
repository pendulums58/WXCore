-- WXK09-014 タイタンズ・グローブ
-- 対象の対戦相手のセンタールリグ１体を凍結し、対象の対戦相手のシグニ１体をダウンし、対戦相手のエナゾーンから対象のカード１枚をトラッシュに置く。対戦相手は手札を１枚捨てる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp,eg)
    local lc=Duel.SelectTarget(tp,nil,tp,0,LOCATION_LRIG,1,1,nil):GetFirst()
    local s=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    local en=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ENA,1,1,nil):GetFirst()
    if lc then Duel.Freeze(lc) end
    if s then Duel.Down(s) end
    if en then Duel.SendToTrash(en,REASON_EFFECT) end
    aux.Discard(1-tp,1)
  end)
  c:RegisterEffect(e1)
end
