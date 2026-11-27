-- WX03-004 ツー・ダスト
-- 対戦相手のセンタールリグが赤の場合、このカードの基本コストは《青×1》になる。
-- 対戦相手の手札を２枚見ないで選び、捨てさせる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 「基本コスト」를 바꾼다
  aux.SetCostBy(e1,function(e,tp,base)
    local lc=Duel.GetMatchingGroup(nil,tp,0,LOCATION_LRIG,nil):GetFirst()
    return lc and lc:IsColor(COLOR_RED) and "{U}" or base
  end)
  -- 「見ないで選び」: 뒷면으로 고른다
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil)
    local n=math.min(2,g:GetCount())
    if n>0 then Duel.SendToTrash(Duel.SelectCards(tp,g,n,n),REASON_EFFECT+REASON_DISCARD) end
  end)
  c:RegisterEffect(e1)
end
