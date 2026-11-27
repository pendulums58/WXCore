-- WX02-075 グレイブ・メイカー
-- あなたのデッキの上からカードを６枚トラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,6)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
end
