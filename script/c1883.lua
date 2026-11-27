-- WX01-080 幻水　シャコタン
-- 【起】《ダウン》手札を１枚捨てる：カードを２枚引き、手札を１枚捨てる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsUp() and Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()>0 end
    Duel.Down(e:GetHandler())
    Duel.SendToTrash(Duel.SelectDiscard(tp,1,1),REASON_COST+REASON_DISCARD)
  end)
  e1:SetOperation(function(e,tp)
    Duel.Draw(tp,2)
    aux.Discard(tp,1)
  end)
  c:RegisterEffect(e1)
end
