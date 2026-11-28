-- WXK02-075 極装　ランベルジェ
-- 【出】《赤》手札から＜アーム＞のシグニを１枚捨てる：カードを２枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{R}")
  e1:SetCost(aux.DiscardCost(1,function(x) return x:IsSigni() and x:IsClass(0,RACE_ARM) end))
  e1:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,2)
  end)
  c:RegisterEffect(e1)
end
