-- WX13-061 羅星　カプスフォー
-- 【出】《白》：あなたのデッキからレベル１のシグニを２枚まで探して場に出し、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{W}")
  e1:SetOperation(function(e,tp)
    local g=aux.Search(tp,function(x) return x:IsSigni() and x:GetLevel()==1 end,2)
    for x in g:Iter() do Duel.PutOnField(x,tp) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
end
