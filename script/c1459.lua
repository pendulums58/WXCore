-- WX21-064 幻竜　#トロス#
-- 【自】：このカードがあなたの＜龍獣＞のシグニの効果によって手札から公開されたとき、あなたのエナゾーンにあるカードが３枚以下の場合、あなたのデッキの一番上のカードをエナゾーンに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_REVEALED_FROM_HAND)
  e1:SetCondition(function(e,tp,eg,ep,ev,re) return re~=nil and (function(x) return x:IsSigni() and (x:IsClass(0,RACE_RYUJU)) end)(re:GetHandler()) end)
  e1:SetOperation(function(e,tp)
    if Duel.GetMatchingGroup(nil,tp,LOCATION_ENA,0,nil):GetCount()<=3 then Duel.EnaCharge(tp,1) end
  end)
  c:RegisterEffect(e1)
end
