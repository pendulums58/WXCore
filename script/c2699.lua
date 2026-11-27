-- WX14-038 羅原　Ｎａ
-- 【出】：対戦相手の手札を見て、その中からコストの合計が１以下のスペル１枚を選び、捨てさせる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    local x=Duel.SelectCards(tp,g:Filter(function(c) return c:IsType(TYPE_SPELL) and c:GetCostTotal()<=1 end,nil),1,1)
    if x:GetCount()>0 then Duel.SendToTrash(x,REASON_EFFECT+REASON_DISCARD) end
  end)
  c:RegisterEffect(e1)
end
