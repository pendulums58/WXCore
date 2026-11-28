-- WXK01-013 焦身成仁
-- カードを４枚引く。対戦相手はあなたの手札を１枚見ないで選び、あなたはそれを捨てる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp,eg)
    -- 버린 뒤에 리프레시(FAQ 1)
    Duel.Draw(tp,4)
    local h=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
    if h:GetCount()>0 then Duel.SendToTrash(Duel.SelectCards(1-tp,h,1,1),REASON_EFFECT+REASON_DISCARD) end
  end)
  c:RegisterEffect(e1)
end
