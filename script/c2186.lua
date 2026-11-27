-- WX07-015 ピーピング・チョイス
-- 対戦相手の手札を見て無色ではないカード１枚を選び、捨てさせる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    local x=Duel.SelectCards(tp,g:Filter(function(c) return c:GetColor()~=0 end,nil),1,1)
    if x:GetCount()>0 then Duel.SendToTrash(x,REASON_EFFECT+REASON_DISCARD) end
  end)
  c:RegisterEffect(e1)
end
