-- WX21-070 コードアート　†Ｃ・Ｆ・Ｍ†
-- 【出】：あなたのデッキからスペル１枚を探してトラッシュに置き、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local g=aux.Search(tp,function(x) return x:IsType(TYPE_SPELL) end,1)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
end
