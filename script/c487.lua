-- WD23-024-E 幻水　ハイギョ
-- 【出】手札から《ライフバースト》を持つカードを１枚捨てる：あなたのデッキからカード１枚を探す。その後、デッキをシャッフルし、そのカードをデッキの一番上に置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(aux.DiscardCost(1,Card.IsLifeBurst))
  -- 상대에게 보이지 않는다(FAQ 1)
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
