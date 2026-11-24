-- WD22-023-U 好色の罪人　ベルフェーゴ
-- 【出】：あなたのデッキから＜悪魔＞のシグニ１枚を探してトラッシュに置き、デッキをシャッフルする。
local s,id=GetID()
s.akuma=aux.ClassFilter(0,RACE_AKUMA)  -- ＜悪魔＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local g=aux.Search(tp,s.akuma,1)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
end
