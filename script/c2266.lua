-- WX08-020 グレイブ・カース
-- 対戦相手は自分のデッキの上からカードを５枚トラッシュに置く。あなたのセンタールリグが黒の場合、代わりにカードを１０枚トラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    local g=Duel.GetDecktopGroup(1-tp,(lc and lc:IsColor(COLOR_BLACK)) and 10 or 5)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
end
