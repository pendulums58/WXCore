-- WXK02-070 仁の遊　ヘンガオ
-- 【出】：あなたのデッキからレベル２以下のシグニ１枚を探してもよい。そうした場合、デッキをシャッフルし、そのシグニを公開しデッキの一番上に置く。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp,eg)
    local x=aux.Search(tp,function(y) return y:IsSigni() and y:GetLevel()<=2 end,1):GetFirst()
    aux.ShuffleDeck(tp)
    if x then
      Duel.RevealCards(x)
      Duel.SendToDeckPosition(x,1)
    end
  end)
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e9)
end
