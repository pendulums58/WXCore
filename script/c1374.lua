-- WD23-013-A ワンモア・コール
-- アンコール －《無》《無》
-- あなたのデッキからカード１枚を探してデッキをシャッフルし、そのカードをデッキの一番上に置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetEncoreCost("{C}{C}")
  e1:SetOperation(function(e,tp)
    local tc=aux.Search(tp,nil,1):GetFirst()
    aux.ShuffleDeck(tp)
    if tc then
      Duel.SendToDeckPosition(tc,1)
      Duel.ConfirmCards(tp,tc)
    end
  end)
  c:RegisterEffect(e1)
end
