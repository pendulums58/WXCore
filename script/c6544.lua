-- WXK04-088 幻水　ビーバン
-- 【自】：このシグニがアタックしたとき、あなたの手札から＜水獣＞のシグニを１枚公開してもよい。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp,eg)
    aux.RevealFromHand(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_SUIJU) end,1)
  end)
  c:RegisterEffect(e1)
end
