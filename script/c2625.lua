-- WX13-054 弐ノ遊　フキナガシ
-- 【自】：このシグニがアタックしたとき、カード名１つを宣言する。あなたのデッキの上からカードを４枚公開し、その中から宣言したカードをすべてエナゾーンに置く。その後、残りを好きな順番でデッキの一番下に置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp)
    local cid=Duel.AnnounceCard(tp)
    local g=Duel.GetDecktopGroup(tp,aux.RevealCount(tp,4))
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    local f=g:Filter(function(c) return c:IsCardName(cid) end,nil)
    if f:GetCount()>0 then Duel.SendToEna(f) end
    local rest=g:Filter(function(c) return c:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(Duel.SelectOrder(tp,rest),false) end
  end)
  c:RegisterEffect(e1)
end
