-- WX01-034 修復
-- あなたのデッキの一番上のカードをライフクロスに加える。その後、あなたのエナゾーンにカードが１０枚以上ある場合、追加であなたのデッキの一番上のカードをライフクロスに加える。
-- ライフバースト：あなたのデッキの一番上のカードをライフクロスに加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,1)
    if g:GetCount()>0 then Duel.SendToLife(g) end
    if Duel.GetMatchingGroup(nil,tp,LOCATION_ENA,0,nil):GetCount()>=10 then
      g=Duel.GetDecktopGroup(tp,1)
      if g:GetCount()>0 then Duel.SendToLife(g) end
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,1)
    if g:GetCount()>0 then Duel.SendToLife(g) end
  end)
  c:RegisterEffect(e2)
end
