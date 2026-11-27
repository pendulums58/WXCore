-- WX03-005 全身全霊
-- 対戦相手のセンタールリグが青の場合、このカードの基本コストは《緑×1》になる。
-- あなたのデッキの一番上のカードをライフクロスに加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 「基本コスト」를 바꾼다
  aux.SetCostBy(e1,function(e,tp,base)
    local lc=Duel.GetMatchingGroup(nil,tp,0,LOCATION_LRIG,nil):GetFirst()
    return lc and lc:IsColor(COLOR_BLUE) and "{G}" or base
  end)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,1)
    if g:GetCount()>0 then Duel.SendToLife(g) end
  end)
  c:RegisterEffect(e1)
end
