-- WXK01-102 超罠　ミミック
-- 【出】：カードを３枚引き、手札からカード３枚を好きな順番でデッキの一番上に置く。（デッキが２枚以下の場合それらをすべて引く）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,3)
    local h=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
    local n=math.min(3,h:GetCount())
    if n>0 then aux.ToDeckTopInOrder(tp,Duel.SelectCards(tp,h,n,n)) end
  end)
  c:RegisterEffect(e1)
end
