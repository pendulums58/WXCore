-- WX01-062 ゲット・オープン
-- あなたのデッキの上からカードを５枚見る。その中から好きな枚数をトラッシュに置き、残りを好きな順番でデッキの一番上に戻す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,5)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    local tr=Duel.SelectCards(tp,g,0,g:GetCount())
    if tr:GetCount()>0 then Duel.SendToTrash(tr,REASON_EFFECT) end
    local rest=g:Filter(function(x) return not tr:IsContains(x) end,nil)
    if rest:GetCount()>0 then aux.ToDeckTopInOrder(tp,rest) end
  end)
  c:RegisterEffect(e1)
end
