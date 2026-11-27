-- WX14-062 ＳＴＡＲ　ＡＲＲＯＷ
-- 対戦相手の手札を１枚見ないで選び、捨てさせる。カードを１枚引き、あなたのデッキからシグニ１枚とスペル１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local h=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil)
    if h:GetCount()>0 then Duel.SendToTrash(Duel.SelectCards(tp,h,1,1),REASON_EFFECT+REASON_DISCARD) end
    Duel.Draw(tp,1)
    local a=aux.Search(tp,Card.IsSigni,1)
    local b=aux.Search(tp,function(x) return x:IsType(TYPE_SPELL) end,1)
    a:Merge(b)
    if a:GetCount()>0 then Duel.RevealCards(a) Duel.SendToHand(a) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
end
