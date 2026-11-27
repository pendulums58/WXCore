-- WX13-050 ＶＯＩＣＥ　ＣＨＡＮＧＥ
-- あなたのトラッシュからカード１枚を対象とし、あなたのライフクロス１枚をトラッシュに置く。そうした場合、それをライフクロスに加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,nil,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local life=Duel.GetMatchingGroup(nil,tp,LOCATION_LIFE,0,nil)
    if life:GetCount()==0 then return end
    if Duel.SendToTrash(Duel.SelectCards(tp,life,1,1),REASON_EFFECT)==0 then return end
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToLife(tc) end
  end)
  c:RegisterEffect(e1)
end
