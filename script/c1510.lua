-- WDK02-007 スリー・ダスト
-- このアーツはあなたのセンタールリグがレベル３以上の場合にしか使用できない。
-- 対戦相手の手札を３枚見ないで選び、捨てさせる。
-- （手札が２枚以下の場合すべて捨てさせる）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCondition(function(e,tp)
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    return lc~=nil and lc:GetLevel()>=3
  end)
  -- 「見ないで選び」: 뒷면으로 고른다. 모자라면 있는 만큼
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil)
    local n=math.min(3,g:GetCount())
    if n>0 then Duel.SendToTrash(Duel.SelectCards(tp,g,n,n),REASON_EFFECT+REASON_DISCARD) end
  end)
  c:RegisterEffect(e1)
end
