-- WX14-008 染刻の巫女　タマヨリヒメ
-- 【出】手札を１枚捨てる：あなたのデッキからシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(aux.DiscardCost(1,nil))
  e1:SetOperation(function(e,tp)
    aux.SearchToHand(tp,Card.IsSigni,1)
  end)
  c:RegisterEffect(e1)
end
