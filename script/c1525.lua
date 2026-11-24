-- WDK04-013 大罠　バラバラ
-- 【出】：あなたのデッキの上からカードを３枚見る。その中から好きな枚数のカードをトラッシュに置き、残りを好きな順番でデッキの一番上に戻す。（デッキが２枚以下の場合それらをすべて見る）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    local tr=Duel.SelectCards(tp,g,0,g:GetCount())
    if tr:GetCount()>0 then Duel.SendToTrash(tr,REASON_EFFECT) end
    local rest=g:Filter(function(x) return not tr:IsContains(x) end,nil)
    if rest:GetCount()>0 then aux.ToDeckTopInOrder(tp,rest) end
  end)
  c:RegisterEffect(e1)
end
