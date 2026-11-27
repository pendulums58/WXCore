-- WX13-082 壱ノ遊　カミカブト
-- 【自】：このシグニがアタックしたとき、あなたのデッキの上からカードを３枚見る。その中から好きな枚数を好きな順番でデッキの一番上に置き、残りを好きな順番でデッキの一番下に置く。
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    local t=Duel.SelectCards(tp,g,0,g:GetCount())
    local b=g:Filter(function(x) return not t:IsContains(x) end,nil)
    if b:GetCount()>0 then Duel.SendToDeckBottom(Duel.SelectOrder(tp,b),false) end
    if t:GetCount()>0 then aux.ToDeckTopInOrder(tp,t) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e2)
end
