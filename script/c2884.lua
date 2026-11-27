-- WX16-069 足英の文章　＃ツルカメ＃
-- 【出】英知=３：あなたのデッキからレベル１の＜英知＞のシグニ１枚を探して場に出し、デッキをシャッフルする。（あなたの場にある＜英知＞のシグニのレベルの合計がちょうど３であるかぎり有効になる）
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCondition(aux.EichiCon(3))
  e1:SetOperation(function(e,tp)
    local x=aux.Search(tp,function(c) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_EICHI)) end)(c) and c:GetLevel()==1 end,1):GetFirst()
    if x then Duel.PutOnField(x,tp) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e2)
end
