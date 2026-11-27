-- WX14-054 幻竜　ザッハーク
-- 【起】《ダウン》：対戦相手は自分のエナゾーンのカードが７枚になるように、エナゾーンからカードをトラッシュに置く。（エナゾーンのカードが７枚以下の場合、この効果の影響を受けない）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetCost(aux.SelfDownCost)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(nil,1-tp,LOCATION_ENA,0,nil)
    local n=g:GetCount()-7
    if n>0 then Duel.SendToTrash(Duel.SelectCards(1-tp,g,n,n),REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
end
