-- WXK01-069 パンドラ・ボックス
-- あなたのデッキの上からカードを３枚見る。その中から１枚を手札に加え、１枚をトラッシュに置き、残りをデッキの一番上に戻す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp,eg)
    -- 모자라면 위에서부터 할 수 있는 만큼(FAQ 1)
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    Duel.SendToHand(Duel.SelectCards(tp,g,1,1))
    local rest=g:Filter(function(y) return y:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToTrash(Duel.SelectCards(tp,rest,1,1),REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
end
