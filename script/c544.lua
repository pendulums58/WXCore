-- SP26-006 レフト・ホープ（「Lostorage incited WIXOSS 5」 初回特典）
-- 対戦相手のすべてのシグニをトラッシュに置く。対戦相手はこのターンの次に、追加の１ターンを得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
    Duel.ExtraTurn(1-tp)
  end)
  c:RegisterEffect(e1)
end
