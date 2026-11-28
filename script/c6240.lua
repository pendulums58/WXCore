-- WXK01-057 ＣＩＲＣＬＥ
-- あなたのデッキの上からカードを５枚見る。その中からシグニを３枚まで場に出し、残りをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp,eg)
    -- 5장 미만이면 있는 만큼(FAQ 4)
    local g=Duel.GetDecktopGroup(tp,5)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    for x in Duel.SelectCards(tp,g:Filter(Card.IsType,nil,TYPE_SIGNI),0,3):Iter() do Duel.PutOnField(x,tp) end
    local rest=g:Filter(function(y) return y:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToTrash(rest,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
end
