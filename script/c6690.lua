-- WXK06-075 コードメイズ　ブラノ
-- 【出】手札を１枚捨てる：あなたのデッキからレベル２の＜迷宮＞のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(aux.DiscardCost(1))
  e1:SetOperation(function(e,tp,eg)
    aux.SearchToHand(tp,function(x) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_MEIKYU) end)(x) and x:GetLevel()==2 end,1)
  end)
  c:RegisterEffect(e1)
end
