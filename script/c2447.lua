-- WX10-085 呼声
-- あなたのデッキの上からカードを５枚公開する。その中から緑のシグニを２枚まで手札に加え、残りをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,aux.RevealCount(tp,5))
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    local pick=Duel.SelectCards(tp,g:Filter(function(x) return x:IsSigni() and x:IsColor(COLOR_GREEN) end,nil),0,2)
    if pick:GetCount()>0 then Duel.SendToHand(pick) end
    local rest=g:Filter(function(x) return x:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToTrash(rest,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
end
