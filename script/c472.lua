-- SP07-009 天佑神助（「selector spread WIXOSS」 BOX2 初回限定特典）
-- あなたのデッキの一番上のカードをライフクロスに加える。その後、手札から＜美巧＞のシグニを２枚捨ててよい。そうした場合、このカードをあなたのルリグデッキに戻す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- ＜美巧＞ 2장을 버리지 못하면 돌아가지 않는다(FAQ 1)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,1)
    if g:GetCount()>0 then Duel.SendToLife(g) end
    local h=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsClass(0,RACE_BIKOU) end,tp,LOCATION_HAND,0,nil)
    if h:GetCount()<2 or not Duel.SelectYesNo(tp) then return end
    if Duel.SendToTrash(Duel.SelectCards(tp,h,2,2),REASON_EFFECT+REASON_DISCARD)<2 then return end
    local me=e:GetHandler()
    if me:IsLocation(LOCATION_CHECK) then Duel.SendToLrigDeck(me) end
  end)
  c:RegisterEffect(e1)
end
