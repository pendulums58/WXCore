-- WDK11-017 ＧＦ　ナイラ
-- 【出】手札から＜英知＞のシグニを１枚捨てる：あなたのデッキから白のスペル１枚を探して公開し手札に加え、デッキをシャッフルする。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(aux.DiscardCost(1,aux.ClassFilter(0,RACE_EICHI)))
  e1:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return x:IsType(TYPE_SPELL) and x:IsColor(COLOR_WHITE) end,1)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e2)
end
