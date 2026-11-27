-- WX19-049 小盾　ハヤト
-- 【出】：あなたのデッキの上からカードを２枚公開する。その中からカード名に《盾》を含むシグニ１枚を手札に加え、残りを好きな順番でデッキの一番上に戻す。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,aux.RevealCount(tp,2))
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    local x=Duel.SelectCards(tp,g:Filter(function(c) return c:IsSigni() and aux.NameHas(c,"盾") end,nil),0,1)
    if x:GetCount()>0 then Duel.SendToHand(x) end
    local rest=g:Filter(function(c) return c:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then aux.ToDeckTopInOrder(tp,rest) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e2)
end
